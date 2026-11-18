#include "chacha20.h"

#include <cstring>

namespace godat {

static inline uint32_t rotl(uint32_t v, int n) { return (v << n) | (v >> (32 - n)); }
static inline uint32_t le32(const uint8_t* p) { return p[0] | (p[1] << 8) | (p[2] << 16) | (uint32_t(p[3]) << 24); }

// 4 sözcüklük çeyrek tur (RFC 8439 2.1)
#define QR(a, b, c, d) \
  a += b; d ^= a; d = rotl(d, 16); \
  c += d; b ^= c; b = rotl(b, 12); \
  a += b; d ^= a; d = rotl(d, 8);  \
  c += d; b ^= c; b = rotl(b, 7);

// tek 64 baytlık anahtar akışı bloğu (RFC 8439 2.3)
static void block(const uint32_t in[16], uint8_t out[64]) {
  uint32_t x[16];
  std::memcpy(x, in, sizeof x);
  for (int i = 0; i < 10; i++) {   // 20 tur = 10 çift (sütun + köşegen)
    QR(x[0], x[4], x[8], x[12]) QR(x[1], x[5], x[9], x[13]) QR(x[2], x[6], x[10], x[14]) QR(x[3], x[7], x[11], x[15])
    QR(x[0], x[5], x[10], x[15]) QR(x[1], x[6], x[11], x[12]) QR(x[2], x[7], x[8], x[13]) QR(x[3], x[4], x[9], x[14])
  }
  for (int i = 0; i < 16; i++) {
    uint32_t v = x[i] + in[i];
    out[i * 4] = v & 0xff; out[i * 4 + 1] = (v >> 8) & 0xff; out[i * 4 + 2] = (v >> 16) & 0xff; out[i * 4 + 3] = v >> 24;
  }
}

void chacha20(const uint8_t key[32], const uint8_t nonce[12], uint32_t counter, uint8_t* data, size_t len) {
  uint32_t st[16] = {0x61707865, 0x3320646e, 0x79622d32, 0x6b206574};   // "expand 32-byte k"
  for (int i = 0; i < 8; i++) st[4 + i] = le32(key + i * 4);
  st[12] = counter;
  for (int i = 0; i < 3; i++) st[13 + i] = le32(nonce + i * 4);
  uint8_t ks[64];
  for (size_t off = 0; off < len; off += 64) {
    block(st, ks);
    size_t n = len - off < 64 ? len - off : 64;
    for (size_t i = 0; i < n; i++) data[off + i] ^= ks[i];
    st[12]++;
  }
}

}  // namespace godat
