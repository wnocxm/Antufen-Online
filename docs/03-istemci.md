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
**Hedef ve saldırı ayrı** (kullanıcı isteği):
- Canavara ilk dokunuş yalnız seçer (`setTarget(e)`). Seçili canavara ikinci dokunuş, saldırı düğmesi (`UI.attack`), bir beceri ya da görev yürüyüşü saldırıyı başlatır (`setTarget(e, true)` → `Game.engage`).
- Yön tuşu/joystick `Game.engage`'i kapatır; hedef seçili kalır, oyuncu kendiliğinden geri dönmez.
- Yaklaşırken engelli karede takılırsa (`p.chaseD` ilerlemiyorsa) ve menzil +0,6 içindeyse olduğu yerden vurur.
**Geçilebilirlik:** NPC'ler yolu kapatmaz, içlerinden geçilir (kullanıcı bildirdi; dar yolda/kapıda takılıyordu). Yalnız sabit toplama nesneleri (maden kayası, kalıntı) durdukları kareyi kapatır (`map.extraBlock`).
- Test: `tools/test/hedef.js`. Test betikleri saldırı için `setTarget(m, true)` kullanır.
Otomatik yol: `routeTo(sid)` sahneler arası (`scenePath`), `routeToNpc(cn)`, `walkToEnt`; görev penceresindeki "Yol Bul".
**Görev yol bulma (`questWalk`)** görevin durumuna göre gider:
- Alınmamış görev → görevi veren.
- Hazır görev (ya da konuş / teslim / özel görev) → ödülü veren kişi (`q.to`).
- Öldür/topla görevi:
  - Bu haritada yaşayan hedef varsa yanına yürür ve hedef olarak seçer; **saldırmaz** (kullanıcı isteği). Çok hedefli görevde bitmemiş hedefler.
  - Hepsi ölüyse doğdukları yere yürür.
  - Yoksa canavarın en yakın haritasına gider; görevdeki harita adı `q.sc` önceliklidir (`monSceneNear(ad, sc)`).
- Nesne toplama → nesne ya da nesnenin haritası.
- Başka haritaya gidince varışta görev yürüyüşü kendiliğinden sürer (`Game.routeQuest`); yön tuşu bunu iptal eder.
- Test: `tools/test/yolbul.js`.

## Veri ve kayıt
- `data.json`: `scenes[sid] = {name, map, lv, lvr:[min,max], exits:[[bölge, ad, hedefSid]], ents:[[id, ad, konum]], music, kind}`, `cit` (NPC), `mon` (canavar), `reg` (görsel kayıt), `palidx`.
- Kayıt (`SAVE_KEY = 'anrufen_save_v1'`, `newSave`): `{v, name, cls, race, sex, lv, xp, gold, hp, mp, gear, eq, bag:[{id,n}], quests:{id:{n,ready}}, done:{id:true}, qitems, scene, x, y, quick, sk:{becerId:kademe}, sp, flags, home, adv}` (`adv`: sınıf yükseltme). `fixSave` eski kayıtları düzeltir (sınıf yükseltilmemişse sınıf ağacı puanlarını geri verir). Çevrimiçiyse `save()` → `Net.save`.
- Başlangıç: insan `120207`, elf `120205` (acemi kampları).

