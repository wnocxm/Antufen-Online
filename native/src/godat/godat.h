// godat arşivleri: orijinal Symbian/APK biçimi (sy2dr2.6 / GODAT2.5) ve bizim şifreli paket biçimimiz (GODAT3.0).
// Ayrıntılı biçim: docs/09-cpp.md › godat. Python karşılığı: tools/godat.py (eşitlik testi: tools/test/godat_esitlik.py).
#pragma once
#include <array>
#include <cstdint>
#include <stdexcept>
#include <string>
#include <vector>

namespace godat {

using Bytes = std::vector<uint8_t>;

// Okuma/yazma hataları (dosya yok, bozuk başlık, yanlış anahtar, kayıt bozulmuş …)
struct Error : std::runtime_error { using std::runtime_error::runtime_error; };

// 32 baytlık şifreleme anahtarı. Yayın anahtarı depoda durmaz (native/anahtar.txt, git dışı); yoksa geliştirme anahtarı kullanılır.
using Key = std::array<uint8_t, 32>;
const Key& defaultKey();
bool isDevKey();

// Arşivdeki bir kayıt: numara, ad (orijinalde bayt dizisi; çoğu boş) ve dosyadaki yeri
struct Entry {
  uint32_t id = 0;
  std::string name;          // ham baytlar (orijinal dosyada latin1 gibi okunur)
  uint64_t offset = 0;       // verinin dosyadaki başlangıcı
  uint64_t size = 0;         // dosyada kapladığı bayt
  uint64_t rawSize = 0;      // açılmış boy (yalnız GODAT3.0)
  uint32_t crc = 0;          // açılmış verinin CRC32'si (yalnız GODAT3.0)
};

enum class Format { Original, Packed };

class Archive {
 public:
  static Archive open(const std::string& path, const Key& key = defaultKey());
  static Archive fromMemory(Bytes bytes, const std::string& label, const Key& key = defaultKey());

  Format format() const { return format_; }
  const std::string& signature() const { return signature_; }
  const std::vector<Entry>& entries() const { return entries_; }
  const Entry* find(uint32_t id) const;   // aynı numara birden çoksa sonuncusu (yama kuralı)
  const Entry* findName(const std::string& name) const;

  Bytes stored(const Entry& e) const;     // dosyada duran baytlar (orijinalde sıkıştırılmış olabilir)
  Bytes data(const Entry& e) const;       // oyunun kullandığı açılmış içerik
  Bytes data(uint32_t id) const;

 private:
  Format format_ = Format::Original;
  std::string label_, signature_;
  Bytes bytes_;
  std::vector<Entry> entries_;
  Key key_{};
  uint8_t salt_[12] = {};
  uint32_t flags_ = 0;       // GODAT3.0 bayrakları (1 şifreli, 2 zlib)
  void parseOriginal();
  void parsePacked();
};

// Orijinal kaydın içeriğini aç: [tür=1, parça sayısı, sıkıştırılmış boy, ham boy] + zlib parçaları; değilse olduğu gibi döner
Bytes unpackOriginal(const Bytes& stored);

// Paket yazıcı: kayıtlar sırayla eklenir; aynı numara sonradan eklenirse eskisinin yerine geçer (katmanlı yama)
struct PackRecord { uint32_t id; std::string name; Bytes data; };
class Packer {
 public:
  void add(uint32_t id, const std::string& name, Bytes data);
  void addArchive(const Archive& a);      // bir arşivin bütün kayıtlarını (açılmış hâliyle) ekler
  void addFile(const std::string& name, Bytes data);   // veri paketi: numara = pathId(ad); başka ada ait numara çakışırsa hata
  size_t size() const { return records_.size(); }
  const std::vector<PackRecord>& records() const { return records_; }
  // encrypt=false: yalnız sıkıştırma (hata ayıklama için); salt: test için sabit tuz verilebilir
  Bytes build(const Key& key = defaultKey(), bool encrypt = true, const uint8_t* salt = nullptr) const;
  void save(const std::string& path, const Key& key = defaultKey(), bool encrypt = true) const;
 private:
  std::vector<PackRecord> records_;
};

// Dosya yolundan kayıt numarası (FNV-1a 32): veri paketlerinde her dosya bir kayıttır, adı yolu, numarası bu
uint32_t pathId(const std::string& path);

Bytes readFile(const std::string& path);
void writeFile(const std::string& path, const Bytes& b);
uint32_t crc32(const Bytes& b);

}  // namespace godat
