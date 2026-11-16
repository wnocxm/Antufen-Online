# 03 · İstemci (www/)

Saf JS, derleme yok. `www/index.html` betikleri şu sırayla yükler (önbellek kırıcı `?v=SÜRÜM`):
`audio.js assets.js i18n.js i18n_data.js tr.js tr_scenes.js quests_gen.js world.js game.js net.js forms.js win.js ui.js`.
Mantıksal ekran yüksekliği `VH = 360` (genişlik orana göre). Hata ayıklama için `window.__G = Game`.

## Dosyalar ve sorumlulukları
| Dosya | İçerik |
|---|---|
| `assets.js` | `Assets`: `data.json`, `ani.json`, `pal.bin` yükler. `Sprite(adı)` → `draw(ctx, anim, t, x, y)`, `animLen`, `anims`. Paletli sayfa tuvali `sheet()`; `this.glow` = ışık ekleme (`lighter`) ile çizim. `Paperdoll` (karakter katmanları). `preload(adlar)` |
| `world.js` | `GameMap`: izometrik kare 42×22 (`TW`, `HW/HH`), `px/py` ↔ `toCell`, `blocked`, bölgeler; `findPath` A* (4 komşu) |
| `game.js` | Oyun mantığı: veri tabloları, kayıt, varlıklar, savaş, beceri, efekt, eşya, görev, GM, otomatik yol, `update` döngüsü |
| `ui.js` | `UI`: başlık ekranı (orijinal ana menü), karakter oluşturma, çevrimiçi giriş, HUD (minimap, 6 yuvarlak harf düğmesi, joystick, yay biçimli beceri düğmeleri, büyük saldırı/konuşma düğmesi), sohbet, GM paneli, `toast/log/float`, `Input` |
| `win.js` | `Win`: tuvalde çizilen pencereler (APK tarzı): `hub, bag, role, npc, task, skill, shop, dead, sys, map, menu`. Ortak yardımcılar `nBegin/nEnd/nTabs/nText/nActions`. `Win.open(ad, seçenek)` |
| `forms.js` | `Forms`: `forms.json` (Symbian) + `forms2.json` (APK, anahtar `n_` önekli) arayüz formları; `img(id, res)` → `assets/ui2/` |
| `net.js` | `Net` (giriş, karakterler, 4 sn'de bir kayıt, WebSocket) ve `Remote` (diğer oyuncular) — bkz. 05 |
| `audio.js` | `SFX`: 12 APK müziği (`assets/music/*.mp3`, döngü uzunlukları `LOOP`), ses efektleri, sentez yedeği |
| `i18n.js`, `i18n_data.js` | `LANG` ('tr'/'en'), `tx(metin)` Türkçe → İngilizce (`EN_UI`), `EN_ITEM`, `EN_SKILL`, `EN_Q` (elle görevlerin İngilizcesi) |
| `tr.js` | `TR.name` / `TR.scene` ad çevirileri, `trName(cn)`, NPC selamları, **elle yazılmış ilk görevler** (`QUESTS`) |
| `tr_scenes.js` | Üretilmiş ad çevirileri (`tools/ceviri.py`): harita adları + `N` sözlüğü + görev dosyalarındaki `adlar` + `kaynak/ceviri/adlar/*.json` (görevsiz genel adlar: `sehir_alan`, `zindan`, `ust_60_77`, `ust_80_120`). Yeni ad eklerken bu dosyalara yaz; denetim: `node tools/test/adlar.js` |
| `quests_gen.js` | Üretilmiş görevler (`tools/gorevler.py`) — bkz. 04 |

## Zaman, hareket
`TICK = 14` kare/sn animasyon zamanı, `STRIDE = 66`, `RUN = 4.2` kare/sn. Hareket yalnızca 4 yön (`snapScreen4`).
Boş yere dokunmak **yürütmez** (`tapWorld`); NPC'ye ilk dokunuş hedef alır, ikinci dokunuş/konuşma düğmesi `talkTo` (yanına yürüyüp konuşur).
Otomatik yol: `routeTo(sid)` sahneler arası (`scenePath`), `routeToNpc(cn)`, `walkToEnt`; görev penceresindeki "Yol Bul".

## Veri ve kayıt
- `data.json`: `scenes[sid] = {name, map, lv, lvr:[min,max], exits:[[bölge, ad, hedefSid]], ents:[[id, ad, konum]], music, kind}`, `cit` (NPC), `mon` (canavar), `reg` (görsel kayıt), `palidx`.
- Kayıt (`SAVE_KEY = 'anrufen_save_v1'`, `newSave`): `{v, name, cls, race, sex, lv, xp, gold, hp, mp, gear, eq, bag:[{id,n}], quests:{id:{n,ready}}, done:{id:true}, qitems, scene, x, y, quick, sk:{becerId:kademe}, sp, flags, home}`. `fixSave` eski kayıtları düzeltir. Çevrimiçiyse `save()` → `Net.save`.
- Başlangıç: insan `120207`, elf `120205` (acemi kampları).

## Savaş
- `stats()` sınıf tabanı (`CLS[cls]`: hp, mp, atk, def ve seviye artışları) + ekipman + pasif beceriler + bufflar.
- `dmgCalc(atk, def, mult, critBonus, add)`: `(atk·mult+add)·rnd(0.92..1.08)·1000/(1000+3·def)`, kritik %8+bonus.
- `xpNeed(l) = (40·l^1.85 + 20)·(1 + 1,5·clamp((l−10)/30, 0, 1))` (10'a kadar hızlı, 40'tan sonra ×2,5). `gainXp` seviye atlatır, yeni açılan görevleri günlüğe yazar (`questsUnlockedAt`).
- Görev deneyimi: öldür/topla `(adet·canavarTP·1,6 + 60·L)·QXP_F(L)`, konuşma `(80 + 50·L)·QXP_F(L)`; `QXP_F = clamp(1,2 − L/40, 0,3, 1)`. (APK'daki `exp` ödülleri seviyeden bağımsız ~300 yer tutucu, kullanılmıyor.)
- Canavar değerleri (`Mob`): TP `(250+260·L)`, saldırı `48 + 27·L + 0,15·L²`, savunma `8·L`; seçkin ☆ ×3 TP ×1,15 saldırı (×1,5 savunma), patron ☆☆ ×18 TP ×1,8 saldırı.
  Sınıf tabanı: savaşçı 1200 TP (+180/sv), büyücü 1000 (+140), elçi 1050 (+150).
- **Denge ölçümü**: `tools/test/denge.js` (RACE=人类|精灵, GRIND=0: kasmasız; seviye seviye görev/öldürme/kasma), `tools/test/savas.js` (her sınıf, seviyesindeki normal ve ☆ canavara karşı süre ve kayıp can). 1. tur sonucu: normal canavar 3-7 sn, %2-24 can; seçkin 11-33 sn, %7-82 can; bütün sınıflar potsuz kazanıyor.
- Canavar seviyesi `monDef(ad, sahne)`: elle `MON` tablosu (sahne aralığına kıstırılır) ya da otomatik: sahnenin `lvr` aralığına göre; ☆ = seçkin (+1, ×3 TP), ☆☆ = patron (+2, ×25 TP). TP `(4+5·lv)·(25|3|1)`.
- Normal saldırı: savaşçı yakın dövüş; büyücü/elçi mermi (`C.bolt`) + çarpma efekti (`C.boltHit`) + `skill_bomb` sesi.
  Orijinal sınıf tablosuna göre normal saldırı = ilk beceri: büyücü 火球术 (火球→火爆炸), elçi 暗影冲击 (暗影冲击_红→冲击爆炸).

## Beceriler ve efektler
- `CLS[cls].skills[]`: `{id, name, icon, mp, cd, mult|pct|add, range, proj, hit, self, fx, fx2, aoe, splash, hitN, projN, buff, dur, healT, hotT, dot, slow, crit, pas, lv, desc}`. Kademe tabloları (`add/pct/healT…`) 10 elemanlı; `skT(sk, alan)`.
- `useSkill(i)`: `self` efekti oyuncuda; 0,25 sn sonra `proj` mermisi (`shoot`) → `land()` (hasar, `hit` efekti; `hitN` adet efekt hedef çevresine saçılır), `aoe` (`projN` varsa her canavara N mermi), şifa, buff.
- **Efekt verisi**: APK `effect_data.godat` → `kaynak/apk/efekt_beceriler.json`. Her beceride `draw_effect_self` (oyuncu), `draw_effect_target` (**uçan mermi**), `draw_effect_track` (**hedefteki çarpma**); `type` = adet, `offset_y` = saçılma yarıçapı. Becerileri buna göre ayarla.
- **Çizim**: efekt resimleri siyah zemin üstünde; APK "glow" malzemesiyle ekler → bizde `Fx` sprite'ı `glow = true`, `globalCompositeOperation = 'lighter'`. Hangi animasyonun oynayacağı `fxAnim` (birden çok karesi olan animasyon; yönlüyse oyuncu yönüne göre).
- `Fx(name, x, y, {anim, dir, z, follow, loop})`; mermi `f.proj = {to, cb, sp:9, vis}`.

## Eşyalar ve dükkânlar
`www/assets/items.json` (169 eşya, `tools/esyalar.py`): `{name, en, slot, cls, lv, price, sell, icon:[tür, no], st:{atk…}, use:{hp|mp|hot:[kaynak, miktar, sn]}, gfx}`; `shops[npc] = [[sekme, [id…]]]`.
`equip/unequip/buyItem/sellItem/useItem/addItem`; görev ödülündeki bilinmeyen eşya kimlikleri atlanır.

## GM
`isGM()`: çevrimdışı adı "GM" ile başlayan karakter; çevrimiçi `Net.admin` (sunucuda `node make-admin.js <kullanıcı>`).
`gmLevel(lv)`, `gmGear()`, `gmHeal()`, `Game.god` (ölümsüz), `Game.fast` (×2,6 hız); GM paneli + NPC listesi (`#gm`), dünya haritasından ışınlanma. Sunucu "GM" önekli adı yönetici olmayana vermez.

## Arayüz notları
- Başlık ekranı orijinal ana menü (logo, kitap çerçevesi UIData_2033, sarı oklar): Devam Et / Yeni Karakter / Çevrimiçi / Dil.
- HUD: çerçeveli minimap (`ui2/hud_frame.png`), 6 yuvarlak harf düğmesi (`ui2/hud_btn.png`): Karakter, Çanta, Beceri, Görev, Harita, Sohbet/Ayarlar.
- Dünya haritası: `assets/wm/` (world.jpg, r1..r7.jpg bölge resimleri, `wm.json`): dünya → bölge → yerel; Otomatik Yol, NPC Listesi.
- Pencere açıkken oyun güncellenmeye devam eder (`update` hep çalışır).

## Zindanlar (`www/js/dungeon.js`)
- `DUNGEONS`: `{id, cn, lv, lvr, train, daily, board, boss, copies:[{door:[alanSahnesi, geçitBölgesi], scenes:[…]}]}`. Irk başına ayrı kopya olabilir (Sınav Ormanı, Mehtap Korusu: insan + elf girişi).
- **Kapılar**: alan haritalarındaki, geçit tablosunda karşılığı olmayan tür 1 bölgeler (APK geçit tablosu boş/kendine bağlamış). `checkExits` → `Dungeon.door(bölge)` → onay kutusu (`Win.ask`, pencere açık olmadan da çalışır) → `enter`.
- **Koşu** `P.dun = {id, copy, cleared:{sahne:varlık:sıra}, boss, t}` kayıtta durur; harita yüklenince `onLoad` (zindandaysa koşu yoksa açar, dışarıdaysa kapatır). Normal zindanda kesilen canavar `cleared`a yazılır ve yeniden doğmaz (`skip`), sınav zindanında yeniden doğar.
- **Canavar**: zindan sahnelerinin `lvr`'si tanımdan; sınav canavarı ×0,7 can ×0,6 saldırı ×0,5 savunma (pano: "zayıf saldırı ve savunma"); boss = ★/☆☆ ya da orijinal `instance_progress` işaretli (101 canavar) → alan boss'unun ×18/×1,8'i yerine ×8 can ×1,2 saldırı (tek kişilik). `★` adlı canavarlar artık boss sayılır (`monDef`).
- **Boss sandığı** (son boss, `d.boss` ya da ilk boss): 40·sv altın, 1-2 ekipman (`randomGear(sv+2)`), 3 iksir; sonra "çıkılsın mı?". Çıkış geçidi ya da ölüm → kapının dışına (`arrivalNear`), koşu kapanır.
- **Günlük sınır** `P.dg = {day, n:{id:adet}}` (normal zindan 3/gün; sınav sınırsız).
- Veri düzeltmesi `fixMonData`: ☆☆【小胖】拉斯 kaydında görünüm/ölüm efekti alanları ters.
- `arrivalNear(regs, geçit)`: geçidin varış bölgesi geçit+1 değilse en yakın tür 0 bölge (önceden oyuncu çıkış bölgesinin üstüne doğuyordu).
- Test: `tools/test/zindan.js` (giriş/çıkış/sandık/sınır/ölüm), `BOSS='sahne:ad:sv;…' node tools/test/savas.js` (boss dövüşü, iksirli). Sonuç: Lars (Sv 20) ve ★Mehtap Kurt Kralı (Sv 30) üç sınıfla da yeniliyor, %43-59 can, 0-4 iksir.
