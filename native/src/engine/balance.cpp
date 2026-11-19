#include "balance.h"
#include "engine/lang.h"

#include <algorithm>
#include <cmath>
#include <set>

#include "engine/rng.h"

namespace engine {

using core::jsOrder;

std::string lookFamily(const std::string& look) {
  // /^(怪物-[^-]+|[^-]+)(-.*)?$/ → $1
  const std::string pre = "怪物-";
  if (look.rfind(pre, 0) == 0) { size_t e = look.find('-', pre.size()); return e == std::string::npos ? look : look.substr(0, e); }
  size_t e = look.find('-'); return e == std::string::npos ? look : look.substr(0, e);
}

void Balance::load(const Vfs& vfs, const core::Json& D) {
  D_ = &D;
  const core::Json B = core::Json::parse(vfs.readText("denge.json"));
  for (const core::Json& v : B["XPT"].arr()) xpt_.push_back((long long)v.num());
  for (const core::Json& v : B["MXPT"].arr()) mxpt_.push_back((long long)v.num());
  for (const auto& kv : B["MON"].obj()) {
    const core::Json& m = kv.second; auto d = std::make_unique<MonDef>();
    d->lv = m["lv"].i(0); d->rank = m["rank"].i(0); d->n = m["n"].i(0); d->wide = m["wide"].i(0); d->xp = (long long)m["xp"].num(0);
    d->passive = m["passive"].truthy(); d->dummy = m["dummy"].truthy(); d->skip = m["skip"].truthy(); d->solo = m["solo"].truthy();
    mon_[kv.first] = std::move(d);
  }
  for (const auto& kv : B["CLS"].obj()) {
    const core::Json& c = kv.second; ClassBase b;
    b.hp = c["hp"].num(); b.mp = c["mp"].num(); b.atk = c["atk"].num(); b.def = c["def"].num();
    b.ghp = c["ghp"].num(); b.gmp = c["gmp"].num(); b.gatk = c["gatk"].num(); b.gdef = c["gdef"].num();
    b.dmgK = c["dmgK"].num(1); b.range = c["range"].num(1.4); b.melee = c["melee"].truthy(); b.bolt = c["bolt"].str(); b.boltHit = c["boltHit"].str(); b.snd = c["snd"].str();
    cls_[kv.first] = b;
  }
  const core::Json I = core::Json::parse(vfs.readText("items.json"));
  for (const auto* kv : jsOrder(I["items"])) {
    const core::Json& it = kv->second; Item x; x.id = kv->first; x.slot = it["slot"].str(); x.cls = it["cls"].str(); x.lv = it["lv"].i(0); x.name = it["name"].str(); x.en = it["en"].str();
    x.ik = it["icon"][0].isStr() ? it["icon"][0].str() : "item"; x.icon = it["icon"][1].i();
    const core::Json& u = it["use"];
    if (u.isObj()) {
      x.use = true; x.useHp = u["hp"].num(); x.useMp = u["mp"].num(); x.qt = u["qt"].truthy();
      auto hot = [](const core::Json& h, Item::Hot& o) { if (h.isArr()) { o.res = h[0].str(); o.amt = h[1].num(); o.sec = h[2].num(); } };
      hot(u["hot"], x.hot); hot(u["hot2"], x.hot2);
    }
    for (const auto& s : it["st"].obj()) { x.st[s.first] = s.second.num(); x.stOrder.push_back(s.first); }
    x.desc = it["desc"].str(); x.gfx = it["gfx"].str();
    if (lang().en) { x.name = !x.en.empty() ? x.en : !lang().item(x.name).empty() ? lang().item(x.name) : x.name; x.desc = it["den"].isStr() ? it["den"].str() : tx(x.desc); }   // HTML loadItems
    x.price = it["price"].i(0); x.sell = it["sell"].i(0); x.pet = it["pet"].truthy(); x.petJ = it["pet"];
    itemIdx_[x.id] = items_.size(); items_.push_back(std::move(x));
  }
  for (const auto& kv : I["shops"].obj()) {
    shops.insert(kv.first); auto& T = shopTabs[kv.first];
    for (const core::Json& t : kv.second.arr()) { ShopTab x; x.name = t[0].str(); for (const core::Json& id : t[1].arr()) x.ids.push_back(id.str()); T.push_back(std::move(x)); }
  }
  for (const auto& hp : std::vector<std::pair<std::string, std::string>>{{"道具商人（人类）", "道具商人（夜精灵）"}, {"武器商人（人类）", "武器商人（夜精灵）"}, {"防具商人（人类）", "防具商人（夜精灵）"}, {"饰品商人（人类）", "饰品商人（夜精灵）"}})
    if (shops.count(hp.first)) { shops.insert(hp.second); shopTabs[hp.second] = shopTabs[hp.first]; }   // gece elfi tüccarları aynı listeleri satar
  // oyunun kendi eşyaları (HTML game.js ITEMS; tablodakilerden sonra — JS nesne sırası: sayısal numaralar önce)
  auto own = [&](const char* id, const char* nm, int icon, const char* desc, int price, double hp, double mp, bool growth) {
    Item x; x.id = id; x.name = tx(nm); x.ik = "item"; x.icon = icon; x.desc = tx(desc); x.price = price; x.useHp = hp; x.useMp = mp; x.use = hp || mp; x.growth = growth;
    x.quest = x.id == "quest"; itemIdx_[x.id] = items_.size(); items_.push_back(std::move(x));
  };
  own("hp1", "Zayıf Can İksiri", 1019, "800 can yeniler.", 20, 800, 0, false); own("hp2", "Can İksiri", 1020, "2000 can yeniler.", 80, 2000, 0, false);
  own("mp1", "Zayıf Mana İksiri", 1026, "800 mana yeniler.", 20, 0, 800, false); own("mp2", "Mana İksiri", 1024, "2000 mana yeniler.", 80, 0, 2000, false);
  own("growthBox", "Gelişim Paketi", 1038, "Aç: seviyene uygun ekipman ve iksir çıkar.", 0, 0, 0, true); own("quest", "Görev Eşyası", 1125, "Görev için gerekli.", 0, 0, 0, false);
  // canavar kayıtları; veri düzeltmesi (HTML fixMonData): ☆☆【小胖】拉斯 kaydında görünüm ile ölüm efekti yer değiştirmiş
  auto fx = [](const std::string& s) { return s.rfind("特效-", 0) == 0; };
  for (const auto* kv : jsOrder(D["mon"])) {
    const core::Json& v = kv->second; if (!v.isArr() || !v.size()) continue;
    MobRec r{v[0].str(), v[1].str(), v[2].str()};
    if (v.size() > 2 && fx(r.look) && !fx(r.deathFx)) std::swap(r.look, r.deathFx);
    for (const core::Json& f : v.arr()) if (f.str() == "instance_progress") r.prog = true;
    mobById_[kv->first] = r;
    if (!mobByName_.count(r.name)) mobByName_[r.name] = kv->first;
  }
  // zindanlar; zindan haritalarının seviye aralığı tanımdan (HTML Dungeon.init, ilk harita yüklenmeden önce): canavar seviyeleri ve
  // görevlerin açılma seviyesi bundan
  if (vfs.exists("zindan.json")) {
    const core::Json Z = core::Json::parse(vfs.readText("zindan.json"));
    core::Json* scenes = const_cast<core::Json&>(D).mut("scenes");   // veri nesnesi Assets'te değiştirilebilir; burada yalnız lvr yazılır
    for (const core::Json& z : Z["dungeons"].arr()) {
      DungeonDef d; d.id = z["id"].str(); d.cn = z["cn"].str(); d.board = z["board"].str(); d.boss = z["boss"].str(); d.lv = z["lv"].i(); d.lvr0 = z["lvr"][0].i(); d.lvr1 = z["lvr"][1].i();
      d.daily = z["daily"].i(); d.req = z["req"].i(); d.train = z["train"].truthy(); d.bossX = z["bossX"].num();
      for (const core::Json& c : z["copies"].arr()) {
        DungeonCopy k; k.doorScene = c["door"][0].str(); k.doorRegion = c["door"][1].i(); for (const core::Json& sc : c["scenes"].arr()) k.scenes.push_back(sc.str());
        if (scenes) for (const std::string& sid : k.scenes) if (core::Json* S = scenes->mut(sid)) S->set("lvr", core::Json::array({core::Json::number(d.lvr0), core::Json::number(d.lvr1)}));
        d.copies.push_back(std::move(k));
      }
      dungeons.push_back(std::move(d));
    }
    for (const auto& kv : Z["exit"].obj()) dungeonExit[kv.first] = {kv.second[0].str(), {kv.second[1].i(), kv.second[2].i()}};
    for (const auto& kv : Z["tp"].obj()) { DungeonTp t; t.sid = kv.second["to"][0].str(); t.hasXY = kv.second["to"][1].isNum(); t.x = kv.second["to"][1].i(); t.y = kv.second["to"][2].i(); t.lv = kv.second["lv"].i(); t.label = kv.second["label"][0].str(); dungeonTp[kv.first] = t; }
  }
  skills.load(vfs);
  if (vfs.exists("quests.json")) quests.load(vfs, D);
  if (vfs.exists("zindan.json")) {   // pano sözleri (konuşma)
    const core::Json Z = core::Json::parse(vfs.readText("zindan.json"));
    for (const auto& kv : Z["greet"]["tr"].obj()) quests.addGreet(kv.first, kv.second.str(), Z["greet"]["en"][kv.first].str());
  }
  if (vfs.exists("travel.json")) {
    const core::Json T = core::Json::parse(vfs.readText("travel.json"));
    for (const auto& kv : T["npc"].obj()) for (const core::Json& o : kv.second.arr()) {
      TravelOpt t; t.kind = o[0].str(); t.name = o[1].str(); t.sid = o[2].isNum() ? std::to_string(o[2].i()) : o[2].str(); t.hasXY = o[3].isNum(); t.x = o[3].i(); t.y = o[4].i();
      travel[kv.first].push_back(t);
    }
    travelCar = T["cost"]["araba"].i(100);
    for (const auto& kv : T["ucret"].obj()) travelFee[kv.first] = kv.second.i();
  }
  if (vfs.exists("pets.json")) {
    const core::Json P = core::Json::parse(vfs.readText("pets.json"));
    for (const core::Json& s : P["species"].arr()) if (!s["apk"].truthy()) eggFam_.push_back({lookFamily(s["forms"][0]["look"].str()), s["egg"].str()});
    pets.load(P);
  }
}

MonDef& Balance::monDef(const std::string& nm, const core::Json& sc) {
  const core::Json& R = sc["lvr"];
  auto it = mon_.find(nm);
  if (it != mon_.end()) {
    MonDef& d = *it->second;
    // elle yazılmış değer sahnenin gerçek seviye aralığının dışındaysa aralığa çekilir (bir kez)
    if (R.isArr() && !d.autoDef && !d.fit && d.lv) {
      d.fit = true;
      const int lv = int(clampd(d.lv, R[0].i(), R[1].i() + (d.rank == 2 ? 2 : d.rank ? 1 : 0)));
      if (lv != d.lv) { d.lv = lv; d.xp = mobXp(lv, d.rank); }
    }
    return d;
  }
  auto has = [&](const char* s) { return nm.find(s) != std::string::npos; };
  const int rank = (nm.rfind("☆☆", 0) == 0 || nm.rfind("★", 0) == 0) ? 2 : has("☆") ? 1 : 0;
  const int S = sc["lv"].i(0) ? sc["lv"].i() : 1;
  std::vector<std::string> kinds;   // sahnedeki yıldızsız canavar türleri (sırasıyla, tekrarsız)
  for (const core::Json& e : sc["ents"].arr()) {
    const std::string id = std::to_string(e[0].i()), n = e[1].str();
    if ((*D_)["mon"][id].isArr() && n.find("☆") == std::string::npos && std::find(kinds.begin(), kinds.end(), n) == kinds.end()) kinds.push_back(n);
  }
  int i = 0; { auto f = std::find(kinds.begin(), kinds.end(), nm); if (f != kinds.end()) i = int(f - kinds.begin()); }
  int lv;
  if (R.isArr()) { const int a = R[0].i(), b = R[1].i(); lv = rank == 2 ? b + 2 : rank ? b + 1 : a + int(jsRound(i * double(b - a) / std::max(1, int(kinds.size()) - 1))); }
  else {
    const int base = std::max(1, S - 9), span = std::max(1, std::min(9, int(kinds.size())));
    lv = std::min(S + 5, base + int(jsRound(i * 8.0 / span)) + (rank == 2 ? 6 : rank ? 3 : 0));
  }
  auto d = std::make_unique<MonDef>();
  d->lv = lv; d->rank = rank; d->xp = mobXp(lv, rank); d->n = rank == 2 ? 1 : rank ? 2 : 7; d->wide = rank ? 4 : 8; d->autoDef = true;
  MonDef& ref = *d; mon_[nm] = std::move(d); return ref;
}

long long Balance::mobXp(int lv, int rank) const {
  const int k = int(clampd(lv, 1, double(mxpt_.size()) - 1));
  return (long long)jsRound(mxpt_[k] * (rank == 2 ? 25 : rank ? 3 : 1));
}
long long Balance::xpNeed(int l) const { return xpt_[size_t(clampd(jsRound(l), 1, double(xpt_.size()) - 1))]; }

const ClassBase& Balance::cls(const std::string& c) const {
  auto it = cls_.find(c); if (it != cls_.end()) return it->second;
  static const ClassBase none; return none;
}
const Item* Balance::item(const std::string& id) const { auto it = itemIdx_.find(id); return it == itemIdx_.end() ? nullptr : &items_[it->second]; }
const Balance::MobRec* Balance::mobById(const std::string& id) const { auto it = mobById_.find(id); return it == mobById_.end() ? nullptr : &it->second; }
const Balance::MobRec* Balance::mobInfo(const std::string& name) const { auto it = mobByName_.find(name); return it == mobByName_.end() ? nullptr : mobById(it->second); }
const std::string* Balance::eggFor(const std::string& look) const {
  const std::string f = lookFamily(look);
  for (const auto& e : eggFam_) if (e.first == f) return &e.second;
  return nullptr;
}

}  // namespace engine

