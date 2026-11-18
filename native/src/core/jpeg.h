// JPEG okuma (ek kütüphane yok): taban (baseline) ve genişletilmiş sıralı Huffman, 8 bit, gri ya da YCbCr, her örnekleme; yeniden
// başlatma işaretleri. Sonuç tarayıcıdaki (libjpeg-turbo) ile birebir: tam sayı ters DCT (jidctint "islow"), "fancy" renk büyütme
// (jdsample h2v2/h2v1), aynı sabit noktalı renk dönüşümü (jdcolor). İlerlemeli (progressive) JPEG desteklenmez (oyunda yok).
#pragma once
#include <cstdint>
#include <vector>

#include "core/png.h"

namespace core {

// Hata olursa std::runtime_error. Sonuç RGBA (saydamlık 255).
Image decodeJPEG(const std::vector<uint8_t>& file);
inline bool isJPEG(const std::vector<uint8_t>& f) { return f.size() > 3 && f[0] == 0xFF && f[1] == 0xD8 && f[2] == 0xFF; }

}  // namespace core
