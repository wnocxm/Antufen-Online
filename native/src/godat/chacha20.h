// ChaCha20 akış şifresi (RFC 8439). Aynı işlem şifreler ve çözer (veriyle anahtar akışı XOR'lanır).
// Doğrulama: tests/test_godat.cpp RFC 8439 2.4.2 örneği.
#pragma once
#include <cstddef>
#include <cstdint>

namespace godat {

// key: 32 bayt, nonce: 12 bayt, counter: ilk bloğun sayacı; data yerinde değiştirilir
void chacha20(const uint8_t key[32], const uint8_t nonce[12], uint32_t counter, uint8_t* data, size_t len);

}  // namespace godat
