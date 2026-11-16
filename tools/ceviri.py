# -*- coding: utf-8 -*-
# Harita ve varlık adlarının çevirileri (elle yazıldı): Çince ad -> (Türkçe, İngilizce). Çıktı: www/js/tr_scenes.js
# Kullanım (depo kökünden): python3 tools/ceviri.py
import json,re
B={
'守望者营地':('Gözcü Kampı','Watcher Camp'),'奔马城':('Koşanat Şehri','Galloping Horse City'),'望日城':('Güneşgören Şehri','Sunwatch City'),'战士工会平台':('Savaşçı Loncası Terası','Warrior Guild Terrace'),
'法师公会平台':('Büyücü Loncası Terası','Mage Guild Terrace'),'法师工会平台':('Büyücü Loncası Terası','Mage Guild Terrace'),'休闲区':('Dinlenme Bölgesi','Leisure District'),'艺术家工会前厅':('Sanatçılar Loncası Girişi','Artist Guild Lobby'),'帝都':('Başkent','Imperial Capital'),
'帝都-英雄广场':('Başkent · Kahramanlar Meydanı','Capital · Heroes Square'),'神殿区':('Tapınak Bölgesi','Temple District'),'帝都-贵族区':('Başkent · Soylular Bölgesi','Capital · Noble District'),'金波港':('Altındalga Limanı','Goldwave Harbor'),
'夜精灵社区':('Gece Elfi Mahallesi','Night Elf Quarter'),'公正广场':('Adalet Meydanı','Justice Square'),'人类社区':('İnsan Mahallesi','Human Quarter'),'试炼之间':('Sınav Odası','Trial Chamber'),'契约密室':('Sözleşme Gizli Odası','Contract Secret Room'),
'望山城':('Dağgören Şehri','Mountainwatch City'),'千仞哨岗':('Uçurum Karakolu','Cliff Outpost'),'魔力温室':('Büyü Serası','Magic Greenhouse'),'浓雾镇':('Yoğunsis Kasabası','Thickfog Town'),'军情前哨':('İstihbarat Karakolu','Intel Outpost'),
'幽暗营地':('Loş Kamp','Gloom Camp'),'魔法学院':('Büyü Akademisi','Magic Academy'),'夜精灵营地':('Gece Elfi Kampı','Night Elf Camp'),'灰斧城':('Bozbalta Şehri','Greyaxe City'),'传送区':('Işınlanma Bölgesi','Teleport Area'),
'帝国近卫军营地':('İmparatorluk Muhafız Kampı','Imperial Guard Camp'),'远征军营地':('Sefer Ordusu Kampı','Expedition Camp'),'黄土岗哨':('Sarıtoprak Karakolu','Loess Outpost'),'夜精灵废院':('Gece Elfi Harabe Avlusu','Night Elf Ruined Yard'),
'神谕先遣队营地':('Kehanet Öncü Kampı','Oracle Vanguard Camp'),'人类营地':('İnsan Kampı','Human Camp'),'寂静林地':('Sessiz Koru','Silent Woodland'),'罗网林地':('Ağlı Koru','Webbed Woodland'),'迷途林地':('Kayıp Koru','Lost Woodland'),'堕落林地':('Yozlaşmış Koru','Fallen Woodland'),
'噩梦平原中部':('Kâbus Ovası Orta','Nightmare Plain Center'),'噩梦平原东':('Kâbus Ovası Doğu','Nightmare Plain East'),'噩梦平原西':('Kâbus Ovası Batı','Nightmare Plain West'),'噩梦平原南':('Kâbus Ovası Güney','Nightmare Plain South'),
'烂泥荒野':('Çamurlu Yaban','Mud Wilds'),'野马草原':('Yabanat Çayırı','Wild Horse Prairie'),'清风草原':('Esinti Çayırı','Breeze Prairie'),'草原前线':('Çayır Cephesi','Prairie Front'),'奔马海港':('Koşanat Limanı','Galloping Horse Harbor'),
'银鹰城西南':('Gümüşkartal Şehri Güneybatı','Silver Eagle City Southwest'),'银鹰城南':('Gümüşkartal Şehri Güney','Silver Eagle City South'),'银鹰城西北':('Gümüşkartal Şehri Kuzeybatı','Silver Eagle City Northwest'),'银鹰城东北':('Gümüşkartal Şehri Kuzeydoğu','Silver Eagle City Northeast'),
'哀嚎小径':('Feryat Patikası','Wailing Path'),'鬼火森林中部':('Cinateşi Ormanı Orta','Wisp Forest Center'),'鬼火森林北':('Cinateşi Ormanı Kuzey','Wisp Forest North'),'鬼火森林东':('Cinateşi Ormanı Doğu','Wisp Forest East'),'鬼火森林南':('Cinateşi Ormanı Güney','Wisp Forest South'),
'暗血森林':('Karakan Ormanı','Darkblood Forest'),'饕餮森林':('Obur Ormanı','Glutton Forest'),'骑士陵寝':('Şövalye Mezarlığı','Knight Mausoleum'),'浓雾镇海岸':('Yoğunsis Kıyısı','Thickfog Coast'),
'罪恶庭院':('Günah Avlusu','Courtyard of Sin'),'传送回廊':('Işınlanma Koridoru','Teleport Corridor'),'迷乱回廊':('Şaşkınlık Koridoru','Corridor of Confusion'),'堕落庙宇':('Yozlaşmış Tapınak','Fallen Temple'),'地下庙宇':('Yeraltı Tapınağı','Underground Temple'),
'鲜血庙宇':('Kan Tapınağı','Blood Temple'),'血腥陋室':('Kanlı Kulübe','Bloody Hovel'),'密室':('Gizli Oda','Secret Room'),'毁坏的山路':('Yıkık Dağ Yolu','Ruined Mountain Road'),'北风山麓':('Poyraz Etekleri','Northwind Foothills'),
'冰河峡谷':('Buzul Kanyonu','Glacier Canyon'),'群狼峰':('Kurtlar Zirvesi','Wolfpack Peak'),'废弃营地':('Terk Edilmiş Kamp','Abandoned Camp'),'暴雪古道':('Tipi Eski Yolu','Blizzard Old Road'),'神鹫峰':('Akbaba Zirvesi','Condor Peak'),
'冰冻隘口':('Donmuş Geçit','Frozen Pass'),'大雪峰':('Büyük Kar Zirvesi','Great Snow Peak'),'矮人大师宅':('Cüce Ustanın Evi','Dwarf Master House'),'雪山营地':('Karlı Dağ Kampı','Snow Mountain Camp'),'漫雾低地':('Sisli Ova','Misty Lowland'),
'阴暗海岸':('Kasvetli Kıyı','Gloomy Coast'),'望日城军港':('Güneşgören Askeri Limanı','Sunwatch Naval Port'),'下城区贫民窟':('Aşağı Şehir Kenar Mahallesi','Lower City Slums'),'垃圾场':('Çöplük','Junkyard'),'贫民窟':('Kenar Mahalle','Slums'),
'废弃城区':('Terk Edilmiş Mahalle','Abandoned District'),'污水洞穴':('Lağım Mağarası','Sewage Cave'),'圆盘竞技场':('Disk Arenası','Disc Arena'),'塔林竞技场':('Kule Arenası','Tower Arena'),'战斗准备区':('Savaş Hazırlık Alanı','Battle Prep Area'),
'落穴之间':('Çukur Odası','Pitfall Chamber'),'没用到的竞技场':('Kullanılmayan Arena','Unused Arena'),'死亡哨所':('Ölüm Karakolu','Death Outpost'),'休息区':('Dinlenme Alanı','Rest Area'),'矮人矿洞':('Cüce Madeni','Dwarf Mine'),
'艺术家工会':('Sanatçılar Loncası','Artist Guild'),'绘画回廊':('Resim Koridoru','Painting Corridor'),'雕塑回廊':('Heykel Koridoru','Sculpture Corridor'),'绘画大厅':('Resim Salonu','Painting Hall'),'雕塑大厅':('Heykel Salonu','Sculpture Hall'),
'苦痛回廊':('Acı Koridoru','Corridor of Pain'),'学徒大厅':('Çırak Salonu','Apprentice Hall'),'恶魔之间':('İblis Odası','Demon Chamber'),'休息室':('Dinlenme Odası','Lounge'),'下水道':('Lağım','Sewer'),'魔法花园':('Büyü Bahçesi','Magic Garden'),
'大图书馆前厅':('Büyük Kütüphane Girişi','Great Library Lobby'),'银鹰城':('Gümüşkartal Şehri','Silver Eagle City'),'银鹰庭院':('Gümüşkartal Avlusu','Silver Eagle Courtyard'),'军营':('Kışla','Barracks'),'仓库':('Depo','Warehouse'),
'银鹰城内城':('Gümüşkartal İç Şehri','Silver Eagle Inner City'),'银鹰城内苑':('Gümüşkartal İç Bahçesi','Silver Eagle Inner Garden'),'塔楼大门':('Kule Kapısı','Tower Gate'),'塔楼':('Kule','Tower'),'挑战者的休息室':('Meydan Okuyanın Odası',"Challenger's Lounge"),
'城主庭院':('Şehir Beyinin Avlusu',"Lord's Courtyard"),'城主密室':('Şehir Beyinin Gizli Odası',"Lord's Secret Room"),'怒焰路口':('Öfkealevi Kavşağı','Furyflame Crossing'),'怒焰夹道':('Öfkealevi Geçidi','Furyflame Passage'),'灰胡岗哨':('Bozsakal Karakolu','Greybeard Outpost'),
'熔岩湖':('Lav Gölü','Lava Lake'),'陨石坑':('Göktaşı Çukuru','Meteor Crater'),'毁灭之路南门':('Yıkım Yolu Güney Kapısı','Ruin Road South Gate'),'暴风雪原南':('Tipi Ovası Güney','Blizzard Plain South'),'休酣之地':('Uyku Diyarı','Slumber Grounds'),
'暴风雪原西北':('Tipi Ovası Kuzeybatı','Blizzard Plain Northwest'),'暴风雪原东':('Tipi Ovası Doğu','Blizzard Plain East'),'极寒之崖':('Dondurucu Uçurum','Frigid Cliff'),'麋鹿雪林':('Geyikli Kar Ormanı','Elk Snow Forest'),'巨熊之抱':('Dev Ayı Kucağı',"Giant Bear's Embrace"),
'帝都城南':('Başkent Güneyi','Capital South'),'帝都城北':('Başkent Kuzeyi','Capital North'),'帝都城西':('Başkent Batısı','Capital West'),'帝都拱门':('Başkent Kemeri','Capital Arch'),'仙子森林':('Peri Ormanı','Fairy Forest'),'蜘蛛森林':('Örümcek Ormanı','Spider Forest'),
'灰白树林':('Külrengi Koru','Ashen Grove'),'荒寂之门':('Issızlık Kapısı','Gate of Desolation'),'恐惧之末':('Korkunun Sonu','Fear\'s End'),'山麓营地':('Etek Kampı','Foothill Camp'),'月夜林地':('Mehtap Korusu','Moonlit Woodland'),'狼王丛林':('Kurt Kralı Ormanı','Wolf King Jungle'),
'噬魂远征军前哨':('Ruhyiyen Sefer Karakolu','Soul Eater Expedition Outpost'),'残破营地':('Harap Kamp','Broken Camp'),'失心平原':('Çılgınlık Ovası','Heartless Plain'),'仪式广场':('Ayin Meydanı','Ritual Square'),'白骨之庭':('Kemik Avlusu','Court of Bones'),
'血祭之间':('Kan Kurbanı Odası','Blood Sacrifice Chamber'),'侍从高地':('Hizmetkâr Yaylası','Attendant Highlands'),'鲜血之门':('Kan Kapısı','Gate of Blood'),'荒芜陵园':('Issız Mezarlık','Barren Cemetery'),'断头台':('Giyotin','Guillotine'),
'绿茵回廊':('Yeşil Koridor','Verdant Corridor'),'领主庭院':('Derebeyi Avlusu',"Overlord's Courtyard"),'破碎山路':('Kırık Dağ Yolu','Shattered Mountain Road'),'乱石岗':('Kayalık Sırt','Rocky Ridge'),'谷底丛林':('Vadi Ormanı','Valley Jungle'),
'维多隘口':('Vido Geçidi','Vido Pass'),'巨魔墓场':('Trol Mezarlığı','Troll Graveyard'),'落日冢':('Günbatımı Höyüğü','Sunset Mound'),'泥泞平原':('Balçık Ovası','Muddy Plain'),'碎脊岭':('Kırıkbel Sırtı','Brokenspine Ridge'),'淤泥荒野':('Balçık Yabanı','Silt Wilds'),
'失落之池':('Kayıp Gölet','Lost Pool'),'腐烂之痕':('Çürüme İzi','Rotting Scar'),'死亡泥潭':('Ölüm Bataklığı','Death Mire'),'流沙港码头':('Akankum İskelesi','Quicksand Wharf'),'流沙港口':('Akankum Limanı','Quicksand Port'),'管理员平台':('Yönetici Platformu','Admin Platform'),
'流沙群岛':('Akankum Adaları','Quicksand Isles'),'金银岛':('Hazine Adası','Treasure Island'),'新月湾':('Hilal Koyu','Crescent Bay'),'新月半岛':('Hilal Yarımadası','Crescent Peninsula'),'新月长岛':('Hilal Uzun Adası','Crescent Long Island'),
'阴暗巷道':('Karanlık Dehliz','Dark Tunnel'),'空旷之地':('Boş Arazi','Open Ground'),'轮回之间':('Döngü Odası','Chamber of Rebirth'),'毁灭之穴':('Yıkım İni','Den of Ruin'),'痛苦之坑':('Acı Çukuru','Pit of Pain'),'幽暗密室':('Loş Gizli Oda','Gloomy Secret Room'),
'隐匿矿坑':('Gizli Maden','Hidden Mine'),'灵魂悬台':('Ruh Balkonu','Soul Ledge'),'英雄塔':('Kahraman Kulesi','Hero Tower'),'巫师塔':('Sihirbaz Kulesi','Wizard Tower'),'骑士塔':('Şövalye Kulesi','Knight Tower'),'术士塔':('Büyücü Kulesi','Warlock Tower'),
'大斗技场':('Büyük Dövüş Arenası','Grand Arena'),'狂战士之间':('Berserker Odası','Berserker Chamber'),'嗜血者之间':('Kana Susamış Odası','Bloodthirster Chamber'),'风暴之间':('Fırtına Odası','Storm Chamber'),'烈焰之间':('Alev Odası','Flame Chamber'),
'邪虫之间':('Uğursuz Böcek Odası','Vile Insect Chamber'),'不朽者之间':('Ölümsüz Odası','Immortal Chamber'),'王者之间':('Kral Odası',"King's Chamber"),'银白前哨':('Gümüşi Karakol','Silverwhite Outpost'),'银白之丘':('Gümüşi Tepe','Silverwhite Hill'),
'冷血之印':('Soğukkan Mührü','Coldblood Seal'),'积雪山麓':('Karlı Etekler','Snowy Foothills'),'寒月之角':('Soğukay Burnu','Coldmoon Horn'),'大冰原':('Büyük Buz Ovası','Great Icefield'),'寒冰废土':('Buzlu Çorak','Frozen Wasteland'),
'炽热前哨':('Kızgın Karakol','Scorching Outpost'),'灼热峡谷':('Kavurucu Kanyon','Searing Canyon'),'黑火山坳':('Kara Volkan Boğazı','Black Volcano Pass'),'燃烧山脊':('Yanan Sırt','Burning Ridge'),'焚化者之台':('Yakıcının Terası',"Incinerator's Terrace"),
'熔岩炼狱':('Lav Arafı','Lava Purgatory'),'熔火之心':('Erimiş Çekirdek','Molten Core'),'末日高台':('Kıyamet Terası','Doomsday Terrace'),'末日广场':('Kıyamet Meydanı','Doomsday Square'),'毁灭高台':('Yıkım Terası','Terrace of Ruin'),
'迷惘之间':('Şaşkınlık Odası','Chamber of Bewilderment'),'军团议会':('Lejyon Meclisi','Legion Council'),'指挥大厅':('Komuta Salonu','Command Hall'),'深渊之核':('Uçurumun Çekirdeği','Abyss Core'),'堕落圣域':('Yozlaşmış Kutsal Alan','Fallen Sanctuary'),
'浮游圣域 - 虚无':('Süzülen Kutsal Alan · Hiçlik','Floating Sanctuary · Void'),'浮游圣域 - 暴虐':('Süzülen Kutsal Alan · Zulüm','Floating Sanctuary · Tyranny'),'浮游圣域 - 狡诈':('Süzülen Kutsal Alan · Hile','Floating Sanctuary · Cunning'),
'扭曲回廊':('Çarpık Koridor','Twisted Corridor'),'浮游圣域 - 屠杀':('Süzülen Kutsal Alan · Katliam','Floating Sanctuary · Slaughter'),'浮游圣域 - 纷争':('Süzülen Kutsal Alan · Nifak','Floating Sanctuary · Strife'),
'圣光泯灭悬台':('Sönen Işık Balkonu','Ledge of Fading Light'),'浮游圣域 - 审判':('Süzülen Kutsal Alan · Yargı','Floating Sanctuary · Judgment'),'帝都广场':('Başkent Meydanı','Capital Square'),'帝都神殿区':('Başkent Tapınak Bölgesi','Capital Temple District'),
'走私者之岛':('Kaçakçılar Adası',"Smugglers' Island"),'梦境之岛':('Rüya Adası','Dream Island'),'深潜梦境':('Derin Rüya','Deep Dream'),'恐怖地穴':('Dehşet Mahzeni','Terror Crypt'),'梦境之穴':('Rüya İni','Dream Den'),'恐惧梦境':('Korku Rüyası','Fear Dream'),
'梦境之丘':('Rüya Tepesi','Dream Hill'),'侏儒梦境':('Cüce Rüyası','Gnome Dream'),'梦境之坡':('Rüya Yamacı','Dream Slope'),'瘟疫梦境':('Veba Rüyası','Plague Dream'),'梦境通道':('Rüya Geçidi','Dream Passage'),'梦境乐园':('Rüya Cenneti','Dream Paradise'),
'梦终之地':('Rüyanın Bittiği Yer','Dream\'s End'),'梦始之地':('Rüyanın Başladığı Yer','Dream\'s Beginning'),'梦境深渊':('Rüya Uçurumu','Dream Abyss'),'驯兽大厅':('Terbiyeci Salonu','Beast Tamer Hall'),'肮脏轮回':('Kirli Döngü','Filthy Cycle'),
'痛苦长廊':('Acı Dehlizi','Gallery of Pain'),'帝王之座':('İmparator Tahtı',"Emperor's Seat"),'兽王监牢':('Canavar Kralı Zindanı','Beast King Prison'),'碎裂断层':('Parçalanmış Fay','Shattered Fault'),'艾因霍克王座':('Einhawk Tahtı','Einhawk Throne'),
'试炼森林':('Sınav Ormanı','Trial Forest'),'试炼平原':('Sınav Ovası','Trial Plain'),'试炼基地':('Sınav Üssü','Trial Base'),'试炼草原':('Sınav Çayırı','Trial Prairie'),'试炼洞穴':('Sınav Mağarası','Trial Cave'),'禁默之痕':('Sessizlik İzi','Scar of Silence'),
'苦痛深渊':('Acı Uçurumu','Abyss of Pain'),'积水密室':('Su Basmış Oda','Flooded Room'),'阴暗密室':('Karanlık Gizli Oda','Dark Secret Room'),'灼热阶梯':('Kavurucu Merdiven','Searing Stairs'),'燃烧长廊':('Yanan Dehliz','Burning Gallery'),
'悲惨回廊':('Sefalet Koridoru','Corridor of Misery'),'极寒密室':('Dondurucu Oda','Frigid Room'),'恶臭密室':('Kokuşmuş Oda','Stench Room'),'恶魔祭坛':('İblis Sunağı','Demon Altar'),'荒芜之地':('Çorak Diyar','Barren Land'),'燃尽长廊':('Kül Dehlizi','Burnt-out Gallery'),
'灵魂炼狱':('Ruh Arafı','Soul Purgatory'),'动乱之源':('Kargaşanın Kaynağı','Source of Turmoil'),'寂静之间':('Sessizlik Odası','Chamber of Silence'),'潮湿走廊':('Rutubetli Koridor','Damp Corridor'),'安德卡诺王座':('Andecano Tahtı','Andecano Throne'),
'迷乱洞窟':('Şaşkınlık Mağarası','Cave of Confusion'),'穿刺之穴':('Kazık İni','Impaling Den'),'妖术之穴':('Büyücülük İni','Sorcery Den'),'巫毒之间':('Vudu Odası','Voodoo Chamber'),'巫毒长廊':('Vudu Dehlizi','Voodoo Gallery'),'污泥之穴':('Çamur İni','Sludge Den'),
'沸血之穴':('Kaynayan Kan İni','Boiling Blood Den'),'达普尼之穴':('Dapni İni','Dapni Den'),'干涸地洞':('Kurumuş Oyuk','Dried Burrow'),'恶魔洞窟':('İblis Mağarası','Demon Cave'),'达普尼的巢穴':('Dapni\'nin İni',"Dapni's Lair"),'土灵墓穴':('Toprak Ruhu Mezarı','Earth Spirit Tomb'),
'梦魇迷宫':('Kâbus Labirenti','Nightmare Maze'),'地狱横沟':('Cehennem Hendeği','Hell Trench'),'怒炎山麓':('Öfkeateşi Etekleri','Furyfire Foothills'),'烈火隘口':('Alev Geçidi','Blaze Pass'),'反叛军前哨':('İsyancı Karakolu','Rebel Outpost'),
'反叛军营地':('İsyancı Kampı','Rebel Camp'),'岩浆裂口':('Magma Yarığı','Magma Fissure'),'火焰峰':('Alev Zirvesi','Flame Peak'),'六成熟丘陵':('Yarı Pişmiş Tepeler','Medium-Rare Hills'),'兽人营地':('Ork Kampı','Orc Camp'),'横尸荒野':('Cesetli Yaban','Corpse Wilds'),
'修罗谷':('Asura Vadisi','Asura Valley'),'死斗坑':('Ölüm Dövüşü Çukuru','Deathmatch Pit'),'灰烬峡谷':('Kül Kanyonu','Ash Canyon'),'利齿峰':('Sivridiş Zirvesi','Sharptooth Peak'),'利齿峰北':('Sivridiş Zirvesi Kuzey','Sharptooth Peak North'),'利齿峰东':('Sivridiş Zirvesi Doğu','Sharptooth Peak East'),
'流铁废墟':('Akandemir Harabeleri','Flowing Iron Ruins'),'英雄陵寝':('Kahraman Mezarlığı','Hero Mausoleum'),'极寒墓穴':('Dondurucu Mezar','Frigid Tomb'),'外侧陵寝':('Dış Mezarlık','Outer Mausoleum'),'陪葬之间':('Gömü Odası','Burial Chamber'),
'安息之间':('Huzur Odası','Chamber of Rest'),'英雄墓':('Kahraman Mezarı',"Hero's Tomb"),'侍僧之间':('Rahip Yardımcısı Odası','Acolyte Chamber'),'神秘荒野':('Gizemli Yaban','Mystic Wilds'),'神秘森林':('Gizemli Orman','Mystic Forest'),'神秘大厅':('Gizemli Salon','Mystic Hall'),
'神秘地洞':('Gizemli Oyuk','Mystic Burrow'),'雪崩地':('Çığ Alanı','Avalanche Ground'),'死灰之森':('Ölü Kül Ormanı','Dead Ash Forest'),'断剑丘陵':('Kırık Kılıç Tepeleri','Broken Sword Hills'),'大宴会场':('Büyük Şölen Salonu','Grand Banquet Hall'),'血色港湾':('Kızıl Liman','Crimson Harbor'),
'奥术图书馆':('Gizem Kütüphanesi','Arcane Library'),'骷髅杯大奖赛':('İskelet Kupası Turnuvası','Skull Cup Grand Prix'),'雪山之巅':('Karlı Dağ Doruğu','Snow Mountain Summit'),'繁星森林':('Yıldızlı Orman','Starry Forest'),'古竞技场遗址':('Eski Arena Kalıntıları','Ancient Arena Ruins'),
'风暴竞技场':('Fırtına Arenası','Storm Arena'),'古代通道':('Kadim Geçit','Ancient Passage'),'矮人山丘':('Cüce Tepesi','Dwarf Hill'),'瘟疫坡':('Veba Yamacı','Plague Slope'),'乐园之门':('Cennet Kapısı','Gate of Paradise'),'远古鸿沟':('Kadim Uçurum','Ancient Chasm'),
'BOSS之家':('Patronların Evi','Boss House'),'荒芜小径':('Issız Patika','Barren Path'),'逆风峡谷':('Karşıyel Kanyonu','Headwind Canyon'),'怒歌营地':('Öfke Türküsü Kampı','Furysong Camp'),'望日城':('Güneşgören Şehri','Sunwatch City'),
'望山城':('Dağgören Şehri','Mountainwatch City'),'金波港':('Altındalga Limanı','Goldwave Harbor'),
}
# ---------- NPC, canavar ve nesne adları (bölge bölge eklenir) ----------
N={
# Güneşli Orman çevresi, Trol Ormanı, Karanlık Gözcü Kulesi, Tarikat Üssü zindanı
'残破的日记':('Yırtık Günlük','Tattered Diary'),'酢浆草':('Yonca','Wood Sorrel'),'☆邪教追随者':('☆Tarikat Müridi','☆Cult Follower'),'鲜血蠕虫':('Kan Solucanı','Blood Worm'),
'喷毒蠕虫':('Zehir Püskürten Solucan','Venom Spitter Worm'),'毁☆灭☆鸭':('Yıkım Ördeği','Duck of Doom'),'枯骨草':('Kemik Otu','Bonegrass'),'☆觅血妖刀':('☆Kan Arayan Lanetli Kılıç','☆Bloodseeker Cursed Blade'),
'☆禁断法师':('☆Yasaklı Büyücü','☆Forbidden Mage'),'☆☆【迷心学者】哈维格尔':('☆☆【Akıl Çelen Bilgin】Havigel','☆☆【Mind-Bending Scholar】Havigel'),'☆狂信武士':('☆Bağnaz Savaşçı','☆Zealot Warrior'),
'凶恶蝙蝠':('Azılı Yarasa','Vicious Bat'),'☆吸血蝙蝠':('☆Vampir Yarasa','☆Vampire Bat'),'☆暗尘仙子':('☆Kara Toz Perisi','☆Darkdust Fairy'),'灵能之刃':('Ruh Gücü Kılıcı','Psionic Blade'),
'☆邪意屠戮者':('☆Kötücül Kasap','☆Malevolent Slaughterer'),'☆【叛神者】托马斯杨':('☆【Tanrı Haini】Thomas Young','☆【God Betrayer】Thomas Young'),'☆石像守卫':('☆Taş Heykel Muhafız','☆Stone Statue Guard'),
'普通副本-尘泥矿坑(50级)':('Normal Zindan · Tozçamur Madeni (Sv 50)','Normal Dungeon · Dustmud Mine (Lv 50)'),'洛米':('Lomi','Lomi'),'嗜血暴徒':('Kana Susamış Haydut','Bloodthirsty Thug'),
'☆嗜血游荡者':('☆Kana Susamış Serseri','☆Bloodthirsty Wanderer'),'☆暮色召唤者':('☆Alacakaranlık Çağırıcısı','☆Twilight Summoner'),'英雄副本-尘泥矿坑(50级)':('Kahraman Zindanı · Tozçamur Madeni (Sv 50)','Heroic Dungeon · Dustmud Mine (Lv 50)'),
'☆邪教献祭者':('☆Tarikat Kurbancısı','☆Cult Sacrificer'),'☆灭寂之灵':('☆Sönmüş Ruh','☆Spirit of Extinction'),'☆恐惧卫士':('☆Korku Muhafızı','☆Fear Guard'),'☆凝望守卫':('☆Gözcü Muhafız','☆Gazing Guard'),
'灵魂收割者':('Ruh Biçici','Soul Reaper'),'☆灵魂碎裂者':('☆Ruh Parçalayıcı','☆Soul Shatterer'),'☆血腥献祭者':('☆Kanlı Kurbancı','☆Bloody Sacrificer'),'夜精灵渗透者':('Gece Elfi Casusu','Night Elf Infiltrator'),
'☆死亡禁卫':('☆Ölüm Muhafızı','☆Death Guard'),'☆☆【偷心法师】罗姆塞恩':('☆☆【Kalp Hırsızı Büyücü】Romsen','☆☆【Heart-Stealing Mage】Romsen'),'森林警卫官':('Orman Muhafız Subayı','Forest Guard Officer'),
# Karanlık Gözcü Kulesi çevresindeki korular
'☆吸血仙子':('☆Kan Emici Peri','☆Bloodsucking Fairy'),'林地夜行者':('Koru Gece Avcısı','Woodland Nightstalker'),'暗影巨魔':('Gölge Trolü','Shadow Troll'),'完好的遗迹':('Sağlam Kalıntı','Intact Relic'),
'织网毒蜘蛛':('Ağ Ören Zehirli Örümcek','Webspinner Venom Spider'),'剑蜘蛛':('Kılıç Örümceği','Sword Spider'),'☆【欺诈女王】科琳娜':('☆【Hilekâr Kraliçe】Corinna','☆【Deceiver Queen】Corinna'),
'☆蜘蛛护卫':('☆Örümcek Muhafız','☆Spider Guard'),'堕落学者':('Yozlaşmış Bilgin','Fallen Scholar'),'☆仙子邪术师':('☆Peri Büyücüsü','☆Fairy Sorcerer'),'无脑僵尸':('Beyinsiz Zombi','Brainless Zombie'),
'☆剧毒撕裂者':('☆Zehirli Parçalayıcı','☆Venomous Ripper'),'污染者':('Kirletici','Defiler'),'☆鬼巨魔':('☆Hayalet Trol','☆Ghost Troll'),'奔马城城主':('Koşanat Şehri Beyi','Lord of Galloping Horse City'),
'【工人】乔治':('【İşçi】George','【Worker】George'),'【美女炼金师】爱丽丝':('【Güzel Simyacı】Alice','【Beautiful Alchemist】Alice'),'【兽医】詹姆斯':('【Veteriner】James','【Vet】James'),'【蠢蛋将军】米斯特':('【Ahmak General】Mister','【Blockhead General】Mister'),
}
# görev çeviri dosyalarındaki adlar (kaynak/ceviri/gorevler/*.json -> "adlar")
import glob as _glob
for _f in sorted(_glob.glob('kaynak/ceviri/gorevler/*.json')):
    if _f.endswith('_kaynak.json'): continue
    for _k, _v in json.load(open(_f, encoding='utf-8')).get('adlar', {}).items(): N.setdefault(_k, tuple(_v))
