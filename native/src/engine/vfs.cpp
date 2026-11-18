#include "vfs.h"

#include <filesystem>

namespace engine {

void Vfs::mountDir(const std::string& dir) {
  if (!std::filesystem::is_directory(dir)) throw godat::Error("klasör yok: " + dir);
  sources_.push_back({dir, nullptr});
}

void Vfs::mountPack(const std::string& path) {
  sources_.push_back({"", std::make_shared<godat::Archive>(godat::Archive::open(path))});
}

bool Vfs::exists(const std::string& path) const {
  for (auto it = sources_.rbegin(); it != sources_.rend(); ++it) {
    if (it->pack) { if (it->pack->find(godat::pathId(path)) && it->pack->findName(path)) return true; }
    else if (std::filesystem::is_regular_file(it->dir + "/" + path)) return true;
  }
  return false;
}

godat::Bytes Vfs::read(const std::string& path) const {
  for (auto it = sources_.rbegin(); it != sources_.rend(); ++it) {
    if (it->pack) {
      const godat::Entry* e = it->pack->find(godat::pathId(path));
      if (e && e->name == path) return it->pack->data(*e);
    } else {
      const std::string f = it->dir + "/" + path;
      if (std::filesystem::is_regular_file(f)) return godat::readFile(f);
    }
  }
  throw godat::Error("veri dosyası yok: " + path);
}

std::string Vfs::readText(const std::string& path) const {
  godat::Bytes b = read(path);
  return std::string(b.begin(), b.end());
}

std::string Vfs::describe() const {
  std::string s;
  for (const Source& x : sources_) s += (s.empty() ? "" : ", ") + (x.pack ? std::string("paket(") + std::to_string(x.pack->entries().size()) + ")" : x.dir);
  return s;
}

}  // namespace engine