## Savaş
- `stats()` sınıf tabanı (`CLS[cls]`: hp, mp, atk, def ve seviye artışları) + ekipman + pasif beceriler + bufflar.
- `dmgCalc(atk, def, mult, critBonus, add)`: `(atk·mult+add)·rnd(0.92..1.08)·1000/(1000+3·def)`, kritik %8+bonus.
- **Deneyim sistemi** (kullanıcı kararı 16.11: "orijinal + %40 görev"):
  - **Görev deneyimi orijinal** (`q.rw.xp`, Symbian ham kaydı). Orijinalde görevlerin yaklaşık dörtte biri 0 deneyim verir.
  - Seviye tablosu `XPT[L]` (L → L+1) ve normal canavar deneyimi `MXPT[L]`, `tools/deneyim_tablosu.py` ile üretilir (girdi: `JSON=… tools/test/gorev_seviye.js`); orijinalleri sunucudaydı.
    - Kural: o seviyeye kadar açılan görevlerin orijinal deneyimi gereken toplamın ~%40'ı, canavarlar ~%60'ı.
    - Eğri: 5 seviyelik dayanaklar, tekdüze artan artışlar, seviye başına en az %3 büyüme.
    - Başlangıç kampı görevleri en az 2. seviyeye çıkarır (`KAMP`).
    - Seviye başına normal canavar sayısı: 20'ye kadar 48 → 200 ısınma, sonra 200.
    - Ölçek `OLCEK` gerçekçi benzetimle ayarlanır.
  - Örnek `XPT`: 1: 670, 10: 5.440, 20: 7.930, 30: 86.500, 40: 395.000, 50: 531.000.
  - Örnek `MXPT`: 1: 8, 20: 31, 30: 260, 40: 1.180, 50: 1.590.
  - `xpNeed(l) = XPT[l]`; canavar `mobXp(lv, rank)` = `MXPT` × (seçkin 3, boss 25) × seviye farkı `clamp(1+0,1·fark, 0,2, 1,5)`. Elle yazılmış `MON` deneyimleri kullanılmaz.
  - Ölçüm (`GRIND=1 tools/test/denge.js`, hedef öldürmeleri dahil):
    - Görev payı insan %39, elf %38.
    - Seviye başına ortalama ~100 öldürme (en çok ~300).
    - 55'e kadar toplam ~5.000 öldürme (eski sistemde ~7.400, çoğu 40 sonrası kasmaydı).
  - `gainXp` seviye atlatır, yeni açılan görevleri günlüğe yazar (`questsUnlockedAt`).
- Canavar değerleri (`Mob`): TP `(250+260·L)`, saldırı `48 + 27·L + 0,15·L²`, savunma `8·L`; seçkin ☆ ×3 TP ×1,15 saldırı (×1,5 savunma), patron ☆☆ ×18 TP ×1,8 saldırı.
  Sınıf tabanı: savaşçı 1200 TP (+180/sv), büyücü 1000 (+140), elçi 1050 (+150).