# genel ad dosyaları (görevsiz): kaynak/ceviri/adlar/*.json  {Çince: [Türkçe, İngilizce]}
for _f in sorted(_glob.glob('kaynak/ceviri/adlar/*.json')):
    for _k, _v in json.load(open(_f, encoding='utf-8')).items():
        if not _k.startswith('_'): N.setdefault(_k, tuple(_v))
NUM={'一':1,'二':2,'三':3,'四':4,'五':5,'六':6,'七':7,'八':8,'九':9}
def tr(n):
    if n in B: return B[n]
    m=re.match(r'^(.*?)(地下)?第?([一二三四五六七八九\d])层$',n)
    if m and m.group(1) in B:
        t,e=B[m.group(1)]; k=NUM.get(m.group(3)) or int(m.group(3))
        return (f'{t} Bodrum {k}. Kat',f'{e} B{k}') if m.group(2) else (f'{t} {k}. Kat',f'{e} Floor {k}')
    m=re.match(r'^(.*)顶层$',n)
    if m and m.group(1) in B: t,e=B[m.group(1)]; return (t+' Tepe Katı',e+' Top Floor')
    m=re.match(r'^(.*)裂隙$',n)
    if m and m.group(1) in B: t,e=B[m.group(1)]; return (t+' Yarığı',e+' Rift')
    m=re.match(r'^梦中的(.*)$',n)
    if m and m.group(1) in B: t,e=B[m.group(1)]; return ('Rüyadaki '+t,'Dream '+e)
    return None
