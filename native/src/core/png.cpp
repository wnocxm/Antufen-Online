#include "png.h"

#include <zlib.h>

#include <cstdlib>
#include <cstring>
#include <stdexcept>

namespace core {

static uint32_t be32(const uint8_t* p) { return (uint32_t(p[0]) << 24) | (p[1] << 16) | (p[2] << 8) | p[3]; }

Image decodePNG(const std::vector<uint8_t>& d) {
  static const uint8_t sig[8] = {137, 80, 78, 71, 13, 10, 26, 10};
  if (d.size() < 8 || std::memcmp(d.data(), sig, 8)) throw std::runtime_error("PNG değil");
  Image im; int type = -1, depth = 0; std::vector<uint8_t> idat, plte, trns; size_t i = 8;
  while (i + 8 <= d.size()) {
    uint32_t len = be32(&d[i]); std::string t(reinterpret_cast<const char*>(&d[i + 4]), 4); const uint8_t* c = &d[i + 8];
    if (i + 12 + len > d.size()) throw std::runtime_error("PNG kesik");
    if (t == "IHDR") { im.w = int(be32(c)); im.h = int(be32(c + 4)); depth = c[8]; type = c[9]; if (c[12]) throw std::runtime_error("taramalı PNG desteklenmiyor"); }
    else if (t == "PLTE") plte.assign(c, c + len);
    else if (t == "tRNS") trns.assign(c, c + len);
    else if (t == "IDAT") idat.insert(idat.end(), c, c + len);
    else if (t == "IEND") break;
    i += 12 + len;
  }
  if (depth != 8) throw std::runtime_error("yalnız 8 bit PNG");
  int ch = type == 0 ? 1 : type == 2 ? 3 : type == 3 ? 1 : type == 4 ? 2 : type == 6 ? 4 : 0;
  if (!ch) throw std::runtime_error("PNG renk türü desteklenmiyor");
  const size_t stride = size_t(im.w) * ch;
  std::vector<uint8_t> raw(size_t(im.h) * (stride + 1)); uLongf rl = uLongf(raw.size());
  if (uncompress(raw.data(), &rl, idat.data(), uLong(idat.size())) != Z_OK || rl != raw.size()) throw std::runtime_error("PNG açılamadı");
  // satır süzgeçlerini geri al (0 yok, 1 sol, 2 üst, 3 ortalama, 4 Paeth)
  std::vector<uint8_t> pix(size_t(im.h) * stride);
  for (int y = 0; y < im.h; y++) {
    const uint8_t ft = raw[y * (stride + 1)], *s = &raw[y * (stride + 1) + 1];
    uint8_t* o = &pix[y * stride]; const uint8_t* up = y ? o - stride : nullptr;
    for (size_t x = 0; x < stride; x++) {
      int a = x >= size_t(ch) ? o[x - ch] : 0, b = up ? up[x] : 0, cc = (up && x >= size_t(ch)) ? up[x - ch] : 0, v = s[x];
      switch (ft) {
        case 1: v += a; break; case 2: v += b; break; case 3: v += (a + b) / 2; break;
        case 4: { int p = a + b - cc, pa = std::abs(p - a), pb = std::abs(p - b), pc = std::abs(p - cc); v += (pa <= pb && pa <= pc) ? a : pb <= pc ? b : cc; } break;
      }
      o[x] = uint8_t(v);
    }
  }
  im.px.resize(size_t(im.w) * im.h * 4);
  for (size_t k = 0, n = size_t(im.w) * im.h; k < n; k++) {
    const uint8_t* s = &pix[k * ch]; uint8_t* o = &im.px[k * 4];
    switch (type) {
      case 0: o[0] = o[1] = o[2] = s[0]; o[3] = 255; break;
      case 2: o[0] = s[0]; o[1] = s[1]; o[2] = s[2]; o[3] = 255; break;
      case 3: { size_t q = s[0]; o[0] = q * 3 + 2 < plte.size() ? plte[q * 3] : 0; o[1] = q * 3 + 2 < plte.size() ? plte[q * 3 + 1] : 0;
                o[2] = q * 3 + 2 < plte.size() ? plte[q * 3 + 2] : 0; o[3] = q < trns.size() ? trns[q] : 255; } break;
      case 4: o[0] = o[1] = o[2] = s[0]; o[3] = s[1]; break;
      case 6: std::memcpy(o, s, 4); break;
    }
  }
  return im;
}

std::vector<uint8_t> encodePNG(const Image& im) {
  std::vector<uint8_t> raw; raw.reserve(size_t(im.h) * (im.w * 4 + 1));
  for (int y = 0; y < im.h; y++) { raw.push_back(0); raw.insert(raw.end(), im.at(0, y), im.at(0, y) + im.w * 4); }
  uLongf cl = compressBound(uLong(raw.size())); std::vector<uint8_t> z(cl);
  compress2(z.data(), &cl, raw.data(), uLong(raw.size()), 6); z.resize(cl);
  std::vector<uint8_t> out = {137, 80, 78, 71, 13, 10, 26, 10};
  auto chunk = [&](const char* t, const std::vector<uint8_t>& c) {
    for (int k = 3; k >= 0; k--) out.push_back(uint8_t(c.size() >> (8 * k)));
    size_t st = out.size(); out.insert(out.end(), t, t + 4); out.insert(out.end(), c.begin(), c.end());
    uint32_t crc = uint32_t(::crc32(0L, &out[st], uInt(out.size() - st)));
    for (int k = 3; k >= 0; k--) out.push_back(uint8_t(crc >> (8 * k)));
  };
  std::vector<uint8_t> h;
  for (int v : {im.w, im.h}) for (int k = 3; k >= 0; k--) h.push_back(uint8_t(uint32_t(v) >> (8 * k)));
  h.insert(h.end(), {8, 6, 0, 0, 0});
  chunk("IHDR", h); chunk("IDAT", z); chunk("IEND", {});
  return out;
}

}  // namespace core
