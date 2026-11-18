#include "balance.h"

#include <algorithm>
#include <cmath>
#include <set>

#include "engine/rng.h"

namespace engine {

// JS nesnesinde tam sayı biçimli anahtarlar önce (artan), sonra diğerleri ekleme sırasıyla: Object.entries / for…in sırası
static std::vector<const std::pair<std::string, core::Json>*> jsOrder(const core::Json& o) {
  std::vector<const std::pair<std::string, core::Json>*> num, rest;
  for (const auto& kv : o.obj()) {
    const std::string& k = kv.first;
    const bool isInt = !k.empty() && k.size() < 10 && std::all_of(k.begin(), k.end(), ::isdigit) && (k == "0" || k[0] != '0');
    (isInt ? num : rest).push_back(&kv);
  }
  std::stable_sort(num.begin(), num.end(), [](auto* a, auto* b) { return std::stoll(a->first) < std::stoll(b->first); });
  num.insert(num.end(), rest.begin(), rest.end());
  return num;
}

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
    d->passive = m["passive"].b(); d->dummy = m["dummy"].b(); d->skip = m["skip"].b(); d->solo = m["solo"].i(0) != 0 || m["solo"].b();
    mon_[kv.first] = std::move(d);
  }
  for (const auto& kv : B["CLS"].obj()) {
    const core::Json& c = kv.second; ClassBase b;
    b.hp = c["hp"].num(); b.mp = c["mp"].num(); b.atk = c["atk"].num(); b.def = c["def"].num();
    b.ghp = c["ghp"].num(); b.gmp = c["gmp"].num(); b.gatk = c["gatk"].num(); b.gdef = c["gdef"].num();
    b.dmgK = c["dmgK"].num(1); b.range = c["range"].num(1.4); b.melee = c["melee"].b(); b.bolt = c["bolt"].str(); b.boltHit = c["boltHit"].str(); b.snd = c["snd"].str();
    cls_[kv.first] = b;
  }
  const core::Json I = core::Json::parse(vfs.readText("items.json"));
  for (const auto* kv : jsOrder(I["items"])) {
    const core::Json& it = kv->second; Item x; x.id = kv->first; x.slot = it["slot"].str(); x.cls = it["cls"].str(); x.lv = it["lv"].i(0);
    for (const auto& s : it["st"].obj()) x.st[s.first] = s.second.num();
    itemIdx_[x.id] = items_.size(); items_.push_back(std::move(x));
  }
  // canavar kayıtları; veri düzeltmesi (HTML fixMonData): ☆☆【小胖】拉斯 kaydında görünüm ile ölüm efekti yer değiştirmiş
  auto fx = [](const std::string& s) { return s.rfind("特效-", 0) == 0; };
  for (const auto* kv : jsOrder(D["mon"])) {
    const core::Json& v = kv->second; if (!v.isArr() || !v.size()) continue;
    MobRec r{v[0].str(), v[1].str(), v[2].str()};
    if (v.size() > 2 && fx(r.look) && !fx(r.deathFx)) std::swap(r.look, r.deathFx);
    mobById_[kv->first] = r;
    if (!mobByName_.count(r.name)) mobByName_[r.name] = kv->first;
  }
  if (vfs.exists("pets.json")) {
    const core::Json P = core::Json::parse(vfs.readText("pets.json"));
    for (const core::Json& s : P["species"].arr()) if (!s["apk"].b()) eggFam_.push_back({lookFamily(s["forms"][0]["look"].str()), s["egg"].str()});
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
