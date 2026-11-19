// Yazılımla çizim tuvali (RGBA). HTML'deki 2D tuvalin oyunda kullanılan kısmı: görsel parçası kopyalama (aynalama, saydamlık,
// ışık olarak ekleme), dolgu, elips gölge; arayüz için kesirli dikdörtgen/elips, ölçekli görsel, radyal degrade, kırpma. Pencereli oyunda bu tuval SDL dokusu olarak ekrana büyütülür; testte PNG olarak yazılır.
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

  // ---- arayüz çizimi (HTML 2D tuvalinin arayüzde kullanılan kısmı; kesirli koordinatlar, kenarlar yumuşak) ----
  // renk 0xRRGGBB; a 0..1 (globalAlpha × renk saydamlığı). Bütün çizimler kırpmaya uyar.
  void blend(int x, int y, uint32_t rgb, float a);                    // tek piksel (source-over)
  void fillRect(float x, float y, float w, float h, uint32_t rgb, float a = 1);
  void strokeRect(float x, float y, float w, float h, float lw, uint32_t rgb, float a = 1);   // çizgi yolun ortasında (HTML strokeRect)
  void fillEllipse(float cx, float cy, float rx, float ry, uint32_t rgb, float a = 1);
  void fillTriangle(float x0, float y0, float x1, float y1, float x2, float y2, uint32_t rgb, float a = 1);   // kenarı yumuşak (4x4 örnek)
  void strokeEllipse(float cx, float cy, float rx, float ry, float lw, uint32_t rgb, float a = 1);
  // görsel parçası (sx, sy, sw, sh) → hedef dikdörtgen (dx, dy, dw, dh); smooth: yumuşatarak büyüt/küçült (HTML imageSmoothingEnabled)
  void drawImage(const core::Image& src, float sx, float sy, float sw, float sh, float dx, float dy, float dw, float dh,
                 float alpha = 1, bool smooth = false, bool additive = false);
  // radyal degrade dolgu (iç yarıçapta a0, dış yarıçapta a1 saydamlık; arası doğrusal) — HTML createRadialGradient
  void fillRadial(float cx, float cy, float r0, float r1, uint32_t rgb, float a0, float a1);
  // daire, iki noktalı radyal degradeyle (HTML createRadialGradient(gx0, gy0, r0, gx1, gy1, r1) + iki renk durağı, sonra arc dolgu)
  void fillCircleGrad(float cx, float cy, float r, float gx0, float gy0, float r0, float gx1, float gy1, float r1, uint32_t c0, uint32_t c1);
  // kırpma: dikdörtgen ve/veya daire (kenarı yumuşak); clearClip hepsini kaldırır
  void clipRect(float x, float y, float w, float h);
  void clipCircle(float cx, float cy, float r);
  void clearClip();

 private:
  bool clipR_ = false, clipC_ = false; float crx0_ = 0, cry0_ = 0, crx1_ = 0, cry1_ = 0, ccx_ = 0, ccy_ = 0, ccr_ = 0;
  float clipCov(int x, int y) const;
};

}  // namespace engine
