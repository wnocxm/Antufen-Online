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
void Canvas::fillTriangle(float x0, float y0, float x1, float y1, float x2, float y2, uint32_t rgb, float a) {
  const int X0 = std::max(0, int(std::floor(std::min({x0, x1, x2})))), X1 = std::min(img.w, int(std::ceil(std::max({x0, x1, x2}))));
  const int Y0 = std::max(0, int(std::floor(std::min({y0, y1, y2})))), Y1 = std::min(img.h, int(std::ceil(std::max({y0, y1, y2}))));
  auto e = [](float ax, float ay, float bx, float by, float px, float py) { return (bx - ax) * (py - ay) - (by - ay) * (px - ax); };
  const float s = e(x0, y0, x1, y1, x2, y2) < 0 ? -1.f : 1.f;
  for (int py = Y0; py < Y1; py++) for (int px = X0; px < X1; px++) {
    int n = 0;
    for (int sy = 0; sy < 4; sy++) for (int sx = 0; sx < 4; sx++) {
      const float u = px + (sx + 0.5f) / 4, v = py + (sy + 0.5f) / 4;
      n += s * e(x0, y0, x1, y1, u, v) >= 0 && s * e(x1, y1, x2, y2, u, v) >= 0 && s * e(x2, y2, x0, y0, u, v) >= 0;
    }
    if (n) blend(px, py, rgb, a * n / 16.f);
  }
}
void Canvas::fillCircleGrad(float cx, float cy, float r, float gx0, float gy0, float r0, float gx1, float gy1, float r1, uint32_t c0, uint32_t c1) {
  if (r <= 0) return;
  const float dx = gx1 - gx0, dy = gy1 - gy0, dr = r1 - r0, A = dx * dx + dy * dy - dr * dr;
  const int X0 = std::max(0, int(std::floor(cx - r))), X1 = std::min(img.w, int(std::ceil(cx + r))), Y0 = std::max(0, int(std::floor(cy - r))), Y1 = std::min(img.h, int(std::ceil(cy + r)));
  for (int py = Y0; py < Y1; py++) for (int px = X0; px < X1; px++) {
    int n = 0;
    for (int sy = 0; sy < 4; sy++) for (int sx = 0; sx < 4; sx++) { const float u = (px + (sx + 0.5f) / 4 - cx) / r, v = (py + (sy + 0.5f) / 4 - cy) / r; n += u * u + v * v <= 1; }
    if (!n) continue;
    // degrade konumu t: noktadan geçen en büyük daire c(t) = c0 + t·d, r(t) = r0 + t·dr ≥ 0 (piksel merkezinde)
    const float qx = px + 0.5f - gx0, qy = py + 0.5f - gy0, B = qx * dx + qy * dy + r0 * dr, C = qx * qx + qy * qy - r0 * r0;
    float t = 0;
    if (std::fabs(A) < 1e-6f) t = B != 0 ? C / (2 * B) : 0;
    else { const float D = B * B - A * C; if (D < 0) continue; const float sq = std::sqrt(D), t1 = (B + sq) / A, t2 = (B - sq) / A; t = std::max(t1, t2); if (r0 + t * dr < 0) t = std::min(t1, t2); }
    t = std::max(0.f, std::min(1.f, t));
    auto ch = [&](int sh) { return float((c0 >> sh) & 255) + (float((c1 >> sh) & 255) - float((c0 >> sh) & 255)) * t; };
    const uint32_t col = (uint32_t(ch(16) + 0.5f) << 16) | (uint32_t(ch(8) + 0.5f) << 8) | uint32_t(ch(0) + 0.5f);
    blend(px, py, col, n / 16.f);
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

// küçültme kopyası (mip düzeyi): her düzey bir öncekinin 2×2 ortalaması (Skia SkMipmap: önceden çarpılmış renk, toplam >> 2); önbellekli
static const core::Image& mipLevel(const core::Image& src, int lvl) {
  struct E { const void* p; int w, h, lvl; uint32_t sum; core::Image im; };
  static std::vector<E> cache;
  uint32_t sum = 0; for (int k = 0; k < 16; k++) { const size_t i = (src.px.size() / 4 / 16 * size_t(k)) * 4; sum = sum * 31 + src.px[i] + (uint32_t(src.px[i + 1]) << 8) + (uint32_t(src.px[i + 3]) << 16); }
  for (const E& e : cache) if (e.p == src.px.data() && e.w == src.w && e.h == src.h && e.lvl == lvl && e.sum == sum) return e.im;
  std::vector<int> cur(src.px.size()); int w = src.w, h = src.h;
  for (size_t i = 0; i < src.px.size(); i += 4) { const int A = src.px[i + 3]; for (int k = 0; k < 3; k++) { const int v = src.px[i + k] * A + 128; cur[i + size_t(k)] = A == 255 ? src.px[i + k] : (v + (v >> 8)) >> 8; } cur[i + 3] = A; }
  for (int l = 0; l < lvl; l++) {
    const int nw = std::max(1, w / 2), nh = std::max(1, h / 2); std::vector<int> nx(size_t(nw) * nh * 4);
    for (int y = 0; y < nh; y++) for (int x = 0; x < nw; x++) for (int k = 0; k < 4; k++) {
      const int x0 = std::min(w - 1, 2 * x), x1 = std::min(w - 1, 2 * x + 1), y0 = std::min(h - 1, 2 * y), y1 = std::min(h - 1, 2 * y + 1);
      nx[(size_t(y) * nw + x) * 4 + size_t(k)] = (cur[(size_t(y0) * w + x0) * 4 + size_t(k)] + cur[(size_t(y0) * w + x1) * 4 + size_t(k)] + cur[(size_t(y1) * w + x0) * 4 + size_t(k)] + cur[(size_t(y1) * w + x1) * 4 + size_t(k)]) >> 2;
    }
    cur.swap(nx); w = nw; h = nh;
  }
  core::Image im; im.w = w; im.h = h; im.px.resize(cur.size());
  for (size_t i = 0; i < cur.size(); i += 4) { const int A = cur[i + 3]; for (int k = 0; k < 3; k++) im.px[i + size_t(k)] = uint8_t(A == 255 ? cur[i + size_t(k)] : A ? std::min(255, (cur[i + size_t(k)] * 255 + A / 2) / A) : 0); im.px[i + 3] = uint8_t(A); }
  if (cache.size() > 24) cache.erase(cache.begin());
  cache.push_back({src.px.data(), src.w, src.h, lvl, sum, std::move(im)});
  return cache.back().im;
}

void Canvas::drawImage(const core::Image& src, float sx, float sy, float sw, float sh, float dx, float dy, float dw, float dh, float alpha, bool smooth, bool additive) {
  if (alpha <= 0 || dw <= 0 || dh <= 0 || sw <= 0 || sh <= 0 || src.empty()) return;
  // yarıdan çok küçültmede tarayıcı (Chrome görsel önbelleği, MipMapUtil) hedeften küçük olmayan en küçük mip düzeyinden örnekler
  if (smooth && !additive && !src.canvas && sx == 0 && sy == 0 && int(sw) == src.w && int(sh) == src.h) {
    const int tw = int(std::ceil(dw - 1e-4f)), th = int(std::ceil(dh - 1e-4f)); int lvl = 0;
    for (;;) { const int nw = std::max(1, src.w >> (lvl + 1)), nh = std::max(1, src.h >> (lvl + 1)); if (nh < th || nw < tw || ((src.w >> lvl) <= 1 && (src.h >> lvl) <= 1)) break; lvl++; }
    if (lvl > 0) { const core::Image& m = mipLevel(src, lvl); drawImage(m, 0, 0, float(m.w), float(m.h), dx, dy, dw, dh, alpha, true, false); return; }
  }
  const int X0 = std::max(0, int(std::floor(dx))), X1 = std::min(img.w, int(std::ceil(dx + dw))), Y0 = std::max(0, int(std::floor(dy))), Y1 = std::min(img.h, int(std::ceil(dy + dh)));
  const float fx = dw / sw, fy = dh / sh;
  auto at = [&](int x, int y) { x = std::max(int(sx), std::min(int(std::ceil(sx + sw)) - 1, x)); y = std::max(int(sy), std::min(int(std::ceil(sy + sh)) - 1, y)); x = std::max(0, std::min(src.w - 1, x)); y = std::max(0, std::min(src.h - 1, y)); return src.at(x, y); };
  // en yakın komşu (tarayıcının Skia hesabı, SkBitmapProcStateAutoMapper): ters dönüşüm tek duyarlıklı (ölçek S = dw/sw, ters 1/S);
  // satırın ilk pikselinin merkezi eşlenir ve 1/65536 aşağı kaydırılır (tam sayıya düşen örnek küçük olan kaynak pikseline gitsin:
  // 32 → 36 px büyütmede her 9. sütun/satır); kaynak satırı bundan, sütunlar ilk pikselden ters ölçek adımlarıyla toplanarak
  const float Sx = dw / sw, Sy = dh / sh, iSx = 1.f / Sx, iSy = 1.f / Sy;
  const float Tx = dx - sx * Sx, Ty = dy - sy * Sy, iTx = -Tx * iSx, iTy = -Ty * iSy;
  for (int py = Y0; py < Y1; py++) {
    const float cyy = py + 0.5f; if (cyy < dy || cyy >= dy + dh) continue;   // piksel merkezi hedefin içinde mi (tarayıcıdaki gibi)
    int nearX0 = -1; double nearU0 = 0; int nearV = 0;
    if (!smooth) { const float a = cyy * iSy; const float b = a + iTy; nearV = int(std::floor(double(b) - 1.0 / 65536)); }
    // çift doğrusal (Skia'nın eski CPU yolu, SkBitmapProcState "low"): kaynak konumu 16.16 sabit noktada, yarım piksel geri; satır
    // doğrudan, sütunlar ilk pikselden ters ölçek adımlarıyla (32.32); ağırlıklar 4 bit (1/16), renkler önceden çarpılmış, toplam >> 8
    int by0 = 0, by1 = 0, bsy = 0; int64_t bfx = 0; bool bfirst = true;
    const int xmin = std::max(0, int(sx)), xmax = std::min(src.w - 1, int(std::ceil(sx + sw)) - 1), ymin = std::max(0, int(sy)), ymax = std::min(src.h - 1, int(std::ceil(sy + sh)) - 1);
    auto frac = [](float v) { return int64_t(double(v) * 4294967296.0); };   // SkScalarToFractionalInt (sıfıra doğru)
    if (smooth && !additive) {
      const float a = cyy * iSy; const float b = a + iTy; const int32_t f = int32_t((frac(b) - (int64_t(0x8000) << 16)) >> 16);
      by0 = std::max(ymin, std::min(ymax, f >> 16)); bsy = (f >> 12) & 0xF; by1 = std::max(ymin, std::min(ymax, (f + 0x10000) >> 16));
    }
    for (int px = X0; px < X1; px++) {
      const float cxx = px + 0.5f; if (cxx < dx || cxx >= dx + dw) continue;
      // kaynakta karşılığı (çift doğrusal): hedef piksel merkezinden ölçeğe bölerek, tek duyarlıklı
      const float u = sx + (cxx - dx) / fx, v = sy + (cyy - dy) / fy;
      float c[4] = {0, 0, 0, 0};
      if (!smooth) {
        if (nearX0 < 0) { nearX0 = px; const float a = cxx * iSx; const float b = a + iTx; nearU0 = double(b) - 1.0 / 65536; }
        const uint8_t* s = at(int(std::floor(nearU0 + double(px - nearX0) * double(iSx))), nearV); for (int k = 0; k < 4; k++) c[k] = s[k];
      }
      else if (!additive) {
        if (bfirst) { bfirst = false; const float a = cxx * iSx; const float b = a + iTx; bfx = frac(b) - (int64_t(0x8000) << 16); }
        const int32_t f = int32_t(bfx >> 16); bfx += frac(iSx);
        const int bx0 = std::max(xmin, std::min(xmax, f >> 16)), bsx = (f >> 12) & 0xF, bx1 = std::max(xmin, std::min(xmax, (f + 0x10000) >> 16));
        const uint8_t* q[4] = {src.at(bx0, by0), src.at(bx1, by0), src.at(bx0, by1), src.at(bx1, by1)};
        const int xy = bsx * bsy, w[4] = {256 - 16 * bsy - 16 * bsx + xy, 16 * bsx - xy, 16 * bsy - xy, xy};
        int sum[4] = {0, 0, 0, 0};
        for (int j = 0; j < 4; j++) { const int A = q[j][3]; for (int k = 0; k < 3; k++) { const int pm = A == 255 ? q[j][k] : (q[j][k] * A + 128 + ((q[j][k] * A + 128) >> 8)) >> 8; sum[k] += pm * w[j]; } sum[3] += A * w[j]; }
        int pc[4]; for (int k = 0; k < 4; k++) pc[k] = sum[k] >> 8;   // önceden çarpılmış sonuç
        float cov = 1; if (clipR_ || clipC_) cov = clipCov(px, py);
        const int A8 = int(std::lround(std::min(1.f, alpha * cov) * 255));
        if (A8 < 255) { const int sc = A8 + 1; for (int k = 0; k < 4; k++) pc[k] = (pc[k] * sc) >> 8; }
        if (pc[3] <= 0 && pc[0] + pc[1] + pc[2] == 0) continue;
        uint8_t* d = img.at(px, py); const int inv = 256 - pc[3];   // kaynak üstte (SkAlphaMulQ)
        for (int k = 0; k < 3; k++) d[k] = uint8_t(std::min(255, pc[k] + ((d[k] * inv) >> 8)));
        d[3] = 255; continue;
      }
      else {   // ışık (lighter) olarak çift doğrusal: kayan noktalı, önceden çarpılmış alfa ile
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
