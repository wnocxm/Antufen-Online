// PNG okuma/yazma (zlib ile; ek kütüphane yok). Okuma: 8 bit, taramasız (non-interlaced) gri, gri+alfa, RGB, RGBA, paletli.
// Oyunun görsel sayfaları gri+alfa (gri = palet numarası), arayüz görselleri RGBA'dır.
#pragma once
#include <cstdint>
#include <string>
#include <vector>

namespace core {

// RGBA, satır satır (her piksel 4 bayt)
struct Image {
  int w = 0, h = 0;
  std::vector<uint8_t> px;
  uint8_t* at(int x, int y) { return &px[(size_t(y) * w + x) * 4]; }
  const uint8_t* at(int x, int y) const { return &px[(size_t(y) * w + x) * 4]; }
  bool empty() const { return w == 0 || h == 0; }
};

// Hata olursa std::runtime_error. Gri+alfa görsel RGBA'ya r = g = b = gri olarak açılır.
Image decodePNG(const std::vector<uint8_t>& file);
std::vector<uint8_t> encodePNG(const Image& im);

}  // namespace core