- **Denge ölçümü**: `tools/test/denge.js` (RACE=人类|精灵, GRIND=0: kasmasız, varsayılan kasmalı; seviye seviye görev/hedef öldürme/kasma), `tools/test/savas.js` (her sınıf, seviyesindeki normal ve ☆ canavara karşı süre ve kayıp can). 1. tur sonucu: normal canavar 3-7 sn, %2-24 can; seçkin 11-33 sn, %7-82 can; bütün sınıflar potsuz kazanıyor.
  - 2. tur (17.11, sınıf ağacı 40'a çekilince): 10-39 arası yalnız acemi ağacı. Rahibin şifası 40'a kaldığı için seçkinlerde %96'ya çıkan kayıp, rahip tabanı `ghp 165, gatk 13, gdef 7` ile en çok ~%84'e indi; savaşçı seçkin ≤%62, büyücü ≤%74; 40 sonrası (sınıf ağacıyla) rahip seçkin %24-45. `ADV=0` ile sınıf görevi hedefleri 40'ta acemi ağacıyla: hepsi iksirsiz kazanılıyor (%36-59).
  - 3. tur (18.11, orijinal beceri sayıları + gerçekçi puan dağıtımı): Beceri ağaçları › Denge.
- Canavar seviyesi `monDef(ad, sahne)`: elle `MON` tablosu (sahne aralığına kıstırılır) ya da otomatik: sahnenin `lvr` aralığına göre; ☆ = seçkin (+1), ☆☆ = patron (+2). Deneyim `mobXp` (yukarıda).
- Normal saldırı: savaşçı yakın dövüş; büyücü/elçi mermi (`C.bolt`) + çarpma efekti (`C.boltHit`) + `skill_bomb` sesi.
  Orijinal sınıf tablosuna göre normal saldırı = ilk beceri: büyücü 火球术 (火球→火爆炸), elçi 暗影冲击 (暗影冲击_红→冲击爆炸).

## Beceriler ve efektler
- `CLS[cls].skills[]`: `{id, sn, mp, cd, range, f(K,s,p,t), pas, buff, dur, heal, toggle}` + efekt alanları (aşağıda). Kademe değerleri `skills.json`'dan (`K('sabit')`).
- `useSkill(i)`: `self` oyuncuda; 0,25 sn sonra `proj` mermisi (`shoot`) → `land()` (hasar + `hit`), `aoe` (oyuncu çevresi), şifa, buff. GM beklemesiz kipte (`Game.gmNoCd`) bekleme/mana yok.
- **Efekt alanları** (her biri orijinal tablodan; `tools/test/efekt.js` hepsini oyunda çeker):
  - `self` / `selfN` / `selfR`: oyuncudaki efekt, kaç kez, kaç piksel saçılarak (`fxBurst`). Yakın dövüşte (`p.state === 'attack'`) 2 kare (2/TICK sn) geç başlar: kılıç izi hareketin inişine denk gelir.
  - `proj` / `projN`: uçan mermi ve sayısı (0,12 sn arayla). `hit` / `hitN` / `hitR`: hedefteki çarpma; çok mermide her mermi kendi payını patlatır (`ceil(hitN/projN)`). `splash`: hasar alanı (kare); görsel saçılma `hitR` ile ayrı.
  - `fx`: eski tek efekt (şifa `LIGHT_ATTACK`, alan `冰霜新星`, hedef efekti `hit` yoksa). `fx2`: hedefte ikinci efekt (Çifte Darbe `BLOOD`).
  - `bfx`: güçlendirme süresince karakterde dönen efekt (`b.fx` → `auraSync`). `totem`: yere konan çağrılmış nesne (`totemAt`, süre `life`).
- **Kaynaklar**:
  - APK `effect_data.godat` → `kaynak/apk/efekt_beceriler.json`: `draw_effect_self` (oyuncu), `draw_effect_target` (**uçan mermi**), `draw_effect_track` (**hedefteki çarpma**); `type` = adet, `offset_y` = saçılma yarıçapı (px). Ayrıca `range`, `target_type` (1 tek hedef, 0 alan/kendisi), `action_id`.
  - Symbian `all_skill` kaydındaki efekt ve ses adları; çelişkide Symbian (ör. 90134 Ayaz Halkası: APK satırı 90128'den kopya, Symbian `特效-冰霜新星`; 90127 Alev Yakışı: Symbian "yakın, tek hedef", APK "uzak").
  - **Güçlendirme/zayıflatma görselleri**: Symbian `all_buff` + APK `config/1021.txt` (buff → simge → efekt). Beceri → buff numarası `skill_const_2nd.lua`'da (ör. yavaşlama 210148, Gözdağı 210146, İlahi Öfke 210144).
  - **Çağrılan nesneler** `all_monster`: 70886 威慑图腾 → `特效-神之威慑` (İlahi Gözdağı totemi), 70472 治疗之泉 → `特效-治疗之泉` (Şifa Pınarı: yerde durur, yalnızca 3 kare içinde iyileştirir, `b.at`), 71274 魔法幻象 → `怪物-魔法幻象` (Büyü Hayali: oyuncunun yanına dikilen yeşil totem, mermiler ondan çıkar; canavar görseli, ışık değil).
- **Süren etkiler** (`auraSync(ent, {anahtar: efekt})`, her karede): oyuncuda `p.buffs[].fx`; canavarda yavaşlama → `特效-缓缓加蓝`, Gözdağı (`weakDef`) → `特效-抗性衰减buff`, donma (`rootT`) → `特效-冻结`. Ölünce / etki bitince / harita değişince kalkar ya da yeniden kurulur. Kanama, yanma, Çürüme buff'larında orijinalde efekt yok (210153, 210428, 210143).
- **Beceri → efekt tablosu** (orijinal; ✓ = önceden de doğruydu):
  - Savaşçı: Temel Kılıç `BLOOD` ✓ · Güçlü Savurma iz `刀光-红` + `BLOOD`×2 · Bıçak Fırlatma ✓ · Çifte Darbe ✓ · Hız Patlaması `特性-聚气` + süren `特效-加速` · Ruh Yaran ✓ · Kan Damgası 聚气 + `鲜血印记` · İntikam Kılıcı iz ×5 + `RELIVE` · Karşı Saldırı Fırtınası 聚气 + `反击风暴` · Testere Bıçak iz ×3 + `BLOOD`×5 · Ağır Yarık hedefte `特效-狂暴BUFF` · Öfke Hiddeti 聚气 + `狂暴之怒`.
  - Büyücü: Ateş Topu ✓ · Dondurma ✓ (+ canavarda mavi) · Şifa ✓ · Alev Yakışı `FIRE_ATTACK`×3 mermi + `火爆炸`×3 (tek hedef, menzil 3) · Büyü Kalkanı süren `弱化术` · Kar Fırtınası `冰块碎裂`×10 r50 · Mana Halesi efektsiz · Alev Darbesi `FIRE_ATTACK2`×3 + ×10 r30 · Ayaz Halkası ✓ · Element Bağışı 聚气 + `元素赐生` · Büyü Darbesi ✓ (ses `skill_wind`) · Büyü Hayali totem · Evre Kayması 聚气 + `神圣之盾`.
  - Kutsal Elçi: Gölge Darbesi ✓ · Çürüme ✓ · İlahi Gözdağı totem + canavarda `抗性衰减buff` · Şifa Pınarı yerde pınar · Gölge Yakışı ✓ · Kutsal Işık `缓缓加红`×40 r180 · İlahi Öfke `狂暴BUFF`×40 r180 + süren `神努buff` · Kutsal Akış 聚气 ✓ · Kutsal Nova `细碎爆炸`×5 r80 · Işık Siperi süren `圣光壁垒` · Gölge Vebası ✓ · Karanlık Ahit 聚气 + `黑暗契约` · Gölge Hükümdarı `治疗buff` + süren `缓缓加红` · Kutsanmış Beden (tetik) efektsiz, Zifiri Perde süren `漆黑之幕`.
- **Çizim**: efekt resimleri siyah zemin üstünde; APK "glow" malzemesiyle ekler → bizde `Fx` sprite'ı `glow = true`, `globalCompositeOperation = 'lighter'` (`{glow:false}` canavar görselli nesneler için).
- **Animasyon seçimi `fxAnim`**: 0. animasyon tek karelik boş duruştur; çok kareli tek animasyon varsa o; tek kareli efektlerde 1. animasyon (buz kalıbı `特效-冻结`: 0 boş, eskiden hiç görünmüyordu). **8 yuvalı yönlü efektler** (`特效-刀光`, `刀光-红`, `BLOOD`, `疾风斩`): tek yuvalar 4 çapraz yön, (1,5) ve (3,7) birbirinin yatay aynası, 1 ve 3 sağa bakar → yön (0 sağ-yukarı, 1 sağ-aşağı, 2 sol-aşağı, 3 sol-yukarı) → yuva `FX8 = [1, 3, 7, 5]`.
- **Çevrik parçalar (`drawParts`, assets.js)**: parça bayrağı bit0 yatay, bit1 dikey ayna. Aynalı parçada `x` sağ kenarı, **dikey çevrilmiş parçada `y` alt kenarı** gösterir (`top = py - h`). Eskiden üst kenar sayılıyordu: kılıç izi karakterin ~100 px altında çıkıyordu; aynı hata Kan Büyü Çemberi (`OBJECT_鲜血魔法阵`), halılar (`GROUND_地毯`) ve 审判者之剑 canavarlarını (monster58) yarım/dağınık çiziyordu.
- `Fx(name, x, y, {anim, dir, z, follow, loop, ox, oy, glow})`; mermi `f.proj = {to, cb, sp:9, vis}`; `f.life` sn sonra biter.

## Beceri ağaçları (orijinal; 18.11 bütün ağaçlar)
**Veri:** `www/assets/skills.json` ← `tools/beceriler.py` (elle değiştirme). Kaynaklar orijinal Symbian istemcisi:
- `all_skilltree.godat`: ağaç → 6 beceri ve sütunu; ırk ağaçları 2 beceri.
- `all_skill.godat`: ad, açıklama şablonu, simge, en yüksek kademe (10/15), **ön koşul** (beceri + kademe), **ağacın kök şartı** (önceki ağaca harcanan puan + sınıf), dışlayan uzmanlık kökü, bekleme.
- `kaynak/cikti/betik/clt_script/skill_const_2nd.lua` (GBK): her becerinin kademe sabitleri (`TABLE_SKILL_CONST[sn]`); dosyada eski tasarımlar da var, sonraki tanım öncekini ezer.
- Çeviri: `kaynak/ceviri/beceriler.json` (ad + açıklama şablonu `{sabit}`, `{cd}`, `{mp}`; ağaç adları; 4 mesleğin 5 kademesi).

| Sınıf | Acemi | Sınıf ağacı | Uzmanlık A | Uzmanlık B |
|---|---|---|---|---|
| Savaşçı | 见习 150008 | 战士 150009 | 嗜血 Kana Susamış 150010 | 狂暴 Öfke 150011 |
| Büyücü | 学徒 150014 | 法师 150015 | 元素 Element 150016 | 奥术 Gizem 150017 |
| Rahip | 初级 150022 | 神使 150023 | 神圣 Kutsal 150024 | 暗影 Gölge 150025 |

**Orijinal kurallar** (`skLock(sk)` → `null | [tür, açıklama]`; tür `adv`, `pts`, `excl`, `pre`):
- Seviye şartı yok; puan seviye başına 1 (+ başlangıçta 1).
- Ön koşul: 3. ve 4. beceri 1.'nin, 5. beceri 3.'nün, 6. beceri 4.'nün **5. kademesini** ister. Uzmanlıklarda 2. beceri kökün 1. kademesini ister.
- Sınıf ağacı: 40'taki sınıf yükseltmesi (`P.adv >= 1`, 130004/130005/130011) **ve acemi ağacına 35 puan**.
- Uzmanlık: 80'deki ikinci yükseltme (`P.adv >= 2`, 黑骑士 Kara Şövalye 130006 / 大魔导师 Başbüyücü 130008 / 天选者 Seçilmiş 130012; iki uzmanlık da aynı sınıf) **ve sınıf ağacına 40 puan**. İki uzmanlığın kökü birbirini dışlar: birini öğrenen öbürünü alamaz.
- Puanları sıfırlama: **Eğitim Kitabı** (训练之书 30092, Symbian fiyatı 8750 altın, beceri eğitmenlerinde: 技能训练师 Guanlin / Kâhin Tapınağı). `skillReset(free)`.
- Irk ağacı (kendiliğinden, kademe 1): İnsan Ruhu (savunma +2×sv, mana +5×sv), Açgözlülük (altın +%10, görev altını dahil); Ruh Kutsaması (direnç +2×sv, can +8×sv), Yaşam Özütü (canavar %5 Yaşam Elementi 30127). Seviye artışları bizim (orijinal metin yalnız "seviyeyle artar" diyor). Eski düz ırk bonusu kaldırıldı.
- Kayıt: `fixSkills(s)` şartı tutmayan ya da kademesi aşan becerinin puanını geri verir (eski kurallarla alınmış beceriler).

**Pencere** (`drawSkill2`, `n_skilltree`, APK görüntüleri gibi): 6 sekme (acemi, sınıf, 2 uzmanlık, ırk, Yaşam); 6 kademeli yuva 50402-50407 (orta, sağ, sol, sağ, sol, sağ = ağaç kaydındaki sıra); turuncu çizgiler APK'daki sabit desen (1→3, 1→4, 3→5, 4→6); yuvada "Öğrenilmedi" / "Sv n"; kilitli ağaçta kök şartı yazar. Sağda seçili beceri: ad, kademe, açıklama (o kademenin değerleriyle, `skDesc`), "Sonraki: 20→40", şart (kırmızı), Yükselt / Kısayol. Altta beceri puanı ve **Puanları Sıfırla** (50430). Yaşam sekmesi 4 mesleği gösterir (`P.life[meslek]` kademe; öğrenme ve toplama sistemi sıradaki iş).

**Motor** (`CLS[sınıf].skills`): her becerinin `sn`'si ve oyundaki karşılığı. `f(K, s, p, t)` etkin becerinin sayıları (`K('sabit')` o kademedeki değer), `pas(K, s, sv)` edilgen, `buff(K, s)` + `dur`, `heal(K, s)`. Eski 36 becerinin kimlikleri korundu (kısayollar bozulmasın); yeni uzmanlık becerileri sona eklendi (kimlik = orijinal numara). 法力光环 Mana Halesi orijinalde etkin (dakikalarca mana sınırı), artık etkin.
- Yeni mekanikler: can emme (Kan Damgası), canın yüzdesi kadar saf hasar (İntikam Kılıcı), yansıtma (Karşı Saldırı Fırtınası), kanama katları ve yutma (Testere Bıçak / Ağır Yarık / Ölüm Kırımı), dönüşümler (savunma→saldırı, saldırı→savunma, mana→saldırı), yanma, dondurma/kök, yavaşlatma etkisi altına ek hasar, mana yüzdesiyle katlanan Büyü Darbesi, hayal totemi, mana kalkanı, mana→can (Karanlık Ahit), kanatlar (Gölge Hükümdarı: şifa/destek kapalı, çevreye % hasar), ölümcül darbeyi savuşturma, sersemletme, mühür (canavar saldıramaz), Zifiri Perde, şifa etkisi artışı.
- Orijinalde PvE etkisi olmayanlar da var: isabet (Mana Denetimi; canavarların kaçınması yok), Umutsuzluk Gücü (canavar şifası yok), Mutlak Alan (takım yok), Kutsal Akış (hasar türü ayrımı yok).
- **Denge** (orijinal sayılar + bizim sınıf tabanları): vuruş çarpanı `dmgK` savaşçı 1,25, büyücü 1,7, rahip 1,75 (eskiden büyücü/rahip becerilerinde ×1,5 vardı; orijinal "saldırı + ek" biçiminde). `tools/test/savas.js` puanları oyuncu gibi dağıtır (`skillAutoSpend`: acemi 35 → sınıf 40 → uzmanlık). 18.11 sonucu: 10-55 normal canavar 4-10 sn, seçkin 12-35 sn, kayıp can ≤%82 (büyücü 23☆ %81); 40-80 iki uzmanlıkla hepsi kazanıyor; zindan boss'ları 0-4 iksirle; 40. sınıf görevi hedefleri acemi ağacıyla iksirsiz.
- Uzmanlık becerilerinin mana bedelleri bizim (orijinal değerler sunucudaydı); bekleme süreleri kayıttan.
- **Simgeler** (18.11 denetim): her becerinin simgesi kendi kaydındaki yoldan (`icon_res_skill`, tam yolla, çakışma yok; 3 beceri eşya simgesi kullanıyor). APK'nın beceri tablosuyla adına göre karşılaştırıldı: 76 becerinin 75'inde yol aynı (治疗术 APK'da bu adla yok). Kullanıcının APK görüntüleriyle savaşçının 4 ağacındaki 24 simge tek tek gözle karşılaştırıldı: hepsi aynı.

## Eşyalar ve dükkânlar
- **Satın alma / satma adedi** (`win.js buyAsk`, `sellAsk`):
  - Ekipman tek tek, onay kutusuyla alınır.
  - Yığılabilen her eşyada adet penceresi (`n_selnum`) açılır; en fazla altının yettiği kadar (≤999).
  - Satarken birden çok varsa adet sorulur.
  - Sayıya dokununca ekranın üstünde sayı klavyeli HTML kutusu (`#numin`) açılır.
  - Bilgisayarda pencere açıkken rakamlar sayıyı yazar, ↑/↓ bir artırıp azaltır, Enter onaylar, Esc kapatır (`Win.key`). Açık kutu varken tuşlar oyun kısayollarına gitmez.
`www/assets/items.json` (169 eşya, `tools/esyalar.py`): `{name, en, slot, cls, lv, price, sell, icon:[tür, no], st:{atk…}, use:{hp|mp|hot:[kaynak, miktar, sn]}, gfx}`; `shops[npc] = [[sekme, [id…]]]`.
`equip/unequip/buyItem/sellItem/useItem/addItem`; görev ödülündeki bilinmeyen eşya kimlikleri atlanır.

## GM
`isGM()`: çevrimdışı adı "GM" ile başlayan karakter; çevrimiçi `Net.admin` (sunucuda `node make-admin.js <kullanıcı>`).
`gmLevel(lv)`, `gmGear()`, `gmHeal()`, `Game.god` (ölümsüz), `Game.fast` (×2,6 hız); GM paneli + NPC listesi (`#gm`), dünya haritasından ışınlanma. Sunucu "GM" önekli adı yönetici olmayana vermez.
**Kural: her yeni sistem kendi GM komutlarıyla gelir** (modülde `GM` nesnesi + panelde sekme/düğme + `tools/test/gm.js`'e adım).
Panel nasıl açılır: sol menünün (karakter menüsü) en altındaki **GM** düğmesi. 7 düğme ekranı doldurduğu için GM ilk açılışta görünmez; menü sayfa gibi parmakla yukarı sürüklenir (bilgisayarda fare tekerleği) ve GM gelir. GM olmayan karakterde menü 7 düğmedir, kaymaz.
Panel yazıları seçili dilde: sekme adları, arama kutusu ve satırlar (`GT(tr, en)`); `DIL=en node tools/test/gm.js` çevrilmeden kalan Türkçe yazıları da listeler.
Sekmeler (`#gtools` `v:maps|dg|pet`, `drawGmSys`, `gmX` in `ui.js`):
- **Haritalar**: haritaya ışınlan (arama), NPC listesi.
- **Zindanlar** (`Dungeon.GM`): her zindan/kopya için "Kapıya git", "İçeri gir" (seviye, ön görev, günlük sınır yok; sayaç artmaz); bu harita için "Boss'u öldür", "Canavarları öldür", "Son kata / başa", "Zindandan çık", "Günlük hakları sıfırla".
- **Sınıf** (`ClassGM`, game.js): beceri efektleri satırı ("Kukla canavar": yanına ölmeyen, kıpırdamayan, saldırmayan canavar, hedef seçili; "Beklemesiz beceri" aç/kapa: bekleme ve mana yok, `Game.gmNoCd`); durum satırı ("Sınıfı yükselt", "İkinci yükseltme (80)", "Acemiye döndür": şartı tutmayan beceriler geri + zincir sıfırlanır, "40 yap + ilk görev"); beceri ağaçları satırı ("Puanları sıfırla (bedava)", "Ağaçları doldur" 1./2. uzmanlık: en az 80, iki yükseltme, puanlar oyuncu gibi dağıtılır); oyuncunun sınıf/ırk zincirindeki her görev için "Hazır yap", "Bitir" (öncekileri de bitmiş sayar), "Git" (görev yürüyüşü). Test: `tools/test/gm.js`, `tools/test/sinif.js`.
- **Evcil** (`Pet.GM`):
  - Her tür için "Hayvanı ver" (doğrudan kuluçka, hak doluysa hak artar) ve "Yumurta + kutu".
  - Üstte "Pencereyi aç", "Seviyeme çek", "Dirilt + doyur + iyileştir", "Evcil eşyaları ver" (mama, iksir, diriltme, Sözleşme Taşı, İç Öz, kutular), "Acıktır" (aç hayvan savaşmaz testi), "Hepsini sil".
  - **Dönüşüm ağacı** satırı: "Sonraki biçim" / "Temel biçim" (`stage`), "3 rastgele beceri" (`skills`), "Dönüşüm malzemesi" (`tf`: yardımcı eşyalar, aynı türden 2 yardımcı hayvan, 20000 altın), "Dönüşüm penceresi" / "Beceri aktarma" (`petf` / `petfs`).
Test: `tools/test/gm.js` panel düğmelerine gerçekten basar (görüntüler `OUT_zindan.png`, `OUT_evcil.png`, `OUT_panda.png`, `OUT_atesdevi.png`, `OUT_aktarma.png`, `OUT_sinif.png`; Ateş Devi'nin 8 biçimini sırayla geçer).

## Arayüz notları
- **Yazı tipleri** (18.11, kullanıcı isteği: "Excel/Word gibi duruyor, oyun havası yok"): `www/assets/fonts/` (SIL OFL, @fontsource; latin + latin-ext dosyası birlikte: ç ö ü temel Latin'de, ğ ş İ genişletilmiş Latin'de). `forms.js` başındaki `FH` / `FB` değişkenleri, `loadFonts()` açılışta yükler.
  - `FH` başlık: **Metamorphous** — sol menü, sekmeler, düğmeler, pencere başlıkları (13 px ve üstü `nText`), duyuru, harita adı. `Forms.btnText`: kalın, altın-parşömen dolgu, koyu kahve dış çizgi.
  - `FB` gövde: **Alegreya** — parşömen yazıları, listeler, açıklamalar, HUD, HTML paneller (`style.css`).
  - Denenip elenen: Cinzel (küçük harfi büyük harf gibi çiziyor, Türkçede i/ı ayrımı kayboluyor), Marcellus, Almendra, MedievalSharp, Grenze Gotisch. Değiştirmek için `FH`/`FB` ve `fonts.css`.
  - Eski "çift yazı": yazının altına 1 px kaydırılmış siyah kopya çiziliyordu (sekmelerde ayrıca açık renkli ikinci kopya). Artık tek kalem + dış çizgi (`Forms.label`, `Forms.btnText`).
- Simgeler `drawIcon` ile yumuşatmasız (orijinal pikseller net).
- Sol menü (`drawHub2`, `n_v5_menu`): `hubItems()` listesi 7'den uzunsa (GM) kaydırılır. `HUB.y` kaydırma (form birimi), `HUB.r` ekrandaki alan; `Win.drag` sürükleme ve `ui.js`'teki tekerlek olayı kaydırır; düğmeler 8-312 bandına kırpılır, aşağıda/yukarıda düğme varsa küçük ok çizilir. Menü kapalıyken açılınca başa döner. Test: `tools/test/menu.js`.
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
- **Ruhyiyen Ovası (40)**: merkez 噬魂远征军前哨 (120276; dışarı geçidi yok). Altındalga'daki Levazımcı → merkez, Subay → Altındalga (`DUNGEON_TP`, NPC penceresinde "✦" seçeneği; orijinal düğmeler). Kapılar: 5 Ölüm Yabanı, 3 Alacakaranlık Vadisi, 7 Kayıp Bataklık, 9 Ruhyiyen Yaylası (panoların yanındaki geçitler; görev metinleri "sağdaki/yukarıdaki/aşağıdaki geçit" ile doğrulandı). Ön görev `req`: Vadi ve Bataklık 82837, Yayla 82840. Son boss Baron ×1,3 can (`bossX`).
- **50. seviye**: 4 Kule (merkez 灵魂悬台 120360; Dağgören'deki Dağ Cücesi Bilgin ışınlar; kapılar 3 Kahraman, 5 Sihirbaz, 7 Büyücü, 9 Şövalye; 4'er kat, tepe katta ★Kadim Ruh). Ruh Balkonu'nun çıkışı boş kuşatma haritasına (120204) bağlı: `DUNGEON_EXIT` → gerçek Dağgören 120078. Akankum Limanı (giriş 流沙港码头 kapı 5; normal ve kahraman kopyaları Hilal Koyu'nda birleştiği için tek zindan; içerideki Titreyen Kâşif Hilal Uzun Adası'na ışınlar, ★Ölüm Kancası). Kahraman (英雄) modları sonra.
- **Alınmayanlar**: Sınav Ovası (40) ve Sınav Üssü (50) — Symbian'da girişi yok (panoları haritaya konmamış; APK'daki Boşluk Işınlayıcısı NPC'leri APK eklemesi). Tozçamur Madeni (50) — girişi 60 bölgesinde, o bölgeyle birlikte.
- **Çok hedefli görev**: `q.targets = [[ad, adet], …]`, `count` toplam; ilerleme `st.c[ad]`, toplam `st.n` (`questKill`). Aktarım aracı Symbian ilerleme satırını "；" ile böler; yıldızsız yazılmış adlar ☆/★ ile denenir. Zindan görevlerinin Symbian kaydında "reddet" alanı yok (ilerleme 8. alanda), araç bunu tanır.
- **Günlük sınır** `P.dg = {day, n:{id:adet}}` (normal zindan 3/gün; sınav sınırsız).
- Veri düzeltmesi `fixMonData`: ☆☆【小胖】拉斯 kaydında görünüm/ölüm efekti alanları ters.
- `arrivalNear(regs, geçit)`: geçidin varış bölgesi geçit+1 değilse en yakın tür 0 bölge (önceden oyuncu çıkış bölgesinin üstüne doğuyordu).
- Test: `tools/test/zindan.js` (giriş/çıkış/sandık/sınır/ölüm), `BOSS='sahne:ad:sv;…' node tools/test/savas.js` (boss dövüşü, iksirli). Sonuç: Lars (Sv 20) ve ★Mehtap Kurt Kralı (Sv 30) üç sınıfla da yeniliyor, %43-59 can, 0-4 iksir.

## Evcil hayvanlar
Ayrıntı: `docs/07-evcil.md` (`www/js/pet.js`, `Pet` modülü).
