// Ses karıştırıcı: HTML audio.js'in SFX / Music davranışı (ayrıntı audio.h).
#include "engine/audio.h"

#include "core/json.h"

#include <algorithm>
#include <cmath>
#include <cstring>

namespace engine {

const std::map<std::string, double>& Audio::loops() {
  static const std::map<std::string, double> L = {
      {"akadiya_music.mid", 42.401}, {"alica_music.mid", 54.135}, {"church_music.mid", 32.016}, {"cover.mid", 45.197},
      {"grassland.mid", 34.688}, {"hole_music.mid", 38.588}, {"nufengshan_music.mid", 37.374}, {"shengbeishan_music.mid", 38.281},
      {"sliva_music.mid", 36.66}, {"snowmountain_music.mid", 38.249}, {"startown_music.mid", 36.51}, {"sunnyforrest_music.mid", 43.161}};
  return L;
}

// WAV (PCM 8/16 bit, tek ya da çift kanal) → tek kanal float
std::shared_ptr<Audio::Clip> Audio::load(const std::string& path) {
  auto it = clips_.find(path); if (it != clips_.end()) return it->second;
  std::shared_ptr<Clip> c;
  try {
    if (vfs_ && vfs_->exists(path)) {
      const auto b = vfs_->read(path);
      auto u32 = [&](size_t p) { return uint32_t(b[p]) | uint32_t(b[p + 1]) << 8 | uint32_t(b[p + 2]) << 16 | uint32_t(b[p + 3]) << 24; };
      auto u16 = [&](size_t p) { return uint16_t(b[p] | b[p + 1] << 8); };
      if (b.size() > 12 && !std::memcmp(b.data(), "RIFF", 4) && !std::memcmp(b.data() + 8, "WAVE", 4)) {
        int ch = 1, bits = 16, rate = 8000; size_t p = 12;
        while (p + 8 <= b.size()) {
          const uint32_t n = u32(p + 4); const size_t d = p + 8;
          if (!std::memcmp(b.data() + p, "fmt ", 4) && d + 16 <= b.size()) { ch = std::max(1, int(u16(d + 2))); rate = int(u32(d + 4)); bits = u16(d + 14); }
          else if (!std::memcmp(b.data() + p, "data", 4)) {
            const size_t end = std::min(b.size(), d + n), bps = size_t(bits / 8) * size_t(ch);
            c = std::make_shared<Clip>(); c->rate = rate;
            for (size_t q = d; bps && q + bps <= end; q += bps) {
              float v = 0;
              for (int k = 0; k < ch; k++) v += bits == 16 ? int16_t(u16(q + size_t(k) * 2)) / 32768.f : (int(b[q + size_t(k)]) - 128) / 128.f;
              c->s.push_back(v / float(ch));
            }
            break;
          }
          p = d + n + (n & 1);
        }
      }
    }
  } catch (...) { c.reset(); }
  clips_[path] = c;
  return c;
}

void Audio::play(const std::string& name, double vol) {
  if (!sfxOn || name.empty()) return;
  auto it = lastAt_.find(name); if (it != lastAt_.end() && now_ - it->second < 0.06) return;
  lastAt_[name] = now_;
  auto c = load("snd/" + name + ".wav"); if (!c || c->s.empty()) return;
  Voice v; v.c = c; v.gain = 0.7 * vol; voices_.push_back(v);
}

double Audio::Param::at(double t) const {
  if (kind == 1) { if (t <= t0) return v0; if (t >= t1) return v1; return v0 + (v1 - v0) * (t - t0) / (t1 - t0); }
  if (kind == 2) { if (t <= t0) return v0; return v1 + (v0 - v1) * std::exp(-(t - t0) / tau); }
  return v0;
}

void Audio::stopMusic() {
  for (Voice& v : voices_) if (v.music && v.stopAt < 0) v.stopAt = now_ + 0.3;   // s.stop(ac.currentTime + 0.3)
  const double g = mus_.at(now_); mus_ = Param(); mus_.kind = 2; mus_.t0 = now_; mus_.v0 = g; mus_.v1 = 0.0001; mus_.tau = 0.08;   // setTargetAtTime
  cur_.clear();
}

double Audio::trackGain(const std::string& name) {
  if (!gainsLoaded_) {
    gainsLoaded_ = true;
    try { if (vfs_ && vfs_->exists("music/seviye.json")) { const auto b = vfs_->read("music/seviye.json"); const core::Json j = core::Json::parse(std::string(b.begin(), b.end()));
      for (const auto& kv : j["kazanc"].obj()) trackGain_[kv.first] = kv.second.num(1); } } catch (...) {}
  }
  auto it = trackGain_.find(name); return it == trackGain_.end() ? 1 : it->second;
}

void Audio::music(const std::string& name0) {
  if (name0.empty()) return;
  std::string name = loops().count(name0) ? name0 : "grassland.mid"; pending_ = name;
  if (!musicOn) return;
  if (cur_ == name) { for (const Voice& v : voices_) if (v.music && v.stopAt < 0) return; }
  stopMusic(); cur_ = name;
  auto c = load("music/" + name.substr(0, name.size() - 4) + ".wav"); if (!c || c->s.empty()) return;   // .mid → .wav
  mus_ = Param(); mus_.kind = 1; mus_.t0 = now_; mus_.v0 = 0.0001; mus_.t1 = now_ + 0.6; mus_.v1 = 0.55;   // 0,6 sn'de 0,55'e
  Voice v; v.c = c; v.loop = true; v.music = true; v.gain = trackGain(name); v.loopEnd = std::min(double(c->s.size()) / c->rate, loops().at(name));
  voices_.push_back(v);
}

// Chrome media::SincResampler gibi: 32 nokta, Blackman penceresi, kesim ölçeği min(1, dst/src) × 0,9; alt konumlar arası doğrusal
const float* Audio::kernel(int src, int dst, double frac) {
  constexpr int K = 32, P = 256;
  if (kernSrc_ != src || kernRate_ != dst) {
    kernSrc_ = src; kernRate_ = dst; kern_.assign(size_t((P + 1) * K), 0.f);
    const double sf = std::min(1.0, double(dst) / src) * 0.9, PI = 3.14159265358979323846;
    for (int p = 0; p <= P; p++) {
      const double o = double(p) / P;
      for (int i = 0; i < K; i++) {
        const double pre = PI * (i - K / 2 - o), x = (i - o) / K;
        const double win = 0.42 - 0.5 * std::cos(2 * PI * x) + 0.08 * std::cos(4 * PI * x);
        kern_[size_t(p * K + i)] = float(win * (pre == 0 ? sf : std::sin(sf * pre) / pre));
      }
    }
  }
  static thread_local float k[32];
  const double q = frac * 256; const int p0 = std::min(255, int(q)); const float t = float(q - p0);
  for (int i = 0; i < 32; i++) k[i] = kern_[size_t(p0 * 32 + i)] * (1 - t) + kern_[size_t((p0 + 1) * 32 + i)] * t;
  return k;
}

void Audio::mix(float* out, int frames, int rate) {
  std::memset(out, 0, sizeof(float) * size_t(frames) * 2);
  for (Voice& v : voices_) {
    const std::vector<float>& s = v.c->s; const double step = double(v.c->rate) / rate, n = double(s.size());
    const double le = v.loop ? v.loopEnd * v.c->rate : n;
    auto S = [&](long i) -> float { if (v.loop) { const long L = long(le); if (L <= 0) return 0; i %= L; if (i < 0) i += L; } return i >= 0 && i < long(s.size()) ? s[size_t(i)] : 0.f; };
    for (int f = 0; f < frames; f++) {
      const double t = now_ + double(f) / rate;
      if (v.stopAt >= 0 && t >= v.stopAt) { v.pos = 1e18; break; }
      if (!v.loop && v.pos >= n) break;
      const long i = long(std::floor(v.pos));
      const float* kk = kernel(v.c->rate, rate, v.pos - double(i)); float y = 0;
      for (int j = 0; j < 32; j++) y += S(i - 16 + j) * kk[j];
      const float g = float(v.music ? mus_.at(t) * v.gain : v.gain);
      out[f * 2] += y * g; out[f * 2 + 1] += y * g;
      v.pos += step; if (v.loop && v.pos >= le) v.pos -= le;
    }
  }
  voices_.erase(std::remove_if(voices_.begin(), voices_.end(), [](const Voice& v) { return v.pos >= 1e17 || (!v.loop && v.pos >= double(v.c->s.size())); }), voices_.end());
  for (int i = 0; i < frames * 2; i++) out[i] = std::max(-1.f, std::min(1.f, out[i]));
  now_ += double(frames) / rate;
}

}  // namespace engine
