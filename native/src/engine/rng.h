// Rastgele sayılar ve JavaScript hesaplarının birebir karşılıkları.
// Oyunun bütün zar atışları tek bir üreteçten gelir (HTML'deki Math.random gibi). Üreteç mulberry32: tohum verilince iki sürüm
// (C++ ve HTML karşılaştırma testinde Math.random yerine aynı üreteç) aynı diziyi üretir; atışlar aynı sırayla yapıldıkça sonuç aynıdır.
#pragma once
#include <cmath>
#include <cstdint>

namespace engine {

class Rng {
 public:
  explicit Rng(uint32_t seed = 0x5EED1234u) : a_(seed) {}
  void seed(uint32_t s) { a_ = s; }
  uint32_t state() const { return a_; }   // ağ: dünya özeti ve eşitleme
  double next() {   // [0, 1) — mulberry32 (JS: Math.imul ve >>> ile aynı 32 bit işlemler)
    a_ += 0x6D2B79F5u;
    uint32_t t = (a_ ^ (a_ >> 15)) * (1u | a_);
    t = (t + ((t ^ (t >> 7)) * (61u | t))) ^ t;
    return double(t ^ (t >> 14)) / 4294967296.0;
  }
 private:
  uint32_t a_;
};

Rng& rng();                                                            // oyunun tek üreteci
inline double rnd(double a, double b) { return a + rng().next() * (b - a); }   // HTML rnd
inline int irnd(int a, int b) { return int(std::floor(rnd(a, b + 1))); }      // HTML irnd
inline double random() { return rng().next(); }                               // HTML Math.random()

// JS Math.round (yarım yukarı); std::round eksi yarımda farklıdır
inline double jsRound(double v) { return std::floor(v + 0.5); }
// V8 Math.hypot (iki değer): en büyüğe bölüp Kahan toplamıyla — std::hypot ile son basamakta farklı olabilir, dallanmalar aynı kalsın diye birebir
inline double jsHypot(double x, double y) {
  x = std::fabs(x); y = std::fabs(y);
  const double mx = x > y ? x : y;
  if (std::isinf(mx)) return INFINITY;
  if (mx == 0) return 0;
  double sum = 0, comp = 0;
  for (double v : {x, y}) { const double n = v / mx, s = n * n - comp, pre = sum + s; comp = (pre - sum) - s; sum = pre; }
  return std::sqrt(sum) * mx;
}
inline double clampd(double v, double a, double b) { return v < a ? a : v > b ? b : v; }
inline double jsSign(double v) { return v > 0 ? 1 : v < 0 ? -1 : v; }

}  // namespace engine
