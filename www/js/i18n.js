// İki dil: Türkçe (asıl metinler) ve İngilizce. Dil değişince sayfa yeniden yüklenir.
// tx(metin): Türkçe metnin İngilizcesini verir (sözlük + kalıplar). Yeni metin eklerken buraya İngilizcesini de ekle.
'use strict';

let LANG = 'tr';
try { LANG = localStorage.getItem('anrufen_lang') || ((navigator.language || 'tr').toLowerCase().startsWith('tr') ? 'tr' : 'en'); } catch (e) { }
function setLang(l) { try { localStorage.setItem('anrufen_lang', l); } catch (e) { } location.reload(); }
const TX_MISS = new Set();

const EN_UI = {
  // giriş, karakter oluşturma
  'Yükleniyor…': 'Loading…', 'Lütfen telefonunu yatay çevir': 'Please rotate your phone to landscape', 'Devam Et': 'Continue', 'Yeni Karakter': 'New Character',
  'Eminim: eski karakter silinsin': 'Sure: delete the old character', 'Sınıf': 'Class', 'Irk': 'Race', 'Cinsiyet': 'Gender', 'Yüz': 'Face', 'Erkek': 'Male', 'Kadın': 'Female',
  'Oyuna başla': 'Start game', 'Kahraman': 'Hero', 'Öldün': 'You died', 'Yeniden doğ': 'Revive', 'Kapat': 'Close',
  'Savaşçı': 'Warrior', 'Büyücü': 'Mage', 'Kutsal Elçi': 'Priest', 'İnsan': 'Human', 'Gece Elfi': 'Night Elf',
  // HUD ve menüler
  'Saldır': 'Attack', 'Çanta': 'Bag', 'Görev': 'Quest', 'Menü': 'Menu', 'Ana Menü': 'Main Menu', 'Karakter': 'Character', 'Beceriler': 'Skills', 'Görevler': 'Quests',
  'Dünya Haritası': 'World Map', 'Ayarlar': 'Settings', 'altın': 'gold', 'Tüm sınıflar': 'All classes', 'Etkin': 'Active', '(edilgen)': '(passive)',
  'Hoşça kal': 'Goodbye', '🛒 Alışveriş': '🛒 Shop', "✦ Guanlin Kasabası'na ışınlan": '✦ Teleport to Guanlin Town', 'Daha sonra': 'Later', 'Tamamla': 'Complete', 'Tamam': 'OK', 'Kabul et': 'Accept',
  'Giriş ekranına dön': 'Back to title screen', 'Yeni karakter oluştur': 'Create new character', 'Eminim, sil': 'Sure, delete', 'Çıkar': 'Unequip', 'Giy': 'Equip', 'Kullan': 'Use', 'Aç': 'Open',
  'Sat': 'Sell', 'English / Türkçe': 'Türkçe / English', 'Language: English': 'Language: English', 'Ad': 'Name', '—': '—', 'Emin misin?': 'Are you sure?', 'Alttaki bir kısayol yuvasına dokun': 'Tap a shortcut slot below', 'Dil: Türkçe': 'Language: Turkish',
  'Aktif görev yok. Başında ! olan kişilerle konuş.': 'No active quests. Talk to people with a ! above their head.',
  'Bir ekipman yuvasına dokun. Yeni ekipmanı çantadan giyebilirsin.': 'Tap an equipment slot. Equip new gear from your bag.',
  // ekipman yuvaları ve özellikler
  'Silah': 'Weapon', 'Başlık': 'Head', 'Zırh': 'Armor', 'Kemer': 'Belt', 'Ayakkabı': 'Boots', 'Eldiven': 'Gloves', 'Kolye': 'Necklace', 'Yüzük': 'Ring',
  'Can': 'HP', 'Mana': 'Mana', 'Saldırı': 'Attack', 'Savunma': 'Defense', 'Kritik': 'Critical', 'Kritik %': 'Critical %', 'Kaçınma %': 'Dodge %', 'Can yenileme': 'HP regen', 'Mana yenileme': 'Mana regen',
  'Büyü direnci': 'Magic resist', 'Tecrübe': 'Experience', 'Altın': 'Gold',
  // orijinal pencere yazıları
  'Ekipman': 'Equipment', 'Tüketim': 'Consumable', 'Genel': 'Misc', 'Kısayol': 'Shortcut', 'Ayrıntı': 'Details', 'Yok Et': 'Destroy', 'Oto. İksir': 'Auto Potion', 'Genişlet': 'Expand',
  'İptal': 'Cancel', 'Geri': 'Back', 'Özellik': 'Stats', 'Unvan': 'Title', 'Bilgi': 'Info', 'Kabul': 'Accept', 'Bırak': 'Abandon', 'Alınabilir': 'Available', 'Alınmış': 'Accepted',
  'Satın Al': 'Buy', 'Onar': 'Repair',
  'Yükselt': 'Upgrade', 'Sıfırla': 'Reset', 'Beceri puanı': 'Skill points', 'Kademe': 'Rank', 'kademe': 'rank', 'Bu beceri en yüksek kademede.': 'This skill is at max rank.',
  'Beceri puanın yok. Seviye atlayınca puan kazanırsın.': 'No skill points. You gain one each level.', 'Beceri puanı kazandın! Beceriler ekranından harca.': 'You gained a skill point! Spend it in the Skills window.',
  'Bu beceri henüz öğrenilmedi. Beceriler ekranından puan ver.': 'This skill is not learned yet. Spend a point in the Skills window.', 'Edilgen beceriler kısayola konmaz.': 'Passive skills cannot go on the shortcut bar.', 'Önce beceriyi öğren.': 'Learn the skill first.',
  'Acemi': 'Trainee', 'Çırak': 'Apprentice', 'Başlangıç': 'Novice', 'Elçi': 'Envoy',
  'Yol Bul': 'Pathfind', 'Görev Listesi': 'Quest List', 'Sık Kullanılan': 'Common', 'Eşya': 'Items', 'Sistem': 'System', 'Beceri': 'Skills', 'Harita': 'Map', 'Alışveriş': 'Shop', 'Teslim': 'Turn in', 'Görev bırakıldı': 'Quest abandoned',
  'Aktif görev yok.': 'No active quests.', 'Hedef bu haritada değil.': 'The target is not on this map.',
  'Karakter Özellikleri': 'Character Stats', 'Karakter Ekipmanı': 'Character Equipment', 'Diğer': 'Other', 'Profil': 'Profile', 'Başarım': 'Achievements', 'Değiştir': 'Change', 'Çıkış': 'Exit',
  'Ad': 'Name', 'Seviye': 'Level', 'Fiz. Saldırı': 'Phys. Attack', 'Kaçınma': 'Dodge', 'Büyü Hızı': 'Cast Speed', 'Kutsal Dir.': 'Holy Res.', 'Ateş Dir.': 'Fire Res.', 'Lonca': 'Guild',
  'Büyü Saldırı': 'Magic Attack', 'İsabet': 'Hit', 'Dayanıklılık': 'Toughness', 'Gölge Dir.': 'Dark Res.', 'Buz Dir.': 'Ice Res.', 'Yok': 'None', 'Boş yuva': 'Empty slot', 'Bir ekipman yuvasına dokun.': 'Tap an equipment slot.',
  // dükkân sekmeleri
  'İksirler': 'Potions', 'Silahlar': 'Weapons', 'Zırhlar': 'Armor', 'Başlıklar': 'Headgear', 'Kemerler': 'Belts', 'Ayakkabılar': 'Boots', 'Eldivenler': 'Gloves', 'Kolyeler': 'Necklaces', 'Yüzükler': 'Rings',
  // oyun mesajları
  'Canın dolu.': 'Your HP is full.', 'Manan dolu.': 'Your mana is full.', 'Mana yetersiz!': 'Not enough mana!', 'Hedef yok.': 'No target.', 'Yakında hedef yok.': 'No target nearby.',
  'Yeterli altının yok.': 'Not enough gold.', 'Iska': 'Miss', 'Gelişim Paketi açıldı! Yeni ekipmanını kuşandın.': 'Growth Pack opened! You equipped your new gear.',
  'Yalnızca iksirler kısayola konabilir.': 'Only potions can be put on the shortcut bar.',
  'Rehber seni bekliyor: başında ! olan kişiye dokun': 'The Guide is waiting: tap the person with a ! above their head',
  'Sol alttaki ejderhayı parmağınla kaydırarak yürü ya da haritada bir yere dokun.': 'Drag the dragon at the bottom left to walk, or tap somewhere on the map.',
  'Canavara dokunursan saldırırsın; sağ alttaki Saldır düğmesi de en yakın canavara saldırır.': 'Tap a monster to attack; the Attack button at the bottom right attacks the nearest one.',
  // eski eşyalar ve görev eşyaları
  'Zayıf Can İksiri': 'Weak Health Potion', 'Can İksiri': 'Health Potion', 'Zayıf Mana İksiri': 'Weak Mana Potion', 'Mana İksiri': 'Mana Potion', 'Gelişim Paketi': 'Growth Pack', 'Görev Eşyası': 'Quest Item',
  'Aç: seviyene uygun ekipman ve iksir çıkar.': 'Open: gives gear and potions for your level.', 'Görev için gerekli.': 'Needed for a quest.',
  'Tavuk Kanı': 'Chicken Blood', 'Domuz Bacak Kemiği': 'Boar Leg Bone', 'Enfiye Kutusu': 'Snuff Box', 'Orman Kurdu Eti': 'Forest Wolf Meat', 'Yabani Sebze': 'Wild Greens', 'Peri Tozu': 'Fairy Dust',
};
// değişken içeren metinler
const EN_RULES = [
  [/^(\d+) altın alındı$/, '$1 gold received'], [/^(\d+) altın$/, '$1 gold'], [/^\((\d+),(\d+)\)\s+(\d+) altın$/, '($1,$2)  $3 gold'],
  [/^Görev alındı: (.*)$/, 'Quest accepted: $1'], [/^Görev tamamlandı: (.*)$/, 'Quest complete: $1'], [/^(.*) tamam\. (.*) ile konuş\.$/, '$1 done. Talk to $2.'],
  [/^Tamam: (.*) ile konuş$/, 'Done: talk to $1'], [/^Tamamlandı — (.*) ile konuş(.*)$/, 'Complete — talk to $1$2'], [/^! (.*) sana görev verecek$/, '! $1 has a quest for you'],
  [/^Ödül: (\d+) TP, (\d+) altın$/, 'Reward: $1 XP, $2 gold'], [/^Ödül: (\d+) TP$/, 'Reward: $1 XP'], [/^\+(\d+) TP$/, '+$1 XP'],
  [/^(.*) kuşanıldı\.$/, '$1 equipped.'], [/^(.*) çıkarıldı\.$/, '$1 unequipped.'], [/^(.*) yok edildi\.$/, '$1 destroyed.'], [/^(.*) etkin\.$/, '$1 active.'],
  [/^(.*) satıldı \(\+(\d+) altın\)\.$/, '$1 sold (+$2 gold).'], [/^(.*) ×(\d+) satın alındı \(−(\d+) altın\)\.$/, '$1 ×$2 bought (−$3 gold).'],
  [/^(.*) (\d+)\. seviyede açılır\.?$/, '$1 unlocks at level $2.'], [/^(\d+)\. seviyede açılır$/, 'Unlocks at level $1'], [/^(\d+)\. seviye gerekir\.$/, 'Requires level $1.'],
  [/^Bu eşya (.*) içindir\.$/, 'This item is for $1.'], [/^Gereken seviye: (\d+)$/, 'Required level: $1'], [/^Seviye (\d+)$/, 'Level $1'], [/^Sv (\d+)$/, 'Lv $1'], [/^(.*)  Sv ?(\d+)$/, '$1  Lv $2'], [/^(.*) Sv(\d+)$/, '$1 Lv$2'], [/^Sv(\d+)$/, 'Lv$1'],
  [/^Satış: (\d+) altın$/, 'Sell: $1 gold'], [/^Sat \(\+(\d+)\)$/, 'Sell (+$1)'], [/^Satın al \((\d+)\)$/, 'Buy ($1)'], [/^10 tane \((\d+)\)$/, '10 pcs ($1)'],
  [/^Ganimet: (.*?)!?$/, 'Loot: $1'], [/^(.*) (\d+)\/(\d+)$/, (m, a, b, c) => `${tx(a)} ${b}/${c}`], [/^(.*) ×(\d+)$/, (m, a, b) => `${tx(a)} ×${b}`], [/^Yeni beceri: (.*)$/, 'New skill: $1'], [/^Şu an: (.*)$/, 'Now in: $1'], [/^Tamamlanan görev: (\d+)$/, 'Quests completed: $1'],
  [/^Ses efektleri: Açık$/, 'Sound effects: On'], [/^Ses efektleri: Kapalı$/, 'Sound effects: Off'], [/^Müzik: Açık$/, 'Music: On'], [/^Müzik: Kapalı$/, 'Music: Off'],
  [/^Oyun otomatik kaydedilir\. Sürüm (\d+)$/, 'The game saves automatically. Version $1'], [/^Sürüm (\d+)$/, 'Version $1'], [/^Kısayol (\d+)$/, 'Shortcut $1'],
  [/^(\d+) can yeniler\.$/, 'Restores $1 HP.'], [/^(\d+) mana yeniler\.$/, 'Restores $1 mana.'], [/^(\d+) mana · ([\d.]+) sn · (.*)$/, (m, a, b, c) => `${a} mana · ${b} s · ${tx(c)}`],
  [/^(.*): bu bölge henüz açılmadı$/, '$1: this area is not open yet'], [/^(.*): eğitim alanı sergisi\.$/, '$1: a training ground display.'], [/^Seviye (\d+)$/, 'Level $1'],
  [/^Bir eşyaya dokun.*$/, 'Tap an item to see its info, use it or equip it.'],
];
EN_RULES.unshift([/^(\d+) mana · ([\d.]+) sn · (.*)$/, (m, a, b, c) => `${a} mana · ${b} s · ${tx(c)}`]);
function tx(s) {
  if (LANG === 'tr' || s == null || typeof s !== 'string' || !s) return s;
  const k = s.trim(); if (!k) return s;
  if (EN_UI[k] != null) return s.replace(k, EN_UI[k]);
  for (const [re, rep] of EN_RULES) if (re.test(k)) return s.replace(k, k.replace(re, rep));
  if (k.includes(' · ')) return s.replace(k, k.split(' · ').map(tx).join(' · '));
  if (/[çğışöüÇĞİŞÖÜ]/.test(k)) TX_MISS.add(k);
  return s;
}
// bir DOM parçasındaki yazıları çevir
function txDom(root) {
  if (LANG === 'tr' || !root) return;
  const w = document.createTreeWalker(root, NodeFilter.SHOW_TEXT); let n; const list = [];
  while ((n = w.nextNode())) list.push(n);
  for (const t of list) { const v = t.nodeValue; if (v && v.trim()) { const r = tx(v); if (r !== v) t.nodeValue = r; } }
  root.querySelectorAll && root.querySelectorAll('[placeholder],[aria-label],input[value]').forEach(e => { for (const a of ['placeholder', 'aria-label', 'value']) { const v = e.getAttribute(a); if (v) e.setAttribute(a, tx(v)); if (a === 'value' && e.value) e.value = tx(e.value); } });
}

