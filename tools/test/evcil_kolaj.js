// Evcil hayvan görsel denetimi: her türün 8 biçimi (temel + 7 dönüşüm aşaması) ve doğuştan becerisinin simgesi tek görselde.
// node tools/test/evcil_kolaj.js   (OUT=çıktı yolu, varsayılan /tmp/evcil_kolaj.png)
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch(); const p = await (await b.newContext({ viewport: { width: 780, height: 360 }, deviceScaleFactor: 1 })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.addInitScript(() => { try { localStorage.setItem('anrufen_lang', 'tr'); } catch (e) {} });
  await p.goto(process.env.URL || 'http://localhost:8099/'); await p.waitForTimeout(1200); await p.keyboard.press('Enter');
  await p.click('[data-cls="战士"]'); await p.fill('#cname', 'Kolaj'); await p.click('#cstart');
  await p.waitForFunction(() => window.__G && window.__G.player, null, { timeout: 30000 });
  const url = await p.evaluate(async () => {
    const S = Pet.D.species, looks = [...new Set(S.flatMap(s => s.forms.map(f => f.look)))];
    await Assets.preload(looks);
    const icons = {}; await Promise.all(S.map(s => new Promise(r => { const sk = Pet.D.skills[s.skill]; if (!sk || !sk.icon) return r(); const I = new Image(); I.onload = I.onerror = r; I.src = `${Assets.base}ui/icon_res_skill_${sk.icon}.png`; icons[s.cn] = I; })));
    const CW = 92, CH = 104, L = 150, cv = document.createElement('canvas'); cv.width = L + CW * 8; cv.height = 24 + CH * S.length;
    const c = cv.getContext('2d'); c.fillStyle = '#2b2620'; c.fillRect(0, 0, cv.width, cv.height); c.font = '11px sans-serif'; c.fillStyle = '#ffe9a8';
    ['Temel', '1', '2', '3', '4', '5', '6', '7'].forEach((h, i) => c.fillText(h, L + i * CW + 4, 15));
    S.forEach((s, r) => {
      const y = 24 + r * CH; c.fillStyle = r % 2 ? '#332d26' : '#3a332b'; c.fillRect(0, y, cv.width, CH);
      c.fillStyle = '#ffe9a8'; c.fillText(`${s.tr} (${s.cn})`, 6, y + 16); c.fillStyle = '#cfc4a8';
      c.fillText(`${Pet.D.templates[s.tpl].tr}${s.apk ? ' · APK' : ''}`, 6, y + 31);
      const sk = Pet.D.skills[s.skill]; c.fillText(sk ? sk.tr[0] : s.skill, 40, y + 54); if (icons[s.cn] && icons[s.cn].naturalWidth) c.drawImage(icons[s.cn], 6, y + 40, 28, 28);
      c.fillText(`${s.box} · ${s.eggs.join(',')}`, 6, y + 84);
      s.forms.forEach((f, i) => {
        const x = L + i * CW, sp = Game.map.sprite(f.look); c.strokeStyle = '#5a4d3c'; c.strokeRect(x + 1, y + 1, CW - 2, CH - 2);
        if (sp.ok) { c.save(); c.beginPath(); c.rect(x + 2, y + 2, CW - 4, CH - 22); c.clip(); sp.draw(c, 2, 0, x + CW / 2, y + CH - 26); c.restore(); } else { c.fillStyle = '#f66'; c.fillText('YOK', x + 30, y + 50); }
        c.fillStyle = f.cn !== s.cn ? '#ffd040' : '#cfc4a8'; c.fillText(f.tr.slice(0, 15), x + 4, y + CH - 6);
      });
    });
    return cv.toDataURL('image/png');
  });
  require('fs').writeFileSync(process.env.OUT || '/tmp/evcil_kolaj.png', Buffer.from(url.split(',')[1], 'base64'));
  console.log('HATA', errs); await b.close();
})();
