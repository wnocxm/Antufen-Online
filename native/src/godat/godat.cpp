#include "godat.h"

#include <zlib.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <random>

#include "chacha20.h"

namespace godat {

// ---------------- yardımcılar ----------------
static uint32_t le32(const uint8_t* p) { return p[0] | (p[1] << 8) | (p[2] << 16) | (uint32_t(p[3]) << 24); }
static uint16_t le16(const uint8_t* p) { return uint16_t(p[0] | (p[1] << 8)); }
static void put32(Bytes& b, uint32_t v) { for (int i = 0; i < 4; i++) b.push_back(uint8_t(v >> (8 * i))); }
static void put16(Bytes& b, uint16_t v) { b.push_back(uint8_t(v)); b.push_back(uint8_t(v >> 8)); }

Bytes readFile(const std::string& path) {
  FILE* f = std::fopen(path.c_str(), "rb");
  if (!f) throw Error("dosya açılamadı: " + path);
  Bytes b; uint8_t buf[1 << 16]; size_t n;
  while ((n = std::fread(buf, 1, sizeof buf, f)) > 0) b.insert(b.end(), buf, buf + n);
  std::fclose(f);
  return b;
}

void writeFile(const std::string& path, const Bytes& b) {
  FILE* f = std::fopen(path.c_str(), "wb");
  if (!f) throw Error("dosya yazılamadı: " + path);
  bool ok = std::fwrite(b.data(), 1, b.size(), f) == b.size();
  ok = (std::fclose(f) == 0) && ok;
  if (!ok) throw Error("dosya yazılamadı: " + path);
}

uint32_t crc32(const Bytes& b) { return uint32_t(::crc32(0L, b.data(), uInt(b.size()))); }

// Tek bir zlib akışını sonuna kadar açar; akış bitmeden veri biterse hata (Python zlib.decompress gibi: akıştan sonraki fazla bayt yok sayılır)
static bool inflateStream(const uint8_t* src, size_t len, Bytes& out) {
  z_stream z{}; if (inflateInit(&z) != Z_OK) return false;
  z.next_in = const_cast<uint8_t*>(src); z.avail_in = uInt(len);
  uint8_t buf[1 << 15]; int r;
  do {
    z.next_out = buf; z.avail_out = sizeof buf;
    r = inflate(&z, Z_NO_FLUSH);
    if (r != Z_OK && r != Z_STREAM_END) { inflateEnd(&z); return false; }
    out.insert(out.end(), buf, buf + (sizeof buf - z.avail_out));
    if (r == Z_OK && z.avail_in == 0 && z.avail_out != 0) { inflateEnd(&z); return false; }   // girdi bitti, akış bitmedi
  } while (r != Z_STREAM_END);
  inflateEnd(&z);
  return true;
}

// ---------------- anahtar ----------------
// Geliştirme anahtarı (herkese açık; yalnız testler ve yerel derleme için). Yayın derlemesi native/anahtar.txt'den
// CMake ile üretilen GODAT_RELEASE_KEY'i kullanır (dosya git dışıdır; docs/09-cpp.md › Anahtar).
#ifdef GODAT_RELEASE_KEY
static const Key kKey = {GODAT_RELEASE_KEY};
static const bool kDev = false;
#else
static const Key kKey = {0x41, 0x6e, 0x72, 0x75, 0x66, 0x65, 0x6e, 0x2d, 0x67, 0x65, 0x6c, 0x69, 0x73, 0x74, 0x69, 0x72,
                         0x6d, 0x65, 0x2d, 0x61, 0x6e, 0x61, 0x68, 0x74, 0x61, 0x72, 0x69, 0x2d, 0x30, 0x30, 0x30, 0x31};   // "Anrufen-gelistirme-anahtari-0001"
static const bool kDev = true;
#endif
const Key& defaultKey() { return kKey; }
bool isDevKey() { return kDev; }

// ---------------- orijinal kayıt içeriği ----------------
Bytes unpackOriginal(const Bytes& r) {
  if (r.size() >= 16) {
    uint32_t t = le32(&r[0]), n = le32(&r[4]), cs = le32(&r[8]);
    if (t == 1 && 16ull + cs <= r.size()) {
      Bytes out;
      if (inflateStream(&r[16], cs, out)) {
        size_t p = 16ull + cs; bool ok = true;
        for (uint32_t k = 1; ok && k < n; k++) {   // sonraki parçalar: [sıkıştırılmış boy, ham boy] + zlib
          if (p + 8 > r.size()) { ok = false; break; }
          uint32_t c2 = le32(&r[p]); p += 8;
          size_t take = std::min<size_t>(c2, r.size() - p);
          ok = inflateStream(&r[p], take, out); p += c2;
        }
        if (ok) return out;
      }
    }
  }
  return r;   // sıkıştırılmamış kayıt (ya da açılamayan): olduğu gibi
}

// ---------------- arşiv okuma ----------------
static const char* kPackSig = "GODAT3.0";
enum : uint32_t { kEncrypted = 1, kCompressed = 2 };
static const uint8_t kDirCheck[4] = {'D', 'I', 'R', '1'};

Archive Archive::open(const std::string& path, const Key& key) { return fromMemory(readFile(path), path, key); }

Archive Archive::fromMemory(Bytes bytes, const std::string& label, const Key& key) {
  Archive a; a.bytes_ = std::move(bytes); a.label_ = label; a.key_ = key;
  if (a.bytes_.size() < 8) throw Error("godat değil (çok kısa): " + label);
  a.signature_.assign(reinterpret_cast<const char*>(a.bytes_.data()), 8);
  if (a.signature_ == kPackSig) { a.format_ = Format::Packed; a.parsePacked(); }
  else if (a.signature_ == "sy2dr2.6" || a.signature_ == "GODAT2.5" || a.signature_ == std::string(8, '\0')) { a.format_ = Format::Original; a.parseOriginal(); }
  else throw Error("godat değil (imza tanınmadı): " + label);
  return a;
}

// Orijinal: [0,8) imza · [8,15) sıfır · [15,19) kayıt sayısı · [19,23) dizin boyu (sayı × 12) · sonra her kayıt için
// numara, konum, ad uzunluğu (u32) + ad. Dizin konuma göre sıralı değildir; kaydın sonu = dosyadaki bir sonraki başlangıç.
void Archive::parseOriginal() {
  const Bytes& b = bytes_;
  if (b.size() < 23) throw Error("bozuk başlık: " + label_);
  uint32_t n = le32(&b[15]); size_t p = 23;
  std::vector<uint64_t> offs;
  for (uint32_t i = 0; i < n; i++) {
    if (p + 12 > b.size()) throw Error("bozuk dizin: " + label_);
    Entry e; e.id = le32(&b[p]); e.offset = le32(&b[p + 4]); uint32_t nl = le32(&b[p + 8]); p += 12;
    if (p + nl > b.size()) throw Error("bozuk ad: " + label_);
    e.name.assign(reinterpret_cast<const char*>(&b[p]), nl); p += nl;
    entries_.push_back(e); offs.push_back(e.offset);
  }
  std::sort(offs.begin(), offs.end()); offs.erase(std::unique(offs.begin(), offs.end()), offs.end()); offs.push_back(b.size());
  for (Entry& e : entries_) {
    uint64_t end = *std::upper_bound(offs.begin(), offs.end() - 1, e.offset);   // bir sonraki başlangıç ya da dosya sonu
    if (e.offset >= end || e.offset > b.size()) { e.size = 0; continue; }
    e.size = std::min<uint64_t>(end, b.size()) - e.offset;
  }
}

// GODAT3.0: [0,8) imza · [8,12) bayraklar (1 şifreli, 2 zlib) · [12,16) kayıt sayısı · [16,28) tuz · [28,32) dizin boyu ·
// dizin ("DIR1" + kayıt başına numara, konum, boy, ham boy, CRC32 (u32) + ad uzunluğu (u16) + ad; şifreli) · veri bölgesi
void Archive::parsePacked() {
  Bytes& b = bytes_;
  if (b.size() < 32) throw Error("bozuk paket başlığı: " + label_);
  uint32_t n = le32(&b[12]), ds = le32(&b[28]); flags_ = le32(&b[8]);
  std::memcpy(salt_, &b[16], 12);
  if (32ull + ds > b.size()) throw Error("bozuk paket dizini: " + label_);
  Bytes dir(b.begin() + 32, b.begin() + 32 + ds);
  if (flags_ & kEncrypted) chacha20(key_.data(), salt_, 0, dir.data(), dir.size());
  if (dir.size() < 4 || std::memcmp(dir.data(), kDirCheck, 4) != 0) throw Error("paket açılamadı (anahtar yanlış ya da dosya bozuk): " + label_);
  size_t p = 4; const uint64_t base = 32ull + ds;
  for (uint32_t i = 0; i < n; i++) {
    if (p + 22 > dir.size()) throw Error("bozuk paket dizini: " + label_);
    Entry e; e.id = le32(&dir[p]); e.offset = base + le32(&dir[p + 4]); e.size = le32(&dir[p + 8]);
    e.rawSize = le32(&dir[p + 12]); e.crc = le32(&dir[p + 16]); uint16_t nl = le16(&dir[p + 20]); p += 22;
    if (p + nl > dir.size() || e.offset + e.size > b.size()) throw Error("bozuk paket dizini: " + label_);
    e.name.assign(reinterpret_cast<const char*>(&dir[p]), nl); p += nl;
    entries_.push_back(e);
  }
}

const Entry* Archive::find(uint32_t id) const {
  for (auto it = entries_.rbegin(); it != entries_.rend(); ++it) if (it->id == id) return &*it;
  return nullptr;
}

Bytes Archive::stored(const Entry& e) const { return Bytes(bytes_.begin() + e.offset, bytes_.begin() + e.offset + e.size); }

// kaydın nonce'u: tuz, ilk 4 baytı numarayla XOR, 9. baytı 1 ile XOR (dizinin nonce'uyla hiç çakışmaz)
static void recordNonce(const uint8_t salt[12], uint32_t id, uint8_t out[12]) {
  std::memcpy(out, salt, 12);
  for (int i = 0; i < 4; i++) out[i] ^= uint8_t(id >> (8 * i));
  out[8] ^= 1;
}

Bytes Archive::data(const Entry& e) const {
  Bytes s = stored(e);
  if (format_ == Format::Original) return unpackOriginal(s);
  if (flags_ & kEncrypted) { uint8_t nonce[12]; recordNonce(salt_, e.id, nonce); chacha20(key_.data(), nonce, 0, s.data(), s.size()); }
  Bytes out;
  if (flags_ & kCompressed) {
    out.resize(e.rawSize); uLongf len = uLongf(e.rawSize);
    if (uncompress(out.data(), &len, s.data(), uLong(s.size())) != Z_OK || len != e.rawSize) throw Error("kayıt bozuk (açılamadı): " + label_ + " #" + std::to_string(e.id));
  } else out = std::move(s);
  if (out.size() != e.rawSize || crc32(out) != e.crc) throw Error("kayıt bozuk (CRC tutmuyor): " + label_ + " #" + std::to_string(e.id));
  return out;
}

Bytes Archive::data(uint32_t id) const {
  const Entry* e = find(id);
  if (!e) throw Error("kayıt yok: " + label_ + " #" + std::to_string(id));
  return data(*e);
}

// ---------------- paket yazma ----------------
void Packer::add(uint32_t id, const std::string& name, Bytes data) {
  for (PackRecord& r : records_) if (r.id == id) { r.name = name; r.data = std::move(data); return; }   // yama: aynı numaranın yerine geçer
  records_.push_back({id, name, std::move(data)});
}

void Packer::addArchive(const Archive& a) { for (const Entry& e : a.entries()) add(e.id, e.name, a.data(e)); }

Bytes Packer::build(const Key& key, bool encrypt, const uint8_t* saltIn) const {
  uint8_t salt[12];
  if (saltIn) std::memcpy(salt, saltIn, 12);
  else { std::random_device rd; for (uint8_t& s : salt) s = uint8_t(rd()); }
  const uint32_t flags = (encrypt ? uint32_t(kEncrypted) : 0u) | uint32_t(kCompressed);
  Bytes dir(kDirCheck, kDirCheck + 4), body;
  for (const PackRecord& r : records_) {
    uLongf cl = compressBound(uLong(r.data.size())); Bytes z(cl);
    if (compress2(z.data(), &cl, r.data.data(), uLong(r.data.size()), 9) != Z_OK) throw Error("sıkıştırılamadı #" + std::to_string(r.id));
    z.resize(cl);
    if (encrypt) { uint8_t nonce[12]; recordNonce(salt, r.id, nonce); chacha20(key.data(), nonce, 0, z.data(), z.size()); }
    if (r.name.size() > 0xffff || body.size() > 0xffffffffull) throw Error("paket çok büyük");
    put32(dir, r.id); put32(dir, uint32_t(body.size())); put32(dir, uint32_t(z.size())); put32(dir, uint32_t(r.data.size()));
    put32(dir, crc32(r.data)); put16(dir, uint16_t(r.name.size())); dir.insert(dir.end(), r.name.begin(), r.name.end());
    body.insert(body.end(), z.begin(), z.end());
  }
  if (encrypt) chacha20(key.data(), salt, 0, dir.data(), dir.size());
  Bytes out(kPackSig, kPackSig + 8);
  put32(out, flags); put32(out, uint32_t(records_.size())); out.insert(out.end(), salt, salt + 12); put32(out, uint32_t(dir.size()));
  out.insert(out.end(), dir.begin(), dir.end()); out.insert(out.end(), body.begin(), body.end());
  return out;
}

void Packer::save(const std::string& path, const Key& key, bool encrypt) const { writeFile(path, build(key, encrypt)); }

}  // namespace godat