// ---------------- İngilizce veri (NPC, canavar, bölge adları; orijinal Çince adlara göre) ----------------
const EN = {
  scene: { '新兵营地': 'Recruit Camp', '观林镇': 'Guanlin Town', '阳光森林': 'Sunny Forest', '阳光森林北': 'Sunny Forest North', '阳光森林南': 'Sunny Forest South', '阳光森林东': 'Sunny Forest East',
    '巨魔森林': 'Troll Forest', '阳光草原': 'Sunny Plains', '黑暗哨塔': 'Dark Watchtower', '邪教基地': 'Cult Base' },
  name: {
    '点点我': 'Guide', '新兵队长': 'Recruit Captain', '新兵教练': 'Recruit Trainer', '教练员': 'Instructor', '初级战斗导师': 'Combat Tutor', '观林镇传送员': 'Guanlin Teleporter',
    '鸭子': 'Duck', '鸡': 'Chicken', '神殿骑士': 'Temple Knight', '魔法骷髅': 'Magic Skeleton', '恶魔傀儡': 'Demon Puppet',
    '驿站老板（人类）': 'Coach Station Owner', '道具商人（人类）': 'Item Merchant', '魔法储物箱': 'Magic Storage Chest', '武器商人（人类）': 'Weapon Merchant', '防具商人（人类）': 'Armor Merchant',
    '驯兽师（人类）': 'Beast Tamer', '饰品商人（人类）': 'Accessory Merchant', '宝石匠（人类）': 'Jeweler', '契约欢乐使者': 'Covenant Joy Envoy', '神秘商人': 'Mysterious Merchant',
    '观林镇镇长': 'Guanlin Mayor', '护林游侠': 'Forest Ranger', '民兵队长': 'Militia Captain', '馋鬼': 'Glutton', '寡妇安娜': 'Widow Anna', '走私者': 'Smuggler', '疯子': 'Madman',
    '疯子的老婆': "Madman's Wife", '护民官': 'Tribune', '汤姆': 'Tom', '人类信箱': 'Mailbox', '杰西': 'Jessie', '炼金师': 'Alchemist', '育种园丁': 'Seed Gardener', '杰克医生': 'Doctor Jack',
    '人类居民': 'Townsperson', '钻石回馈使者': 'Diamond Envoy', '采矿人（人类）': 'Miner', '装备强化大师': 'Equipment Master', '魔法兽强化大师': 'Magic Beast Master',
    '医生工会学徒': 'Doctor Apprentice Fige', '沧桑的旅者': 'Weathered Traveler', '考古理论者（人类）': 'Archaeologist', '竞技场管理人莉莉': 'Arena Keeper Lily',
    '源质炼金师（人类）': 'Essence Alchemist', '技能训练师（人类）': 'Skill Trainer',
    '小草堆': 'Small Grass Pile', '草堆': 'Grass Pile', '魔法土堆': 'Magic Dirt Mound', '贫矿': 'Poor Ore', '风化岩（任务矿）': 'Weathered Rock', '风化的遗迹（任务遗迹）': 'Weathered Ruin',
    '契约爱神': 'Covenant Cupid', '战士守卫': 'Warrior Guard', '野菜': 'Wild Greens', '破碎的遗迹': 'Broken Ruin', '魔法草': 'Magic Herb', '林隐仙子': 'Forest Hermit Fairy',
    '闪光的草堆': 'Glittering Grass Pile', '警卫卡鲁': 'Guard Karu',
    '毒蛇帮路匪': 'Viper Gang Bandit', '野猪': 'Wild Boar', '☆【帝国叛徒】迪萨安': '☆【Imperial Traitor】Disaan', '蜘蛛': 'Longleg Spider', '蜘蛛掠夺者': 'Spider Raider',
    '森林狼': 'Forest Wolf', '☆森林狼头领': '☆Forest Wolf Chief', '森林蝰蛇': 'Forest Viper', '恶作剧仙子': 'Prankster Fairy', '毒蛇帮精英': 'Viper Gang Elite', '蜂蜜仙子': 'Honey Fairy',
    '☆毒蛇帮虐杀者': '☆Viper Gang Butcher', '☆精英护卫': '☆Elite Guard', '☆☆【叛徒】萨丁曼': '☆☆【Traitor】Sadinman', '森林巨魔': 'Forest Troll', '☆巨魔摧毁者': '☆Troll Destroyer', '☆饥饿的巨魔': '☆Hungry Troll',
  },
  greet: {
    '点点我': 'Hello, young adventurer. You can choose what to talk about below our conversation. See the ! above my head? It means I have a quest for you. Start with your first main quest: [Sign Up].',
    '新兵队长': 'Glad to see you, youngster. If I have a ? above my head, you can complete a quest with me. Remember that.',
    '新兵教练': 'I review the battle results here.', '教练员': 'Items you win in battle go straight into your bag.',
    '初级战斗导师': 'To face the challenges of your future adventures you must learn how to attack. Tap the monster you want to attack; your character will walk to the target and keep attacking.',
    '观林镇传送员': 'Hello, young adventurer. When your recruit training is finished I will teleport you to a new town, where real challenges await.',
    '驿站老板（人类）': 'For only 100 gold my coaches will carry you quickly between cities. No more long, tiring roads.',
    '道具商人（人类）': 'I sell all the odds and ends every adventurer needs. Even great heroes cannot do without my bottles and little tools!',
    '魔法储物箱': 'This chest is enchanted. It holds a lot, and you can take your things back out in any city.',
    '武器商人（人类）': 'Weapons of every kind, sold and repaired! The tools of a hero\'s trade! Don\'t be stingy! Heroes one and all, step right up!',
    '防具商人（人类）': 'Armor of every kind, sold and repaired! The tools of a hero\'s trade! Don\'t be stingy!',
    '驯兽师（人类）': 'A magic beast loyal to you! A guardian that never tires! A companion that never betrays! ...As long as you buy its feed from me and feed it well.',
    '饰品商人（人类）': 'Accessories of every kind, sold and repaired! The tools of a hero\'s trade!',
    '宝石匠（人类）': 'Gems! Ah, the most beautiful and precious things in the world. Especially those that can be set into equipment, made by a special refining process.',
    '契约欢乐使者': 'I come from a distant world, carrying the hopes and wishes of many people. On holidays I hand out all kinds of gifts. Have fun!',
    '神秘商人': 'There are powerful treasures in this world that will make things easier for you. Take a look at the shop.',
    '观林镇镇长': 'Welcome, young adventurer. The town has had plenty of trouble lately, and we badly need your help.',
    '护林游侠': 'Watch your step, human. Harm the forest and you will answer to me. But most of the time it is you who should take care that the forest does not harm you.',
    '民兵队长': 'Thank you for coming to help. But first keep yourself in hand and follow orders; only then will you be of use.',
    '馋鬼': 'You there, have you found anything new and tasty?',
    '寡妇安娜': 'My husband is dead, my husband is dead, my husband is dead... If I had not wanted mushrooms he would not have taken me picking, and those spiders would not have bitten him... It is all my fault...',
    '走私者': 'Go... move along, you have no business here.',
    '疯子': 'They are coming! They torture me! They say the world will end! It is all true! Everyone will die! Blood! Aaah!',
    '疯子的老婆': 'Ah... ever since my husband was attacked by a gang in the forest, he has lost his mind.',
    '护民官': 'When you help the people of the kingdom they may give you a People\'s Medal. The King rewards those who carry these medals; bring them to me.',
    '汤姆': 'Heroes who rescue princesses are so boring! When I grow up I will be a wild dark hero! And then... then... I will have every dentist executed!',
    '人类信箱': 'If you have a stamp you can send letters and parcels to your friends.',
    '杰西': 'They say the noble ladies in the capital eat cream cake every day... how lovely.',
    '炼金师': 'Alchemy is a noble art that joins magic and medicine. A lifetime is not enough to learn its secrets... So the best thing is to use it to make money!',
    '育种园丁': 'The flowers are about to wither; I am gathering the seeds worth saving and preparing for the future.',
    '杰克医生': 'I treat the illnesses of people and animals alike, but I wish people would learn to prevent disease.',
    '人类居民': 'The lumber camp keeps getting attacked; we cannot get any work done.',
    '采矿人（人类）': 'What a great trade mining is! I have spent my whole life searching for veins, because the profit is always incredible.',
    '装备强化大师': 'As the Blacksmiths\' Guild representative here, I offer equipment enhancement.',
    '魔法兽强化大师': 'I represent the Beast Tamers\' Guild; I offer enhancement services for magic beasts.',
    '医生工会学徒': 'Greetings, fearless adventurer! I am Fige, apprentice of the Doctors\' Guild. For 100 gold I will restore your HP and mana on the spot!',
    '沧桑的旅者': 'I have traveled far in my life and set foot in nearly every corner of this continent. I am old now, but I am happy to help you with my experience.',
    '考古理论者（人类）': 'What happened on this continent? Do not believe gossip; only the old ruins tell the truth.',
    '竞技场管理人莉莉': 'To my mind, beating enemies in the wild is nothing much. The truly strong are those who win in contests between people.',
    '源质炼金师（人类）': 'The alchemy of decomposition is a deep art.', '技能训练师（人类）': 'To live in this world you should learn a craft besides fighting.',
    '小草堆': 'There seems to be an ordinary snuff box in the grass.', '草堆': 'An ordinary pile of grass.', '魔法土堆': 'A loose mound of dirt; it looks a little strange.',
    '野菜': 'Fresh ferns growing in the forest.', '魔法草': 'A special plant that grows in the forest.', '林隐仙子': 'The forest is full of nature magic; by resting quietly I can become part of it.',
    '闪光的草堆': 'There seem to be strange plant seeds in the grass.', '警卫卡鲁': 'When will I ever get out of this cursed place...', '战士守卫': 'It is not safe here. Be careful.',
  },
  cls: { '战士': 'Warrior', '法师': 'Mage', '牧师': 'Priest' }, race: { '人类': 'Human', '精灵': 'Night Elf' },
};