namespace engine {
static std::string jsKey(const core::Json& v) { if (v.isStr()) return v.str(); const double d = v.num(); return std::floor(d) == d ? std::to_string((long long)d) : std::to_string(d); }
void PetData::load(const core::Json& J) {
  species.clear(); templates.clear(); stages.clear(); skills.clear();
  for (const core::Json& s : J["species"].arr()) {
    PetSpecies x; x.cn = s["cn"].str(); x.tr = s["tr"].str(); x.en = s["en"].str(); if (lang().en && !x.en.empty()) x.tr = x.en;   // .tr: seçili dil
    x.egg = s["egg"].str(); x.box = s["box"].str(); x.skill = jsKey(s["skill"]); x.tpl = s["tpl"].i(); x.apk = s["apk"].truthy();
    for (const core::Json& f : s["forms"].arr()) { PetForm k; k.cn = f["cn"].str(); k.tr = f["tr"].str(); k.en = f["en"].str(); k.look = f["look"].str(); if (lang().en && !k.en.empty()) k.tr = k.en;
      for (const core::Json& t : f[lang().en ? "sayEn" : "sayTr"].arr()) k.sayTr.push_back(t.str());
      x.forms.push_back(std::move(k));
    }
    for (const core::Json& t : s[lang().en ? "chatEn" : "chatTr"].arr()) x.chatTr.push_back(t.str());   // seçili dil
    species.push_back(std::move(x));
  }
  for (const auto& kv : J["templates"].obj()) {
    const core::Json& t = kv.second; PetTemplate x; x.tr = t["tr"].str(); x.en = t["en"].str(); if (lang().en && !x.en.empty()) x.tr = x.en; x.mag = t["cls"].str() == "mag";
    x.hpG = t["hp_growth"].num(); x.mpG = t["mp_growth"].num(); x.patk = t["base_phys_atk"].num(); x.matk = t["base_mag_atk"].num(); x.def = t["base_def"].num(); x.dodge = t["dodge"].num();
    for (const core::Json& k : t["pool"].arr()) x.pool.push_back(jsKey(k));
    templates[std::atoi(kv.first.c_str())] = std::move(x);
  }
  for (const core::Json& s : J["stages"].arr()) stages.push_back({s["cost"].i(), s["lv"].i(1), s["mult"].num(1)});
  for (const auto& kv : J["skills"].obj()) { const core::Json& k = kv.second; PetSkillInfo x; x.tr = k["tr"][0].str(); x.desc = k["tr"][1].str(); x.en = k["en"][0].str(); if (lang().en) { if (!x.en.empty()) x.tr = x.en; if (k["en"][1].isStr()) x.desc = k["en"][1].str(); } x.icon = k["icon"].i(); x.ik = k["ik"].str(); x.kind = k["kind"].str(); skills[kv.first] = std::move(x); }
}
}  // namespace engine
