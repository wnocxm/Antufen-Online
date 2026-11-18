// godat kütüphanesi birim testleri:  ctest (native/build içinde) ya da doğrudan ./test_godat
// 1) ChaCha20: RFC 8439 2.4.2 resmî örneği. 2) Paket gidiş-dönüş (şifreli ve şifresiz). 3) Katmanlı yama.
// 4) Bozuk veri ve yanlış anahtar yakalanır. 5) Orijinal kayıt açma (çok parçalı zlib, açılamayan kayıt olduğu gibi döner).
#include <zlib.h>

#include <cstdio>
#include <cstring>
#include <string>

#include "godat/chacha20.h"
#include "godat/godat.h"

static int failed = 0, passed = 0;
#define CHECK(cond, what) do { if (cond) { passed++; } else { failed++; std::printf("KALDI: %s (%s:%d)\n", what, __FILE__, __LINE__); } } while (0)

using godat::Bytes;
static Bytes str(const std::string& s) { return Bytes(s.begin(), s.end()); }
static Bytes fromHex(const char* h) { Bytes b; for (size_t i = 0; h[i] && h[i + 1]; i += 2) b.push_back(uint8_t(std::stoi(std::string(h + i, 2), nullptr, 16))); return b; }
template <class F> static bool throws(F f) { try { f(); } catch (const godat::Error&) { return true; } return false; }

static void testChacha() {
  uint8_t key[32]; for (int i = 0; i < 32; i++) key[i] = uint8_t(i);
  Bytes nonce = fromHex("000000000000004a00000000");
  Bytes msg = str("Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.");
  Bytes want = fromHex("6e2e359a2568f98041ba0728dd0d6981e97e7aec1d4360c20a27afccfd9fae0bf91b65c5524733ab8f593dabcd62b3571639d624e65152ab8f530c"
                       "359f0861d807ca0dbf500d6a6156a38e088a22b65e52bc514d16ccf806818ce91ab77937365af90bbf74a35be6b40b8eedf2785e42874d");
  Bytes c = msg; godat::chacha20(key, nonce.data(), 1, c.data(), c.size());
  CHECK(c == want, "ChaCha20 RFC 8439 2.4.2 şifreli metin");
  godat::chacha20(key, nonce.data(), 1, c.data(), c.size());
  CHECK(c == msg, "ChaCha20 çözme = şifreleme");
}

static void testRoundTrip() {
  godat::Packer p;
  p.add(80000, "", str("rapor: yeni asker kaydı"));
  p.add(5000, "ani_horse_lv1", Bytes(70000, 7));        // büyük, iyi sıkışan kayıt
  Bytes noise(5000); uint32_t x = 1; for (auto& b : noise) { x = x * 1664525 + 1013904223; b = uint8_t(x >> 24); } p.add(7, "gürültü", noise);
  p.add(9, "", Bytes());                                  // boş kayıt
  for (bool enc : {true, false}) {
    godat::Archive a = godat::Archive::fromMemory(p.build(godat::defaultKey(), enc), "bellek");
    CHECK(a.format() == godat::Format::Packed && a.entries().size() == 4, "paket: kayıt sayısı");
    CHECK(a.data(80000) == str("rapor: yeni asker kaydı"), "paket: metin kaydı");
    CHECK(a.data(5000) == Bytes(70000, 7) && a.find(5000)->name == "ani_horse_lv1", "paket: büyük kayıt ve ad");
    CHECK(a.data(7) == noise && a.data(9).empty(), "paket: sıkışmayan ve boş kayıt");
  }
  // şifreli pakette düz metin görünmez
  Bytes enc = p.build(); std::string s(enc.begin(), enc.end());
  CHECK(s.find("ani_horse_lv1") == std::string::npos, "şifreli pakette kayıt adı okunmuyor");
  Bytes plain = p.build(godat::defaultKey(), false); std::string s2(plain.begin(), plain.end());
  CHECK(s2.find("ani_horse_lv1") != std::string::npos, "şifresiz pakette ad okunuyor (hata ayıklama kipi)");
}

