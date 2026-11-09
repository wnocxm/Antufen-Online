// Orijinal ekran tanımlarını (AnbufenUI.godat -> assets/forms.json) çizen ve dokunmayı eşleyen katman.
// Her denetim: konum, durumlar (0 normal, 1 basılı/seçili) ve katmanlar (0 çizgi, 1 dolgu/yer tutucu, 2 görsel, 3 yazı).
'use strict';

const Forms = (() => {
  let F = null; const imgs = {};
  // orijinal arayüz yazılarının Türkçesi
  const T = {
    '装备': 'Ekipman', '消耗': 'Tüketim', '普通': 'Genel', '任务': 'Görev', '任务 ': 'Görev', '快捷键': 'Kısayol', '存钱': 'Sat', '详细': 'Ayrıntı', '销毁': 'Yok Et',
    '自动回复': 'Oto. İksir', '扩容': 'Genişlet', '确定': 'Tamam', '取消': 'İptal', '返回': 'Geri', '关闭': 'Kapat', '属性': 'Özellik', '称号': 'Unvan', '信息': 'Bilgi',
    '接受': 'Kabul', '放弃': 'Bırak', '完成': 'Tamamla', '可接任务': 'Alınabilir', '已接任务': 'Alınmış', '购买': 'Satın Al', '卖出': 'Sat', '修理': 'Onar',
  };
  async function init(base) { F = await fetch(base + 'forms.json').then(r => r.json()); }
  function img(id) { let im = imgs[id]; if (!im) { im = new Image(); im.src = `${Assets.base}ui/AnbufenUI_Resource_${id}.png`; imgs[id] = im; } return im; }
  const rgb = c => `rgb(${(c >>> 16) & 255},${(c >>> 8) & 255},${c & 255})`;
  function get(name) { return F[name]; }
  function ctrl(name, id) { return F[name].c.find(c => c.id === id); }

  // Bir denetimi çiz. st: durum indeksi. o: {x,y} form kökü; dx,dy: ek kaydırma (yan menüler için)
  function drawCtrl(ctx, c, st, ox, oy, txt) {
    const s = c.s[Math.min(st || 0, c.s.length - 1)]; if (!s) return;
    const cx = ox + s.r[0], cy = oy + s.r[1];
    for (let i = s.L.length - 1; i >= 0; i--) {
      const [k, x, y, w, h, a0, a1, a2, col, al, im, t] = s.L[i], X = cx + x, Y = cy + y;
      if (k === 2 && im) {
        const I = img(im); if (!I.complete || !I.naturalWidth) continue;
        ctx.globalAlpha = al / 100;
        const sw = Math.min(w, I.naturalWidth - a0), sh = Math.min(h, I.naturalHeight - a1); if (sw <= 0 || sh <= 0) { ctx.globalAlpha = 1; continue; }
        for (let yy = 0; yy < h; yy += sh) for (let xx = 0; xx < w; xx += sw) { const tw = Math.min(sw, w - xx), th = Math.min(sh, h - yy); ctx.drawImage(I, a0, a1, tw, th, X + xx, Y + yy, tw, th); }
        ctx.globalAlpha = 1;
      } else if (k === 0) { ctx.fillStyle = rgb(col); ctx.fillRect(X, Y, Math.max(1, w), Math.max(1, h)); }
      else if (k === 1) { if (a2 === 0 && al > 0) { ctx.globalAlpha = al / 100; ctx.fillStyle = rgb(col); ctx.fillRect(X, Y, w, h); ctx.globalAlpha = 1; } }
      else if (k === 3) { const str = txt != null ? txt : (T[t] || T[(t || '').trim()] || t); label(ctx, str, X, Y, w, h, rgb(col)); }
    }
  }
  function label(ctx, str, x, y, w, h, color, align = 'center', size = 11) {
    if (str == null || str === '') return;
    ctx.font = `${size}px "Noto Sans", sans-serif`; ctx.textAlign = align; ctx.textBaseline = 'middle';
    const tx = align === 'center' ? x + w / 2 : align === 'right' ? x + w - 2 : x + 2, ty = y + h / 2 + 0.5;
    ctx.fillStyle = '#000'; ctx.fillText(str, tx + 1, ty + 1, w); ctx.fillStyle = color || '#fff'; ctx.fillText(str, tx, ty, w);
    ctx.textBaseline = 'alphabetic';
  }
  // Formun düz (gruba ait olmayan) denetimlerini arkadan öne çiz
  function draw(ctx, name, ox, oy, opt = {}) {
    const f = F[name];
    for (let i = f.c.length - 1; i >= 0; i--) {
      const c = f.c[i]; if (c.g !== -1) continue; if (opt.hide && opt.hide(c)) continue;
      drawCtrl(ctx, c, opt.state ? opt.state(c) : 0, ox, oy, opt.text ? opt.text(c) : undefined);
      if (opt.after) opt.after(c, ox + c.s[0].r[0], oy + c.s[0].r[1], c.s[0].r[2], c.s[0].r[3]);
    }
  }
  // Yan menü (grup): arka plan denetimi (gy = -1) ve düğmeler (gy = dikey konum)
  function drawGroup(ctx, name, g, ox, oy, opt = {}) {
    const f = F[name], items = f.c.filter(c => c.g === g && c.gy >= 0 && c.s.length && !(opt.hide && opt.hide(c))).sort((a, b) => a.gy - b.gy);
    const bg = f.c.find(c => c.g === g && c.gy === -1);
    if (bg) { ctx.save(); ctx.beginPath(); ctx.rect(ox, oy, 79, items.length * 46 + 2); ctx.clip(); drawCtrl(ctx, bg, 0, ox, oy); ctx.restore(); }
    items.forEach((c, i) => drawCtrl(ctx, c, opt.state ? opt.state(c) : 0, ox, oy + i * 46, opt.text ? opt.text(c) : undefined));
    return items.map((c, i) => ({ c, x: ox + 1, y: oy + 1 + i * 46, w: 77, h: 46 }));
  }
  function hit(name, ox, oy, x, y, filter) {
    const f = F[name];
    for (const c of f.c) { if (c.g !== -1 || !c.s.length) continue; if (filter && !filter(c)) continue; const r = c.s[0].r; if (x >= ox + r[0] && x < ox + r[0] + r[2] && y >= oy + r[1] && y < oy + r[1] + r[3]) return c; }
    return null;
  }
  return { init, get, ctrl, draw, drawCtrl, drawGroup, hit, label, img, T };
})();
