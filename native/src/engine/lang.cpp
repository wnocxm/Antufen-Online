// Dil: HTML i18n.js tx() ile aynı sıra (sözlük → kalıplar → " · " parçaları). Ayrıntı lang.h.
#include "engine/lang.h"

#include "core/json.h"

namespace engine {

Lang& lang() { static Lang L; return L; }

void Lang::load(const Vfs& vfs) {
  ui_.clear(); item_.clear(); cls_.clear(); race_.clear(); rules_.clear(); cache_.clear();
  if (!vfs.exists("dil_en.json")) return;
  const auto b = vfs.read("dil_en.json"); const core::Json j = core::Json::parse(std::string(b.begin(), b.end()));
  for (const auto& kv : j["ui"].obj()) ui_[kv.first] = kv.second.str();
  for (const auto& kv : j["esya"].obj()) item_[kv.first] = kv.second.str();
  for (const auto& kv : j["sinif"].obj()) cls_[kv.first] = kv.second.str();
  for (const auto& kv : j["irk"].obj()) race_[kv.first] = kv.second.str();
  for (const core::Json& r : j["kurallar"].arr()) {
    Rule R; R.re = std::regex(r[0].str(), std::regex::ECMAScript); R.rep = r[2].str(); R.tpl = r[3].truthy(); rules_.push_back(std::move(R));
  }
}

const std::string& Lang::item(const std::string& n) const { static const std::string e; auto it = item_.find(n); return it == item_.end() ? e : it->second; }
std::string Lang::cls(const std::string& cn) const {
  if (en) { auto it = cls_.find(cn); if (it != cls_.end()) return it->second; }
  return cn == "战士" ? "Savaşçı" : cn == "法师" ? "Büyücü" : cn == "牧师" ? "Kutsal Elçi" : cn;
}
std::string Lang::race(const std::string& cn) const {
  if (en) { auto it = race_.find(cn); if (it != race_.end()) return it->second; }
  return cn == "人类" ? "İnsan" : cn == "精灵" ? "Gece Elfi" : cn;
}

// JS String.replace(re, değiştirme): $1…$9, $&, $$; şablonda $tN = tx(N. grup)
std::string Lang::apply(const Rule& r, const std::string& k, const std::smatch& m) {
  std::string o = m.prefix().str();
  const std::string& p = r.rep;
  for (size_t i = 0; i < p.size(); i++) {
    if (p[i] != '$' || i + 1 >= p.size()) { o += p[i]; continue; }
    const char c = p[i + 1];
    if (c == '$') { o += '$'; i++; }
    else if (c == '&') { o += m[0].str(); i++; }
    else if (c == 't' && r.tpl && i + 2 < p.size() && p[i + 2] >= '1' && p[i + 2] <= '9') { o += tx(m[size_t(p[i + 2] - '0')].str()); i += 2; }
    else if (c >= '1' && c <= '9') { o += m[size_t(c - '0')].str(); i++; }
    else o += p[i];
  }
  return o + m.suffix().str();
  (void)k;
}

std::string Lang::tx(const std::string& s) {
  if (!en || s.empty()) return s;
  auto c = cache_.find(s); if (c != cache_.end()) return c->second;
  // JS trim: baştaki ve sondaki boşluklar
  const char* ws = " \t\n\r\f\v"; const size_t a = s.find_first_not_of(ws);
  if (a == std::string::npos) return s;
  const size_t z = s.find_last_not_of(ws); const std::string k = s.substr(a, z - a + 1);
  auto put = [&](const std::string& r) { if (cache_.size() > 20000) cache_.clear(); cache_[s] = r; return r; };
  auto rebuild = [&](const std::string& v) { return s.substr(0, a) + v + s.substr(z + 1); };   // s.replace(k, …): yalnız ilk geçiş
  auto u = ui_.find(k); if (u != ui_.end()) return put(rebuild(u->second));
  for (const Rule& r : rules_) { std::smatch m; if (std::regex_search(k, m, r.re)) return put(rebuild(apply(r, k, m))); }
  if (k.find(" · ") != std::string::npos) {
    std::string o; size_t p = 0;
    for (;;) { const size_t q = k.find(" · ", p); o += tx(k.substr(p, q == std::string::npos ? std::string::npos : q - p)); if (q == std::string::npos) break; o += " · "; p = q + 4; }
    return put(rebuild(o));
  }
  // çevirisi olmayan Türkçe metin (HTML TX_MISS): Türkçeye özgü harf varsa kaydet
  for (const char* t : {"ç", "ğ", "ı", "ş", "ö", "ü", "Ç", "Ğ", "İ", "Ş", "Ö", "Ü"}) if (k.find(t) != std::string::npos) { if (missing.size() < 2000) missing.push_back(k); break; }
  return put(s);
}

}  // namespace engine
