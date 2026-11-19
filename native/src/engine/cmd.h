// Komut: arayüzün dünyayı değiştiren her isteği (docs/10-ag.md). Çevrimdışı yerelde uygulanır; çevrimiçi aynı komut adım numarasıyla
// sunucuya gider, sunucu kendi dünyasında uygular (istemci de anında tepki için yerelde uygular). Değerler metin (JSON dizisi olarak taşınır).
#pragma once
#include <cstdlib>
#include <string>
#include <vector>

namespace engine {

struct Cmd {
  std::string op;                 // ör. "skill", "buy", "accept", "gm"
  std::vector<std::string> a;     // değerler
  const std::string& s(size_t k) const { static const std::string e; return k < a.size() ? a[k] : e; }
  int i(size_t k) const { return k < a.size() ? std::atoi(a[k].c_str()) : 0; }
};

}  // namespace engine
