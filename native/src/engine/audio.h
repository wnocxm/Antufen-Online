// Ses karıştırıcı (HTML www/js/audio.js SFX ve SFX.Music karşılığı); SDL'den bağımsız: uygulama SDL ses aygıtının geri çağrısında
// mix() çağırır, test modu aynı çıktıyı WAV'a yazar. Kaynaklar:
//   ses efektleri  snd/<ad>.wav       (orijinal, 8 kHz tek kanal 16 bit)
//   müzik          music/<parça>.wav  (APK'nın orijinal kayıtları, 8 kHz tek kanal 16 bit; HTML bunların MP3'e çevrilmişini çalar)
// Seviyeler HTML'deki gibi: ana 1, efektler 0,7 × çağrının sesi, müzik 0,32 (başta) → yeni parçada 0,0001'den 0,6 sn'de 0,55'e;
// durdurulunca 0,08 sn zaman sabitiyle 0,0001'e söner, eski parça 0,3 sn sonra kesilir. Parça kendi döngü uzunluğunda baştan döner
// (HTML LOOP). Aynı efekt 0,06 sn içinde ikinci kez çalmaz. Yeniden örnekleme: Chrome'un SincResampler'ı gibi 32 noktalı Blackman
// pencereli sinc, kesim alçak hızın Nyquist'inin 0,9'u (8 kHz kayıtta 3,6 kHz; basit eğri yöntemi 4 kHz üstünde yansıma bırakıyordu).
// Parça kazancı music/seviye.json (tools/muzik_cpp.py): HTML'nin MP3'leri ses yüksekliği eşitlenmiş (orijinalden 5-10 dB kısık);
// C++ orijinal WAV'ı aynı yükseklikte çalsın diye RMS(mp3) / RMS(wav).
#pragma once
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "engine/vfs.h"

namespace engine {

class Audio {
 public:
  void attach(const Vfs& vfs) { vfs_ = &vfs; }
  // HTML SFX.play(name, vol): efektler kapalıysa ya da aynı ad 0,06 sn içinde çaldıysa çalmaz
  void play(const std::string& name, double vol = 1);
  // HTML SFX.Music.play(name): bilinmeyen parça yerine grassland; aynı parça çalıyorsa dokunmaz; müzik kapalıysa yalnız hatırlar
  void music(const std::string& name);
  void stopMusic();                       // HTML Music.stop
  void setSfx(bool on) { sfxOn = on; }
  void setMusic(bool on) { musicOn = on; if (!on) stopMusic(); else music(pending_); }
  bool sfxOn = true, musicOn = true;
  // karıştır: frames kare, stereo float (sol, sağ), rate örnekleme hızı; saat ilerler
  void mix(float* out, int frames, int rate);
  double time() const { return now_; }    // ses saati (sn; HTML ac.currentTime)
  std::string current() const { return cur_; }
  static const std::map<std::string, double>& loops();   // HTML LOOP: parça → döngü uzunluğu (sn)

 private:
  struct Clip { std::vector<float> s; int rate = 8000; };
  std::shared_ptr<Clip> load(const std::string& path);
  std::map<std::string, std::shared_ptr<Clip>> clips_;
  std::map<std::string, double> trackGain_; bool gainsLoaded_ = false;
  double trackGain(const std::string& name);
  std::vector<float> kern_; int kernRate_ = 0, kernSrc_ = 0;   // sinc çekirdeği (257 alt konum × 32 nokta)
  const float* kernel(int src, int dst, double frac);
  struct Voice { std::shared_ptr<Clip> c; double pos = 0, gain = 1, loopEnd = 0, stopAt = -1; bool loop = false, music = false; };
  std::vector<Voice> voices_;
  std::map<std::string, double> lastAt_;
  // müzik kazancı (AudioParam): son olay rampa ya da hedefe yaklaşma
  struct Param { int kind = 0; double t0 = 0, v0 = 0.32, t1 = 0, v1 = 0.32, tau = 0; double at(double t) const; } mus_;
  std::string cur_, pending_;
  const Vfs* vfs_ = nullptr;
  double now_ = 0;
};

}  // namespace engine
