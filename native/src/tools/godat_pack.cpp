// godat_pack: bir ya da birkaç godat arşivini tek bir şifreli GODAT3.0 paketine yazar.
//   godat_pack [--sifresiz] -o <çıktı> <taban.godat> [yama1.godat yama2.godat …]
// Arşivler sırayla eklenir; aynı numaralı kayıt sonradan gelen arşivde varsa onun yerine geçer (katmanlı yama).
// Girdiler orijinal godat ya da daha önce üretilmiş GODAT3.0 paketleri olabilir.
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

#include "godat/godat.h"

int main(int argc, char** argv) {
  std::string out; bool encrypt = true; std::vector<std::string> in;
  for (int i = 1; i < argc; i++) {
    if (!std::strcmp(argv[i], "-o") && i + 1 < argc) out = argv[++i];
    else if (!std::strcmp(argv[i], "--sifresiz")) encrypt = false;
    else in.push_back(argv[i]);
  }
  if (out.empty() || in.empty()) { std::fprintf(stderr, "kullanım: godat_pack [--sifresiz] -o <çıktı> <taban> [yama …]\n"); return 2; }
  try {
    godat::Packer p;
    for (const std::string& f : in) {
      size_t before = p.size();
      godat::Archive a = godat::Archive::open(f);
      p.addArchive(a);
      std::printf("%s: %zu kayıt (%zu yeni)\n", f.c_str(), a.entries().size(), p.size() - before);
    }
    p.save(out, godat::defaultKey(), encrypt);
    std::printf("%s yazıldı: %zu kayıt%s%s\n", out.c_str(), p.size(), encrypt ? ", şifreli" : ", şifresiz",
                godat::isDevKey() && encrypt ? " (GELİŞTİRME anahtarı)" : "");
  } catch (const godat::Error& e) {
    std::fprintf(stderr, "HATA: %s\n", e.what());
    return 1;
  }
  return 0;
}
