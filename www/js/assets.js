// Orijinal oyun varlıklarını yükler ve çizer.
// Görseller palet indeksli (gri = renk numarası, alfa = saydamlık) PNG olarak gelir;
// palet burada uygulanır, böylece aynı görselin renk varyantları üretilebilir.
'use strict';

const Assets = (() => {
  let D = null, ANI = null, PAL = null;
  const imgs = new Map(), canv = new Map(), loading = new Map();

  async function init(base = 'assets/') {
    const [d, a, p] = await Promise.all([
      fetch(base + 'data.json').then(r => r.json()),
      fetch(base + 'ani.json').then(r => r.json()),
      fetch(base + 'pal.bin').then(r => r.arrayBuffer()),
    ]);
    D = d; ANI = a; PAL = new Uint8Array(p);
    Assets.base = base;
    return D;
  }
  function pal(key) { const i = D.palidx[key]; return i == null ? null : PAL.subarray(i * 768, i * 768 + 768); }

  function loadImg(key) {
    if (imgs.has(key)) return Promise.resolve(imgs.get(key));
    if (loading.has(key)) return loading.get(key);
    const pr = (Assets.blobLoader ? Assets.blobLoader(key) : Promise.resolve(Assets.base + 'sheets/' + key + '.png'))
      .then(src => new Promise((res, rej) => { const im = new Image(); im.onload = () => { imgs.set(key, im); res(im); }; im.onerror = () => rej(new Error('görsel yok: ' + key)); im.src = src; }));
    loading.set(key, pr); return pr;
  }
  // Paleti uygulanmış tuval
  function sheet(file, bmp, palId) {
    const sk = file + '_' + bmp, pk = palId ? file + '_' + palId : sk, ck = sk + '|' + pk;
    let c = canv.get(ck); if (c) return c;
    const im = imgs.get(sk); if (!im) { loadImg(sk).catch(() => { }); return null; }
    const P = pal(pk) || pal(sk);
    c = document.createElement('canvas'); c.width = im.width; c.height = im.height;
    const x = c.getContext('2d', { willReadFrequently: true }); x.drawImage(im, 0, 0);
    const id = x.getImageData(0, 0, c.width, c.height), d = id.data;
    for (let i = 0; i < d.length; i += 4) {
      if (!d[i + 3]) continue;
      const k = d[i] * 3; d[i] = P[k]; d[i + 1] = P[k + 1]; d[i + 2] = P[k + 2];
      if (d[i] === 255 && d[i + 1] === 0 && d[i + 2] === 255) d[i + 3] = 0;
    }
    x.putImageData(id, 0, 0); canv.set(ck, c); return c;
  }
  // Işık efektleri (alev vb.) için: koyu pikseller hiçbir şey eklemez, çizgili titreşim yatayda yumuşatılır.
  function sheetAdd(file, bmp, palId) {
    const base = sheet(file, bmp, palId); if (!base) return null;
    const ck = 'add|' + file + '_' + bmp + '|' + palId; let c = canv.get(ck); if (c) return c;
    c = document.createElement('canvas'); c.width = base.width; c.height = base.height;
    const x = c.getContext('2d', { willReadFrequently: true });
    const src = base.getContext('2d').getImageData(0, 0, c.width, c.height).data;
    const id = x.createImageData(c.width, c.height), d = id.data, W = c.width;
    for (let i = 0; i < src.length; i += 4) {
      const px = (i >> 2) % W, j = px + 1 < W ? i + 4 : i, k = px > 0 ? i - 4 : i;
      if (!src[i + 3] && !src[j + 3] && !src[k + 3]) continue;
      for (let ch = 0; ch < 3; ch++) d[i + ch] = ((src[i + 3] ? src[i + ch] : 0) * 2 + (src[j + 3] ? src[j + ch] : 0) + (src[k + 3] ? src[k + ch] : 0)) / 4;
      d[i + 3] = 255;
    }
    x.putImageData(id, 0, 0); canv.set(ck, c); return c;
  }
  function reg(name) { return D.reg[name]; }
  function ani(file, aniId) { return ANI[file + '_' + aniId]; }
  async function preload(names) {
    const keys = new Set();
    for (const n of names) { const r = D.reg[n]; if (r) keys.add(r[0] + '_' + r[1]); }
    await Promise.all([...keys].map(k => loadImg(k).catch(e => console.warn(e.message))));
  }
  async function preloadKeys(keys) { await Promise.all([...keys].map(k => loadImg(k).catch(e => console.warn(e.message)))); }

  // Tek görsellik bir kareyi çiz. (x,y) çapa noktası.
  function drawParts(ctx, A, frame, sheets, x, y, mirror, alpha = 1) {
    const parts = A.f[frame]; if (!parts) return;
    for (const p of parts) {
      const m = A.m[p[0]]; if (!m) continue;
      const S = sheets.length > 1 ? sheets[m[4]] : sheets[0]; if (!S) continue;
      const fv = p[1] & 2, w = m[2], h = m[3];
      let flipX = !!(p[1] & 1), px = p[2], py = p[3];
      if (mirror) { px = -px; flipX = !flipX; }
      // aynalı parçada x değeri sağ kenarı gösterir
      const left = flipX ? px - w : px;
      ctx.globalAlpha = alpha;
      if (!flipX && !fv) ctx.drawImage(S, m[0], m[1], w, h, x + left, y + py, w, h);
      else {
        ctx.save(); ctx.translate(x + left + (flipX ? w : 0), y + py + (fv ? h : 0)); ctx.scale(flipX ? -1 : 1, fv ? -1 : 1);
        ctx.drawImage(S, m[0], m[1], w, h, 0, 0, w, h); ctx.restore();
      }
    }
    ctx.globalAlpha = 1;
  }
  // Kayıt adına göre sprite
  class Sprite {
    constructor(name) {
      const r = D.reg[name]; this.ok = !!r; if (!r) return;
      this.r = r; this.A = ANI[r[0] + '_' + r[2]]; this.ok = !!this.A;
      this.add = /火焰|火光|光柱|光芒/.test(name);
      loadImg(r[0] + '_' + r[1]).catch(() => { });
    }
    get anims() { return this.A ? this.A.a : []; }
    frameOf(anim, t) {
      const seq = this.A.a[anim]; if (!seq || !seq.length) return null;
      let tot = 0; for (const s of seq) tot += Math.max(1, s[1]);
      let k = Math.floor(t) % tot; for (const s of seq) { k -= Math.max(1, s[1]); if (k < 0) return s[0]; }
      return seq[0][0];
    }
    animLen(anim) { const seq = this.A.a[anim] || []; let n = 0; for (const s of seq) n += Math.max(1, s[1]); return n; }
    draw(ctx, anim, t, x, y, mirror, alpha) {
      if (!this.ok) return;
      const S = (this.add ? sheetAdd : sheet)(this.r[0], this.r[1], this.r[3]); if (!S) return;
      const f = this.frameOf(anim, t); if (f == null) return;
      if (this.add) ctx.globalCompositeOperation = 'lighter';
      drawParts(ctx, this.A, f, [S], x, y, mirror, alpha);
      if (this.add) ctx.globalCompositeOperation = 'source-over';
    }
    drawFrame(ctx, f, x, y) { const S = sheet(this.r[0], this.r[1], this.r[3]); if (S) drawParts(ctx, this.A, f, [S], x, y); }
  }

  // Oyuncu karakteri: gövde, kafa, silah ve süs katmanları ortak kare tanımıyla çizilir.
  // look: {cls:'战士'|'法师'|'牧师', race:'人类'|'精灵', sex:'male'|'fema', body:[tier,color], head:[tier,color], weap:[tier,color]}
  const ACTIONS = ['comm', 'town', 'figh', 'hors'];
  class Paperdoll {
    constructor(look) { this.set(look); }
    set(look) {
      this.look = look; this.layers = {};
      for (const act of ACTIONS) {
        const fr = D.frames[`frame_${act}_${look.sex}_${look.race}_${look.cls}`];
        const A = fr ? ANI['frame_ani_' + fr] : null;
        const L = [];
        const pick = (part, gear) => {
          const suf = `_${act}_${look.sex}_${look.race}_${look.cls}`;
          if (typeof gear === 'string') { const n = `${gear}_${part}${suf}`; if (D.reg[n]) return D.reg[n]; }
          else if (gear && gear[0]) { const n = `group${gear[0]}_${gear[1]}_${part}${suf}`; if (D.reg[n]) return D.reg[n]; }
          return D.reg[`default_${part}${suf}`] || null;
        };
        L[0] = pick('body', look.bodyG || look.body); L[1] = pick('head', look.headG || look.head); L[2] = pick('weap', look.weapG || look.weap);
        const o1 = D.reg[`group1_orn1${'_' + act}_${look.sex}_${look.race}_${look.cls}`];
        const o2 = D.reg[`group1_${look.orn2 || '白'}_orn2_${act}_${look.sex}_${look.race}_${look.cls}`] || Object.keys(D.reg).filter(k => k.startsWith('group1_') && k.includes('_orn2_' + act + '_' + look.sex + '_' + look.race + '_' + look.cls)).map(k => D.reg[k])[0];
        L[3] = look.race === '精灵' ? o1 : null; L[4] = look.aura ? (o2 || null) : null;
        L.forEach(r => r && loadImg(r[0] + '_' + r[1]).catch(() => { }));
        this.layers[act] = { A, L };
      }
    }
    animLen(act, anim) { const A = this.layers[act]?.A; if (!A) return 1; const seq = A.a[anim] || []; let n = 0; for (const s of seq) n += Math.max(1, s[1]); return n; }
    draw(ctx, act, anim, t, x, y, alpha = 1) {
      const lay = this.layers[act]; if (!lay || !lay.A) return;
      const seq = lay.A.a[anim]; if (!seq || !seq.length) return;
      let tot = 0; for (const s of seq) tot += Math.max(1, s[1]);
      let k = Math.floor(t) % tot, f = seq[0][0]; for (const s of seq) { k -= Math.max(1, s[1]); if (k < 0) { f = s[0]; break; } }
      const sheets = lay.L.map(r => r ? sheet(r[0], r[1], r[3]) : null);
      // gölge (orn2) önce, sonra diğerleri kare sırasıyla
      drawParts(ctx, lay.A, f, sheets, x, y, false, alpha);
    }
  }
  return { init, reg, ani, sheet, pal, preload, preloadKeys, loadImg, Sprite, Paperdoll, drawParts, get D() { return D; } };
})();