static void testLayers() {
  godat::Packer base; base.add(1, "a", str("bir")); base.add(2, "b", str("iki")); base.add(3, "c", str("üç"));
  godat::Packer patch; patch.add(2, "b", str("İKİ (yama)")); patch.add(9, "yeni", str("dokuz"));
  godat::Archive A = godat::Archive::fromMemory(base.build(), "taban"), B = godat::Archive::fromMemory(patch.build(), "yama");
  godat::Packer all; all.addArchive(A); all.addArchive(B);
  godat::Archive C = godat::Archive::fromMemory(all.build(), "birleşik");
  CHECK(C.entries().size() == 4, "yama: 3 taban + 1 yeni kayıt");
  CHECK(C.data(2) == str("İKİ (yama)") && C.data(1) == str("bir") && C.data(9) == str("dokuz"), "yama: aynı numara yenisiyle değişir");
  CHECK(C.entries()[1].id == 2, "yama: değişen kayıt yerini korur");
}

static void testTamper() {
  godat::Packer p; p.add(42, "", str("Andecano'nun hazinesi"));
  Bytes b = p.build();
  godat::Key wrong = godat::defaultKey(); wrong[0] ^= 1;
  CHECK(throws([&] { godat::Archive::fromMemory(b, "yanlış anahtar", wrong); }), "yanlış anahtar yakalanır");
  Bytes t = b; t.back() ^= 0x20;   // son kaydın bir baytı
  godat::Archive a = godat::Archive::fromMemory(t, "oynanmış");
  CHECK(throws([&] { a.data(42); }), "oynanmış kayıt yakalanır (CRC)");
  CHECK(throws([&] { godat::Archive::fromMemory(str("merhaba dünya"), "godat değil"); }), "godat olmayan dosya reddedilir");
}

// orijinal biçimi bellekte kur: imza, 7 sıfır, sayı, dizin boyu, girdiler, veri
static void testOriginal() {
  auto z = [](const Bytes& d) { uLongf cl = compressBound(uLong(d.size())); Bytes o(cl); compress2(o.data(), &cl, d.data(), uLong(d.size()), 6); o.resize(cl); return o; };
  auto u32 = [](Bytes& b, uint32_t v) { for (int i = 0; i < 4; i++) b.push_back(uint8_t(v >> (8 * i))); };
  Bytes p1 = str("birinci parça "), p2 = str("ikinci parça"), z1 = z(p1), z2 = z(p2);
  Bytes rec1; u32(rec1, 1); u32(rec1, 2); u32(rec1, uint32_t(z1.size())); u32(rec1, uint32_t(p1.size()));
  rec1.insert(rec1.end(), z1.begin(), z1.end()); u32(rec1, uint32_t(z2.size())); u32(rec1, uint32_t(p2.size())); rec1.insert(rec1.end(), z2.begin(), z2.end());
  Bytes rec2 = str("sıkıştırılmamış kayıt");
  Bytes f = str("sy2dr2.6"); f.resize(15, 0); u32(f, 2); u32(f, 24);
  uint32_t dirEnd = 23 + 12 + 3 + 12;
  u32(f, 100); u32(f, dirEnd + uint32_t(rec1.size())); u32(f, 3); f.insert(f.end(), {'b', 'i', 'r'});   // dizin konuma göre sıralı değil
  u32(f, 200); u32(f, dirEnd); u32(f, 0);
  f.insert(f.end(), rec1.begin(), rec1.end()); f.insert(f.end(), rec2.begin(), rec2.end());
  godat::Archive a = godat::Archive::fromMemory(f, "orijinal");
  CHECK(a.format() == godat::Format::Original && a.entries().size() == 2, "orijinal: kayıt sayısı");
  CHECK(a.data(200) == str("birinci parça ikinci parça"), "orijinal: iki parçalı zlib kayıt");
  CHECK(a.data(100) == rec2 && a.find(100)->name == "bir", "orijinal: sıkıştırılmamış kayıt ve ad");
  Bytes bad = rec1; bad[20] ^= 0xff;
  CHECK(godat::unpackOriginal(bad) == bad, "orijinal: açılamayan kayıt olduğu gibi döner");
}

int main() {
  testChacha(); testRoundTrip(); testLayers(); testTamper(); testOriginal();
  std::printf("godat testleri: %d geçti, %d kaldı%s\n", passed, failed, godat::isDevKey() ? " (geliştirme anahtarı)" : "");
  return failed ? 1 : 0;
}
