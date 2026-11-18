// godat_dump: bir godat arşivinin içeriğini yazar (orijinal ya da GODAT3.0 paket).
//   godat_dump <dosya>              → özet: her kayıt için numara, ad (onaltılık), açılmış boy, CRC32
//   godat_dump <dosya> <numara> <çıktı>  → o kaydın açılmış içeriğini dosyaya yazar
// Özet biçimi tools/godat_ozet.py ile aynıdır; eşitlik testi: tools/test/godat_esitlik.py
#include <cinttypes>
#include <cstdio>
#include <cstdlib>

#include "godat/godat.h"

static std::string hex(const std::string& s) {
  static const char* d = "0123456789abcdef"; std::string o;
  for (unsigned char c : s) { o += d[c >> 4]; o += d[c & 15]; }
  return o;
}

int main(int argc, char** argv) {
  if (argc != 2 && argc != 4) { std::fprintf(stderr, "kullanım: godat_dump <dosya> [numara çıktı]\n"); return 2; }
  try {
    godat::Archive a = godat::Archive::open(argv[1]);
    if (argc == 4) { godat::writeFile(argv[3], a.data(uint32_t(std::strtoul(argv[2], nullptr, 10)))); return 0; }
    std::printf("kayıt\t%zu\n", a.entries().size());
    for (const godat::Entry& e : a.entries()) {
      godat::Bytes d = a.data(e);
      std::printf("%" PRIu32 "\t%s\t%zu\t%08" PRIx32 "\n", e.id, hex(e.name).c_str(), d.size(), godat::crc32(d));
    }
  } catch (const godat::Error& e) {
    std::fprintf(stderr, "HATA: %s\n", e.what());
    return 1;
  }
  return 0;
}
