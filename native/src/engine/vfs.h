// Sanal dosya sistemi: oyun verisini bir klasörden (geliştirme: www/assets) ya da şifreli GODAT3.0 veri paketlerinden okur.
// Sonra bağlanan kaynak öncekinin üstündedir (yama: aynı yoldaki dosya yenisiyle değişir).
#pragma once
#include <memory>
#include <string>
#include <vector>

#include "godat/godat.h"

namespace engine {

class Vfs {
 public:
  void mountDir(const std::string& dir);
  void mountPack(const std::string& path);
  bool exists(const std::string& path) const;
  godat::Bytes read(const std::string& path) const;      // yoksa godat::Error
  std::string readText(const std::string& path) const;
  std::string describe() const;                          // bağlı kaynakların listesi

 private:
  struct Source { std::string dir; std::shared_ptr<godat::Archive> pack; };
  std::vector<Source> sources_;
};

}  // namespace engine
