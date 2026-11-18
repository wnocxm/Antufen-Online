#include "jpeg.h"

#include <algorithm>
#include <cstring>
#include <stdexcept>

namespace core {
namespace {

const int ZIGZAG[64] = {0, 1, 8, 16, 9, 2, 3, 10, 17, 24, 32, 25, 18, 11, 4, 5, 12, 19, 26, 33, 40, 48, 41, 34, 27, 20, 13, 6, 7, 14, 21, 28,
                        35, 42, 49, 56, 57, 50, 43, 36, 29, 22, 15, 23, 30, 37, 44, 51, 58, 59, 52, 45, 38, 31, 39, 46, 53, 60, 61, 54, 47, 55, 62, 63};

struct Huff { bool ok = false; uint8_t len[256] = {}; uint16_t code[256] = {}; uint8_t val[256] = {}; int n = 0; int maxcode[18] = {}, valptr[17] = {}, mincode[17] = {}; };
struct Comp { int id = 0, h = 1, v = 1, tq = 0, td = 0, ta = 0, bw = 0, bh = 0, dw = 0, dh = 0, pred = 0; std::vector<uint8_t> pix; };

struct Reader {
  const std::vector<uint8_t>& f; size_t p = 0; uint32_t buf = 0; int bits = 0; bool marker = false;
  explicit Reader(const std::vector<uint8_t>& d) : f(d) {}
  int byte() { if (p >= f.size()) throw std::runtime_error("JPEG: dosya erken bitti"); return f[p++]; }
  int u16() { const int a = byte(); return (a << 8) | byte(); }
  // entropi verisi: 0xFF00 → 0xFF; işarete gelince sıfır doldurulur (libjpeg gibi)
  void fill() {
    while (bits <= 24) {
      int b = 0;
      if (!marker && p < f.size()) {
        b = f[p];
        if (b == 0xFF) { const int n = p + 1 < f.size() ? f[p + 1] : 0; if (n == 0) p += 2; else { marker = true; b = 0; } }
        else p++;
      }
      buf |= uint32_t(b) << (24 - bits); bits += 8;
    }
  }
  int bit() { fill(); const int r = int(buf >> 31); buf <<= 1; bits--; return r; }
  int get(int n) { if (!n) return 0; fill(); const int r = int(buf >> (32 - n)); buf <<= n; bits -= n; return r; }
  void reset() { buf = 0; bits = 0; marker = false; }
  int decode(const Huff& h) {
    int code = 0;
    for (int l = 1; l <= 16; l++) { code = (code << 1) | bit(); if (code <= h.maxcode[l]) return h.val[h.valptr[l] + code - h.mincode[l]]; }
    return 0;   // bozuk kod: sıfır
  }
};
int extend(int v, int t) { return t && v < (1 << (t - 1)) ? v - (1 << t) + 1 : v; }

// libjpeg jidctint.c jpeg_idct_islow (tam sayı, CONST_BITS 13, PASS1_BITS 2)
const int CB = 13, P1 = 2;
inline int64_t desc(int64_t x, int n) { return (x + (int64_t(1) << (n - 1))) >> n; }
uint8_t RL[1024];   // IDCT_range_limit[x & 1023]
struct RLInit { RLInit() { for (int x = 0; x < 1024; x++) { const int v = x < 512 ? x : x - 1024; RL[x] = uint8_t(std::max(0, std::min(255, v + 128))); } } } rlInit;
void idct(const int* in, const uint16_t* q, uint8_t* out, int stride) {
  int64_t ws[64];
  for (int c = 0; c < 8; c++) {
    const int* ip = in + c; const uint16_t* qp = q + c; int64_t* w = ws + c;
    if (!ip[8] && !ip[16] && !ip[24] && !ip[32] && !ip[40] && !ip[48] && !ip[56]) { const int64_t dc = int64_t(ip[0]) * qp[0] * (1 << P1); for (int k = 0; k < 8; k++) w[k * 8] = dc; continue; }
    int64_t z2 = int64_t(ip[16]) * qp[16], z3 = int64_t(ip[48]) * qp[48];
    int64_t z1 = (z2 + z3) * 4433, tmp2 = z1 + z3 * -15137, tmp3 = z1 + z2 * 6270;
    z2 = int64_t(ip[0]) * qp[0]; z3 = int64_t(ip[32]) * qp[32];
    int64_t tmp0 = (z2 + z3) * (1 << CB), tmp1 = (z2 - z3) * (1 << CB);
    const int64_t t10 = tmp0 + tmp3, t13 = tmp0 - tmp3, t11 = tmp1 + tmp2, t12 = tmp1 - tmp2;
    tmp0 = int64_t(ip[56]) * qp[56]; tmp1 = int64_t(ip[40]) * qp[40]; tmp2 = int64_t(ip[24]) * qp[24]; tmp3 = int64_t(ip[8]) * qp[8];
    z1 = tmp0 + tmp3; z2 = tmp1 + tmp2; z3 = tmp0 + tmp2; int64_t z4 = tmp1 + tmp3; const int64_t z5 = (z3 + z4) * 9633;
    tmp0 *= 2446; tmp1 *= 16819; tmp2 *= 25172; tmp3 *= 12299; z1 *= -7373; z2 *= -20995; z3 *= -16069; z4 *= -3196; z3 += z5; z4 += z5;
    tmp0 += z1 + z3; tmp1 += z2 + z4; tmp2 += z2 + z3; tmp3 += z1 + z4;
    w[0] = desc(t10 + tmp3, CB - P1); w[56] = desc(t10 - tmp3, CB - P1); w[8] = desc(t11 + tmp2, CB - P1); w[48] = desc(t11 - tmp2, CB - P1);
    w[16] = desc(t12 + tmp1, CB - P1); w[40] = desc(t12 - tmp1, CB - P1); w[24] = desc(t13 + tmp0, CB - P1); w[32] = desc(t13 - tmp0, CB - P1);
  }
  for (int r = 0; r < 8; r++) {
    const int64_t* w = ws + r * 8; uint8_t* o = out + r * stride;
    if (!w[1] && !w[2] && !w[3] && !w[4] && !w[5] && !w[6] && !w[7]) { const uint8_t v = RL[int(desc(w[0], P1 + 3)) & 1023]; for (int k = 0; k < 8; k++) o[k] = v; continue; }
    int64_t z2 = w[2], z3 = w[6];
    int64_t z1 = (z2 + z3) * 4433, tmp2 = z1 + z3 * -15137, tmp3 = z1 + z2 * 6270;
    int64_t tmp0 = (w[0] + w[4]) * (1 << CB), tmp1 = (w[0] - w[4]) * (1 << CB);
    const int64_t t10 = tmp0 + tmp3, t13 = tmp0 - tmp3, t11 = tmp1 + tmp2, t12 = tmp1 - tmp2;
    tmp0 = w[7]; tmp1 = w[5]; tmp2 = w[3]; tmp3 = w[1];
    z1 = tmp0 + tmp3; z2 = tmp1 + tmp2; z3 = tmp0 + tmp2; int64_t z4 = tmp1 + tmp3; const int64_t z5 = (z3 + z4) * 9633;
    tmp0 *= 2446; tmp1 *= 16819; tmp2 *= 25172; tmp3 *= 12299; z1 *= -7373; z2 *= -20995; z3 *= -16069; z4 *= -3196; z3 += z5; z4 += z5;
    tmp0 += z1 + z3; tmp1 += z2 + z4; tmp2 += z2 + z3; tmp3 += z1 + z4;
    const int S = CB + P1 + 3;
    o[0] = RL[int(desc(t10 + tmp3, S)) & 1023]; o[7] = RL[int(desc(t10 - tmp3, S)) & 1023]; o[1] = RL[int(desc(t11 + tmp2, S)) & 1023]; o[6] = RL[int(desc(t11 - tmp2, S)) & 1023];
    o[2] = RL[int(desc(t12 + tmp1, S)) & 1023]; o[5] = RL[int(desc(t12 - tmp1, S)) & 1023]; o[3] = RL[int(desc(t13 + tmp0, S)) & 1023]; o[4] = RL[int(desc(t13 - tmp0, S)) & 1023];
  }
}

}  // namespace

Image decodeJPEG(const std::vector<uint8_t>& file) {
  Reader R(file);
  if (R.u16() != 0xFFD8) throw std::runtime_error("JPEG: imza yok");
  uint16_t Q[4][64] = {}; Huff HD[4], HA[4]; std::vector<Comp> C; int W = 0, H = 0, Hm = 1, Vm = 1, ri = 0, mcux = 0, mcuy = 0; bool frame = false, done = false;
  while (!done && R.p < file.size()) {
    int m = R.byte(); if (m != 0xFF) continue;
    while (m == 0xFF && R.p < file.size()) m = R.byte();
    if (m == 0xD9) break;
    if (m == 0xD8 || (m >= 0xD0 && m <= 0xD7) || m == 0x01) continue;
    const int L = R.u16(); const size_t end = R.p + size_t(L) - 2;
    if (m == 0xDB) {   // nicemleme tabloları (zikzak sırasından doğal sıraya)
      while (R.p < end) { const int pq = R.byte(), t = pq & 3; for (int k = 0; k < 64; k++) Q[t][ZIGZAG[k]] = uint16_t((pq >> 4) ? R.u16() : R.byte()); }
    } else if (m == 0xC4) {   // Huffman tabloları
      while (R.p < end) {
        const int tc = R.byte(); Huff& h = (tc >> 4) ? HA[tc & 3] : HD[tc & 3]; h = Huff(); int cnt[17] = {}; h.n = 0;
        for (int l = 1; l <= 16; l++) { cnt[l] = R.byte(); h.n += cnt[l]; }
        if (h.n > 256) throw std::runtime_error("JPEG: bozuk Huffman tablosu");
        for (int i = 0; i < h.n; i++) h.val[i] = uint8_t(R.byte());
        int code = 0, k = 0;
        for (int l = 1; l <= 16; l++) { h.valptr[l] = k; h.mincode[l] = code; code += cnt[l]; k += cnt[l]; h.maxcode[l] = cnt[l] ? code - 1 : -1; code <<= 1; }
        h.ok = true;
      }
    } else if (m == 0xC0 || m == 0xC1) {   // çerçeve: taban / genişletilmiş sıralı
      if (R.byte() != 8) throw std::runtime_error("JPEG: yalnız 8 bit");
      H = R.u16(); W = R.u16(); const int n = R.byte(); C.resize(size_t(n));
      for (Comp& c : C) { c.id = R.byte(); const int hv = R.byte(); c.h = hv >> 4; c.v = hv & 15; c.tq = R.byte() & 3; Hm = std::max(Hm, c.h); Vm = std::max(Vm, c.v); }
      if (W <= 0 || H <= 0 || n < 1) throw std::runtime_error("JPEG: bozuk çerçeve");
      mcux = (W + 8 * Hm - 1) / (8 * Hm); mcuy = (H + 8 * Vm - 1) / (8 * Vm);
      for (Comp& c : C) { c.bw = mcux * c.h; c.bh = mcuy * c.v; c.pix.assign(size_t(c.bw) * 8 * size_t(c.bh) * 8, 0); c.dw = (W * c.h + Hm - 1) / Hm; c.dh = (H * c.v + Vm - 1) / Vm; }
      frame = true;
    } else if (m == 0xC2 || m == 0xC3 || (m >= 0xC5 && m <= 0xCF && m != 0xC8 && m != 0xCC)) throw std::runtime_error("JPEG: ilerlemeli/aritmetik JPEG desteklenmiyor");
    else if (m == 0xDD) ri = R.u16();
    else if (m == 0xDA) {   // tarama
      if (!frame) throw std::runtime_error("JPEG: çerçevesiz tarama");
      const int ns = R.byte(); std::vector<Comp*> S;
      for (int i = 0; i < ns; i++) { const int id = R.byte(), t = R.byte(); for (Comp& c : C) if (c.id == id) { c.td = t >> 4; c.ta = t & 15; S.push_back(&c); } }
      R.p = end; R.reset();
      for (Comp& c : C) c.pred = 0;
      int coef[64];
      auto block = [&](Comp& c, int bx, int by) {
        std::memset(coef, 0, sizeof coef);
        const int t = R.decode(HD[c.td]); const int diff = t ? extend(R.get(t), t) : 0; c.pred += diff; coef[0] = c.pred;
        for (int k = 1; k < 64;) {
          const int rs = R.decode(HA[c.ta]), r = rs >> 4, s = rs & 15;
          if (!s) { if (r == 15) { k += 16; continue; } break; }
          k += r; if (k > 63) break;
          coef[ZIGZAG[k]] = extend(R.get(s), s); k++;
        }
        if (bx < c.bw && by < c.bh) idct(coef, Q[c.tq], &c.pix[size_t(by) * 8 * size_t(c.bw) * 8 + size_t(bx) * 8], c.bw * 8);
      };
      int todo = 0;
      auto restart = [&] {
        if (!ri) return;
        if (++todo < ri) return;
        todo = 0; R.reset();   // okuyucu işarette durur: RSTn ise atla
        if (R.p + 1 < file.size() && file[R.p] == 0xFF && file[R.p + 1] >= 0xD0 && file[R.p + 1] <= 0xD7) R.p += 2;
        for (Comp& c : C) c.pred = 0;
      };
      if (S.size() == 1) {   // tek bileşen: bileşenin kendi blokları
        Comp& c = *S[0]; const int nbx = (c.dw + 7) / 8, nby = (c.dh + 7) / 8;
        for (int by = 0; by < nby; by++) for (int bx = 0; bx < nbx; bx++) { block(c, bx, by); restart(); }
      } else {
        for (int my = 0; my < mcuy; my++) for (int mx = 0; mx < mcux; mx++) {
          for (Comp* c : S) for (int v = 0; v < c->v; v++) for (int h = 0; h < c->h; h++) block(*c, mx * c->h + h, my * c->v + v);
          restart();
        }
      }
      // tarama sonu: bir sonraki işarete git
      while (R.p + 1 < file.size() && !(file[R.p] == 0xFF && file[R.p + 1] != 0 && !(file[R.p + 1] >= 0xD0 && file[R.p + 1] <= 0xD7))) R.p++;
      continue;
    }
    R.p = end;
  }
  if (!frame) throw std::runtime_error("JPEG: çerçeve yok");
  // bileşenleri tam boya büyüt (libjpeg jdsample: h2v2/h2v1 "fancy", ötekiler kopyalama); kenarlarda son satır/sütun yinelenir
  std::vector<std::vector<uint8_t>> full(C.size());
  for (size_t ci = 0; ci < C.size(); ci++) {
    Comp& c = C[ci]; std::vector<uint8_t>& o = full[ci]; o.assign(size_t(W) * H, 0);
    const int stride = c.bw * 8; auto at = [&](int x, int y) { return int(c.pix[size_t(std::max(0, std::min(c.dh - 1, y))) * stride + size_t(std::max(0, std::min(c.dw - 1, x)))]); };
    const int fx = Hm / c.h, fy = Vm / c.v; const int ow = c.dw * fx;
    std::vector<uint8_t> row(size_t(ow) + 2);
    for (int oy = 0; oy < H; oy++) {
      if (fx == 2 && fy == 2 && c.dw > 2) {
        const int iy = oy / 2, ny = (oy & 1) ? iy + 1 : iy - 1;
        auto cs = [&](int x) { return at(x, iy) * 3 + at(x, ny); };
        int last = cs(0), cur = cs(0), nxt = cs(1); int k = 0;
        row[size_t(k++)] = uint8_t((cur * 4 + 8) >> 4); row[size_t(k++)] = uint8_t((cur * 3 + nxt + 7) >> 4); last = cur; cur = nxt;
        for (int x = 2; x < c.dw; x++) { nxt = cs(x); row[size_t(k++)] = uint8_t((cur * 3 + last + 8) >> 4); row[size_t(k++)] = uint8_t((cur * 3 + nxt + 7) >> 4); last = cur; cur = nxt; }
        row[size_t(k++)] = uint8_t((cur * 3 + last + 8) >> 4); row[size_t(k++)] = uint8_t((cur * 4 + 7) >> 4);
      } else if (fx == 2 && fy == 1 && c.dw > 2) {
        const int iy = oy; int k = 0, v = at(0, iy);
        row[size_t(k++)] = uint8_t(v); row[size_t(k++)] = uint8_t((v * 3 + at(1, iy) + 2) >> 2);
        for (int x = 1; x < c.dw - 1; x++) { v = at(x, iy) * 3; row[size_t(k++)] = uint8_t((v + at(x - 1, iy) + 1) >> 2); row[size_t(k++)] = uint8_t((v + at(x + 1, iy) + 2) >> 2); }
        v = at(c.dw - 1, iy); row[size_t(k++)] = uint8_t((v * 3 + at(c.dw - 2, iy) + 1) >> 2); row[size_t(k++)] = uint8_t(v);
      } else for (int x = 0; x < ow; x++) row[size_t(x)] = uint8_t(at(x / fx, oy / fy));
      std::memcpy(&o[size_t(oy) * W], row.data(), size_t(std::min(W, ow)));
      for (int x = ow; x < W; x++) o[size_t(oy) * W + size_t(x)] = row[size_t(ow - 1)];
    }
  }
  // renk dönüşümü (libjpeg jdcolor: 16 bit sabit nokta tabloları)
  Image im; im.w = W; im.h = H; im.px.assign(size_t(W) * H * 4, 255);
  auto clamp8 = [](int v) { return uint8_t(v < 0 ? 0 : v > 255 ? 255 : v); };
  if (C.size() >= 3) {
    static int crr[256], cbb[256]; static int64_t crg[256], cbg[256]; static bool init = false;
    if (!init) {
      const int64_t SB = 16, HALF = int64_t(1) << (SB - 1); auto FIX = [&](double x) { return int64_t(x * double(int64_t(1) << SB) + 0.5); };
      for (int i = 0; i < 256; i++) { const int64_t x = i - 128; crr[i] = int((FIX(1.40200) * x + HALF) >> SB); cbb[i] = int((FIX(1.77200) * x + HALF) >> SB); crg[i] = -FIX(0.71414) * x; cbg[i] = -FIX(0.34414) * x + HALF; }
      init = true;
    }
    for (size_t i = 0; i < size_t(W) * H; i++) {
      const int y = full[0][i], cb = full[1][i], cr = full[2][i]; uint8_t* d = &im.px[i * 4];
      d[0] = clamp8(y + crr[cr]); d[1] = clamp8(y + int((cbg[cb] + crg[cr]) >> 16)); d[2] = clamp8(y + cbb[cb]);
    }
  } else for (size_t i = 0; i < size_t(W) * H; i++) { uint8_t* d = &im.px[i * 4]; d[0] = d[1] = d[2] = full[0][i]; }
  return im;
}

}  // namespace core
