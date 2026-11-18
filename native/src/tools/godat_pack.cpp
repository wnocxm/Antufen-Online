// godat_pack: godat arşivlerini ya da bir klasördeki dosyaları tek bir şifreli GODAT3.0 paketine yazar.
//   godat_pack [--sifresiz] -o <çıktı> <taban.godat> [yama1.godat …]      arşivler (orijinal ya da GODAT3.0), katmanlı yama
//   godat_pack [--sifresiz] -o <çıktı> --dizin <klasör> [--onek <ön ek>]   veri paketi: her dosya bir kayıt (adı = göreli yol)
// Aynı numaralı kayıt sonradan gelen arşivde varsa onun yerine geçer.
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <filesystem>
#include <string>
#include <vector>

#include "godat/godat.h"

namespace fs = std::filesystem;

int main(int argc, char** argv) {
  std::string out, dir, prefix; bool encrypt = true; std::vector<std::string> in;
  for (int i = 1; i < argc; i++) {
    if (!std::strcmp(argv[i], "-o") && i + 1 < argc) out = argv[++i];
    else if (!std::strcmp(argv[i], "--sifresiz")) encrypt = false;
    else if (!std::strcmp(argv[i], "--dizin") && i + 1 < argc) dir = argv[++i];
    else if (!std::strcmp(argv[i], "--onek") && i + 1 < argc) prefix = argv[++i];
    else in.push_back(argv[i]);
  }
  if (out.empty() || (in.empty() && dir.empty())) {
    std::fprintf(stderr, "kullanım: godat_pack [--sifresiz] -o <çıktı> <taban> [yama …]\n"
                         "          godat_pack [--sifresiz] -o <çıktı> --dizin <klasör> [--onek <ön ek>]\n");
    return 2;
  }
  try {
    godat::Packer p;
    for (const std::string& f : in) {
      size_t before = p.size();
      godat::Archive a = godat::Archive::open(f);
      p.addArchive(a);
      std::printf("%s: %zu kayıt (%zu yeni)\n", f.c_str(), a.entries().size(), p.size() - before);
    }
    if (!dir.empty()) {
      std::vector<fs::path> files;
      for (const auto& e : fs::recursive_directory_iterator(dir)) if (e.is_regular_file()) files.push_back(e.path());
      std::sort(files.begin(), files.end());   // aynı girdiden hep aynı paket
      for (const fs::path& f : files) p.addFile(prefix + fs::relative(f, dir).generic_string(), godat::readFile(f.string()));
      std::printf("%s: %zu dosya\n", dir.c_str(), files.size());
    }
    p.save(out, godat::defaultKey(), encrypt);
    std::printf("%s yazıldı: %zu kayıt%s%s\n", out.c_str(), p.size(), encrypt ? ", şifreli" : ", şifresiz",
                godat::isDevKey() && encrypt ? " (GELİŞTİRME anahtarı)" : "");
  } catch (const std::exception& e) {
    std::fprintf(stderr, "HATA: %s\n", e.what());
    return 1;
  }
  return 0;
}
