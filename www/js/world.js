// Orijinal .wim haritalarını çizer. Izgara: 42x22 piksellik baklava karolar.
'use strict';

const TW = 42, TH = 22, HW = 21, HH = 11;

class GameMap {
  constructor(id, json, scene) {
    Object.assign(this, json);
    this.id = id; this.scene = scene;
    this.OX = this.h * HW;            // (0,0) karesinin tepe noktasının x'i
    this.pw = (this.w + this.h) * HW; this.ph = (this.w + this.h) * HH + TH;
    this.objs = []; this.ground = null; this.sprites = new Map();
    this.extraBlock = new Uint8Array(this.w * this.h);
  }
  // kare merkezinden piksel
  px(x, y) { return this.OX + (x - y) * HW; }
  py(x, y) { return (x + y) * HH + HH; }
  // pikselden kare koordinatı (ondalıklı, merkez = tam sayı)
  toCell(X, Y) { const a = (X - this.OX) / HW, b = (Y - HH) / HH; return { x: (a + b) / 2, y: (b - a) / 2 }; }
  idx(x, y) { return y * this.w + x; }
  inside(x, y) { return x >= 0 && y >= 0 && x < this.w && y < this.h; }
  blocked(fx, fy) {
    const x = Math.round(fx), y = Math.round(fy);
    if (!this.inside(x, y)) return true;
    const i = this.idx(x, y); return this.b[i] === 1 || this.extraBlock[i] === 1;
  }
  sprite(name) { let s = this.sprites.get(name); if (!s) { s = new Assets.Sprite(name); this.sprites.set(name, s); } return s; }
  // zemin ve nesne görsellerinin anahtarları (önceden yükleme için)
  assetNames() { return this.names.slice(); }

  build() {
    // zemini tek tuvale çiz
    const c = document.createElement('canvas'); c.width = this.pw; c.height = this.ph;
    const g = c.getContext('2d');
    const sets = this.names.map(n => {
      if (!n.startsWith('GROUND')) return null;
      const r = Assets.reg(n); if (!r) return null;
      const S = Assets.sheet(r[0], r[1], r[3]); if (!S) return null;
      return { S, cols: Math.floor(S.width / TW) };
    });
    for (let y = 0; y < this.h; y++) for (let x = 0; x < this.w; x++) {
      const i = this.idx(x, y), cc = this.c[i], tt = this.t[i];
      const X = this.px(x, y) - HW, Y = (x + y) * HH;
      for (const [s, t] of [[cc & 255, tt & 255], [cc >> 8, tt >> 8]]) {
        if (!s) continue; const G = sets[s - 1]; if (!G) continue;
        g.drawImage(G.S, (t % G.cols) * TW, Math.floor(t / G.cols) * TH, TW, TH, X, Y, TW, TH);
      }
    }
    this.ground = c;
    // nesneler
    this.objs = [];
    for (let y = 0; y < this.h; y++) for (let x = 0; x < this.w; x++) {
      const i = this.idx(x, y), o = this.o[i];
      if (!o) continue;
      const nm = this.names[o - 1]; if (!nm || nm.startsWith('GROUND')) continue;
      const sp = this.sprite(nm); if (!sp.ok) continue;
      this.objs.push({ kind: 'obj', x, y, sp, anim: this.a[i], depth: x + y, X: this.px(x, y), Y: this.py(x, y), flat: /魔法阵|传送门|阵|地标|箭头|地毯/.test(nm) });
    }
  }
  regionsOf(type) { return this.regions.filter(r => r[1] === type); }
}

// A* yol bulma (8 yön, köşe kesmeden)
function findPath(map, sx, sy, tx, ty, maxIter = 5000) {
  sx = Math.round(sx); sy = Math.round(sy); tx = Math.round(tx); ty = Math.round(ty);
  if (!map.inside(tx, ty)) return null;
  if (map.blocked(tx, ty)) {
    let best = null, bd = 1e9;
    for (let r = 1; r < 5 && !best; r++) for (let dy = -r; dy <= r; dy++) for (let dx = -r; dx <= r; dx++) {
      const x = tx + dx, y = ty + dy; if (map.inside(x, y) && !map.blocked(x, y)) { const d = Math.hypot(dx, dy); if (d < bd) { bd = d; best = [x, y]; } }
    }
    if (!best) return null; [tx, ty] = best;
  }
  const W = map.w, key = (x, y) => y * W + x, open = [[sx, sy, 0, 0]], g = new Map([[key(sx, sy), 0]]), came = new Map();
  let it = 0;
  while (open.length && it++ < maxIter) {
    let bi = 0; for (let i = 1; i < open.length; i++) if (open[i][3] < open[bi][3]) bi = i;
    const [x, y] = open.splice(bi, 1)[0];
    if (x === tx && y === ty) { const out = []; let k = key(x, y); while (k !== undefined && k !== key(sx, sy)) { out.push([k % W, Math.floor(k / W)]); k = came.get(k); } return out.reverse(); }
    for (const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]]) {
      const nx = x + dx, ny = y + dy; if (!map.inside(nx, ny) || map.blocked(nx, ny)) continue;
      if (dx && dy && (map.blocked(x + dx, y) || map.blocked(x, y + dy))) continue;
      const ng = g.get(key(x, y)) + (dx && dy ? 1.414 : 1), k = key(nx, ny);
      if (ng < (g.get(k) ?? 1e9)) { g.set(k, ng); came.set(k, key(x, y)); open.push([nx, ny, ng, ng + Math.hypot(nx - tx, ny - ty)]); }
    }
  }
  return null;
}
