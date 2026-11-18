#include "canvas.h"

#include <algorithm>
#include <cmath>

namespace engine {

void Canvas::resize(int w, int h) { img.w = w; img.h = h; img.px.assign(size_t(w) * h * 4, 0); }

void Canvas::fill(uint8_t r, uint8_t g, uint8_t b) {
  for (size_t i = 0; i < img.px.size(); i += 4) { img.px[i] = r; img.px[i + 1] = g; img.px[i + 2] = b; img.px[i + 3] = 255; }
}

void Canvas::blit(const core::Image& src, int sx, int sy, int w, int h, int dx, int dy, bool flipX, bool flipY, float alpha, bool additive) {
  if (alpha <= 0) return;
  const int ga = int(alpha * 255 + 0.5f);
  // hedefte görünen aralık
  int x0 = std::max(0, -dx), y0 = std::max(0, -dy), x1 = std::min(w, img.w - dx), y1 = std::min(h, img.h - dy);
  for (int y = y0; y < y1; y++) {
    const int syy = sy + (flipY ? h - 1 - y : y); if (syy < 0 || syy >= src.h) continue;
    uint8_t* d = img.at(dx + x0, dy + y);
    for (int x = x0; x < x1; x++, d += 4) {
      const int sxx = sx + (flipX ? w - 1 - x : x); if (sxx < 0 || sxx >= src.w) continue;
      const uint8_t* s = src.at(sxx, syy);
      const int a = s[3] * ga / 255; if (!a) continue;
      if (additive) { for (int k = 0; k < 3; k++) d[k] = uint8_t(std::min(255, d[k] + s[k] * a / 255)); }
      else if (a == 255) { d[0] = s[0]; d[1] = s[1]; d[2] = s[2]; }
      else { for (int k = 0; k < 3; k++) d[k] = uint8_t((s[k] * a + d[k] * (255 - a) + 127) / 255); }
      d[3] = 255;
    }
  }
}

void Canvas::shadow(int cx, int cy, int rx, int ry, float alpha) {
  const int a = int(alpha * 255 + 0.5f);
  for (int y = -ry; y <= ry; y++) {
    const int half = int(std::floor(rx * std::sqrt(std::max(0.0, 1.0 - double(y * y) / (ry * ry))) + 0.5));
    const int Y = cy + y; if (Y < 0 || Y >= img.h) continue;
    for (int x = -half; x <= half; x++) {
      const int X = cx + x; if (X < 0 || X >= img.w) continue;
      uint8_t* d = img.at(X, Y);
      for (int k = 0; k < 3; k++) d[k] = uint8_t(d[k] * (255 - a) / 255);
    }
  }
}

// ---------------- arayüz çizimi ----------------
float Canvas::clipCov(int x, int y) const {
  float c = 1;
  if (clipR_) {   // dikdörtgen kırpma: pikselin dikdörtgen içinde kalan alanı
    const float ox = std::max(0.f, std::min(float(x + 1), crx1_) - std::max(float(x), crx0_)), oy = std::max(0.f, std::min(float(y + 1), cry1_) - std::max(float(y), cry0_));
    c *= ox * oy;
  }
  if (clipC_ && c > 0) {   // daire: merkeze uzaklığa göre yumuşak kenar
    const float d = std::sqrt((x + 0.5f - ccx_) * (x + 0.5f - ccx_) + (y + 0.5f - ccy_) * (y + 0.5f - ccy_));
    c *= std::max(0.f, std::min(1.f, ccr_ + 0.5f - d));
  }
  return c;
}
void Canvas::clipRect(float x, float y, float w, float h) {
  if (clipR_) { crx0_ = std::max(crx0_, x); cry0_ = std::max(cry0_, y); crx1_ = std::min(crx1_, x + w); cry1_ = std::min(cry1_, y + h); }
  else { clipR_ = true; crx0_ = x; cry0_ = y; crx1_ = x + w; cry1_ = y + h; }
}
void Canvas::clipCircle(float cx, float cy, float r) { clipC_ = true; ccx_ = cx; ccy_ = cy; ccr_ = r; }
void Canvas::clearClip() { clipR_ = clipC_ = false; }

void Canvas::blend(int x, int y, uint32_t rgb, float a) {
  if (x < 0 || y < 0 || x >= img.w || y >= img.h) return;
  if (clipR_ || clipC_) a *= clipCov(x, y);
  if (a <= 0) return;
  if (a > 1) a = 1;
  uint8_t* d = img.at(x, y);
  const float r = float((rgb >> 16) & 255), g = float((rgb >> 8) & 255), b = float(rgb & 255);
  d[0] = uint8_t(d[0] + (r - d[0]) * a + 0.5f); d[1] = uint8_t(d[1] + (g - d[1]) * a + 0.5f); d[2] = uint8_t(d[2] + (b - d[2]) * a + 0.5f); d[3] = 255;
}

// kesirli dikdörtgen: kenar piksellerinde örtülen alan kadar (tarayıcının kenar yumuşatması gibi)
void Canvas::fillRect(float x, float y, float w, float h, uint32_t rgb, float a) {
  if (w < 0) { x += w; w = -w; }
  if (h < 0) { y += h; h = -h; }
  const float x1 = x + w, y1 = y + h;
  const int X0 = std::max(0, int(std::floor(x))), Y0 = std::max(0, int(std::floor(y))), X1 = std::min(img.w, int(std::ceil(x1))), Y1 = std::min(img.h, int(std::ceil(y1)));
  for (int py = Y0; py < Y1; py++) {
    const float cy = std::min(float(py + 1), y1) - std::max(float(py), y); if (cy <= 0) continue;
    for (int px = X0; px < X1; px++) {
      const float cx = std::min(float(px + 1), x1) - std::max(float(px), x); if (cx <= 0) continue;
      blend(px, py, rgb, a * cx * cy);
    }
  }
}
void Canvas::strokeRect(float x, float y, float w, float h, float lw, uint32_t rgb, float a) {
  const float k = lw / 2;
  fillRect(x - k, y - k, w + lw, lw, rgb, a);                 // üst
  fillRect(x - k, y + h - k, w + lw, lw, rgb, a);             // alt
  fillRect(x - k, y + k, lw, h - lw, rgb, a);                 // sol (köşeler üstte/altta)
  fillRect(x + w - k, y + k, lw, h - lw, rgb, a);             // sağ
}
// elips: 4×4 alt örnekle örtü
void Canvas::fillEllipse(float cx, float cy, float rx, float ry, uint32_t rgb, float a) {
  if (rx <= 0 || ry <= 0) return;
  const int X0 = std::max(0, int(std::floor(cx - rx))), X1 = std::min(img.w, int(std::ceil(cx + rx))), Y0 = std::max(0, int(std::floor(cy - ry))), Y1 = std::min(img.h, int(std::ceil(cy + ry)));
  for (int py = Y0; py < Y1; py++) for (int px = X0; px < X1; px++) {
    int n = 0;
    for (int sy = 0; sy < 4; sy++) for (int sx = 0; sx < 4; sx++) { const float u = (px + (sx + 0.5f) / 4 - cx) / rx, v = (py + (sy + 0.5f) / 4 - cy) / ry; n += u * u + v * v <= 1; }
    if (n) blend(px, py, rgb, a * n / 16.f);
  }
}
void Canvas::strokeEllipse(float cx, float cy, float rx, float ry, float lw, uint32_t rgb, float a) {
  if (rx <= 0 || ry <= 0) return;
  const float m = lw / 2 + 1;
  const int X0 = std::max(0, int(std::floor(cx - rx - m))), X1 = std::min(img.w, int(std::ceil(cx + rx + m))), Y0 = std::max(0, int(std::floor(cy - ry - m))), Y1 = std::min(img.h, int(std::ceil(cy + ry + m)));
  for (int py = Y0; py < Y1; py++) for (int px = X0; px < X1; px++) {
    int n = 0;
    for (int sy = 0; sy < 4; sy++) for (int sx = 0; sx < 4; sx++) {
      const float X = px + (sx + 0.5f) / 4 - cx, Y = py + (sy + 0.5f) / 4 - cy;
      const float f = X * X / (rx * rx) + Y * Y / (ry * ry) - 1, gx = 2 * X / (rx * rx), gy = 2 * Y / (ry * ry), g = std::sqrt(gx * gx + gy * gy);
      n += g > 0 && std::fabs(f / g) <= lw / 2;   // elipse yaklaşık uzaklık
    }
    if (n) blend(px, py, rgb, a * n / 16.f);
  }
}

void Canvas::drawImage(const core::Image& src, float sx, float sy, float sw, float sh, float dx, float dy, float dw, float dh, float alpha, bool smooth, bool additive) {
  if (alpha <= 0 || dw <= 0 || dh <= 0 || sw <= 0 || sh <= 0 || src.empty()) return;
  const int X0 = std::max(0, int(std::floor(dx))), X1 = std::min(img.w, int(std::ceil(dx + dw))), Y0 = std::max(0, int(std::floor(dy))), Y1 = std::min(img.h, int(std::ceil(dy + dh)));
  const float fx = dw / sw, fy = dh / sh;
  auto at = [&](int x, int y) { x = std::max(int(sx), std::min(int(std::ceil(sx + sw)) - 1, x)); y = std::max(int(sy), std::min(int(std::ceil(sy + sh)) - 1, y)); x = std::max(0, std::min(src.w - 1, x)); y = std::max(0, std::min(src.h - 1, y)); return src.at(x, y); };
  for (int py = Y0; py < Y1; py++) {
    const float cyy = py + 0.5f; if (cyy < dy || cyy >= dy + dh) continue;   // piksel merkezi hedefin içinde mi (tarayıcıdaki gibi)
    for (int px = X0; px < X1; px++) {
      const float cxx = px + 0.5f; if (cxx < dx || cxx >= dx + dw) continue;
      // kaynakta karşılığı: hedef piksel merkezinden ölçeğe bölerek, tek duyarlıklı (tarayıcının en yakın komşu örneklemesine en yakın)
      const float u = sx + (cxx - dx) / fx, v = sy + (cyy - dy) / fy;
      float c[4] = {0, 0, 0, 0};
      if (!smooth) { const uint8_t* s = at(int(std::floor(u)), int(std::floor(v))); for (int k = 0; k < 4; k++) c[k] = s[k]; }
      else {   // çift doğrusal (tarayıcının varsayılan "low" kalitesi: küçültmede de ara boyut yok); önceden çarpılmış alfa ile
        const float fu = u - 0.5f, fv = v - 0.5f; const int iu = int(std::floor(fu)), iv = int(std::floor(fv)); const float tu = fu - iu, tv = fv - iv;
        const uint8_t* q[4] = {at(iu, iv), at(iu + 1, iv), at(iu, iv + 1), at(iu + 1, iv + 1)}; const float w[4] = {(1 - tu) * (1 - tv), tu * (1 - tv), (1 - tu) * tv, tu * tv};
        float sa = 0; for (int j = 0; j < 4; j++) { for (int k = 0; k < 3; k++) c[k] += q[j][k] * q[j][3] / 255.f * w[j]; sa += q[j][3] * w[j]; }
        c[3] = sa; if (sa > 0) for (int k = 0; k < 3; k++) c[k] = c[k] * 255.f / sa;
      }
      float a = c[3] / 255.f * alpha; if (clipR_ || clipC_) a *= clipCov(px, py);
      if (a <= 0) continue;
      uint8_t* d = img.at(px, py);
      if (additive) { for (int k = 0; k < 3; k++) d[k] = uint8_t(std::min(255.f, d[k] + c[k] * a + 0.5f)); }
      else for (int k = 0; k < 3; k++) d[k] = uint8_t(d[k] + (c[k] - d[k]) * std::min(1.f, a) + 0.5f);
      d[3] = 255;
    }
  }
}

void Canvas::fillRadial(float cx, float cy, float r0, float r1, uint32_t rgb, float a0, float a1) {
  for (int py = 0; py < img.h; py++) for (int px = 0; px < img.w; px++) {
    const float d = std::sqrt((px + 0.5f - cx) * (px + 0.5f - cx) + (py + 0.5f - cy) * (py + 0.5f - cy));
    const float t = std::max(0.f, std::min(1.f, (d - r0) / std::max(1e-3f, r1 - r0)));
    const float a = a0 + (a1 - a0) * t; if (a > 0) blend(px, py, rgb, a);
  }
}

}  // namespace engine
