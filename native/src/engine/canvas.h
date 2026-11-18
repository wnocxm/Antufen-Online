// Yazılımla çizim tuvali (RGBA). HTML'deki 2D tuvalin oyunda kullanılan kısmı: görsel parçası kopyalama (aynalama, saydamlık,
// ışık olarak ekleme), dolgu, elips gölge. Pencereli oyunda bu tuval SDL dokusu olarak ekrana büyütülür; testte PNG olarak yazılır.
#pragma once
#include <cstdint>

#include "core/png.h"

namespace engine {

class Canvas {
 public:
  core::Image img;
  void resize(int w, int h);
  int w() const { return img.w; }
  int h() const { return img.h; }
  void fill(uint8_t r, uint8_t g, uint8_t b);
  // kaynaktan (sx, sy, w, h) parçasını (dx, dy)'ye çiz; flipX/flipY aynalar; alpha 0..1; additive = ışık (lighter)
  void blit(const core::Image& src, int sx, int sy, int w, int h, int dx, int dy, bool flipX = false, bool flipY = false, float alpha = 1.f, bool additive = false);
  // yarı saydam siyah elips (varlıkların ayak gölgesi)
  void shadow(int cx, int cy, int rx, int ry, float alpha);
};

}  // namespace engine