sc=json.load(open('www/assets/data.json'))['scenes']
src=open('www/js/tr.js').read()
T={};E={};miss=[]
for s in sc.values():
    n=s['name']
    if f"'{n}'" in src or n in T: continue
    r=tr(n)
    if r: T[n],E[n]=r
    else: miss.append(n)
print(len(T),'eksik',miss)
NT={k:v[0] for k,v in N.items() if f"'{k}'" not in src}; NE={k:v[1] for k,v in N.items() if f"'{k}'" not in src}
dj=lambda o: json.dumps(o,ensure_ascii=False,separators=(',',':'))
js="// Harita ve varlık adları: orijinal Çince adların Türkçe ve İngilizce karşılıkları. tools/ceviri.py üretir; elle değiştirme.\n'use strict';\nObject.assign(TR.scene, LANG === 'en' ? "+dj(E)+" : "+dj(T)+");\nObject.assign(TR.name, LANG === 'en' ? "+dj(NE)+" : "+dj(NT)+");\n"
open('www/js/tr_scenes.js','w').write(js); print('ad',len(NT))
# durum: sahnelerdeki adların ne kadarı çevrildi
allsrc=src+js; ents={e[1] for s in sc.values() for e in s['ents']}
print('varlık adı',len(ents),'çevrilmiş',sum(1 for n in ents if f"'{n}'" in allsrc or f'"{n}"' in allsrc))
