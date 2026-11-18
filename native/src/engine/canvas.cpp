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

}  // namespace engine
