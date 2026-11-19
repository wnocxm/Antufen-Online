// Evcil hayvanlar (魔法兽): veri (www/assets/pets.json ← tools/evcil.py) ve kayıt yapıları. Oyun mantığı world_pet.cpp (HTML pet.js).
// Ayrıntı: docs/07-evcil.md. Not (JS'ten): türün doğuştan becerisi metin ("90146"), rastgele beceriler şablon havuzundan sayı olarak gelir;
// JS'te ikisi hiç eşit sayılmaz (=== tür denetimi). C++'ta da doğuştan beceri rastgelelerle karşılaştırılmaz.
#pragma once
#include <map>
#include <string>
#include <vector>

#include "core/json.h"

namespace engine {

class Sprite;

struct PetForm { std::string cn, tr, en, look; std::vector<std::string> sayTr; };
struct PetSpecies { std::string cn, tr, en, egg, box, skill; int tpl = 0; bool apk = false; std::vector<PetForm> forms; std::vector<std::string> chatTr; };
struct PetTemplate { std::string tr, en; bool mag = false; double hpG = 0, mpG = 0, patk = 0, matk = 0, def = 0, dodge = 0; std::vector<std::string> pool; };
struct PetStage { int cost = 0, lv = 1; double mult = 1; };
struct PetSkillInfo { std::string tr, desc, en, ik, kind; int icon = 0; };

struct PetData {
  std::vector<PetSpecies> species;
  std::map<int, PetTemplate> templates;
  std::vector<PetStage> stages;
  std::map<std::string, PetSkillInfo> skills;
  void load(const core::Json& J);
  const PetSpecies* by(const std::string& cn) const { for (const PetSpecies& s : species) if (s.cn == cn) return &s; return nullptr; }
  bool ok() const { return !species.empty(); }
};

// kayıttaki evcil hayvan (HTML P.pets[]): st dönüşüm düzeyi 0-7, sk rastgele beceriler, sat tokluk, joy mutluluk, tal yetenek
struct PetRec {
  std::string uid, sp, name;
  int st = 0, lv = 1;
  std::vector<std::string> sk;
  double xp = 0, hp = 0, mp = 0, sat = 100, joy = 100, tal = 1, deadAt = 0;
  bool dead = false;
  std::map<std::string, double> gift;   // yetenek meyveleri (patk, matk, hp: binde)
};

// çağrılmış hayvanın dünyadaki varlığı (HTML PetEnt); gen: her çağrılışta yeni (canavarların hedefi bununla tanınır)
struct PetEnt {
  bool on = false; int gen = 0; std::string uid;
  double x = 0, y = 0, t = 0, animT = 0, atkT = 0, skT = 0, combatT = 0, chatT = 0, auraT = 0, stateT = 0, sayT = 0;
  std::string state = "idle", say, lk; int dir = 2; char ax = 0;
  Sprite* sp = nullptr;
  std::map<std::string, double> cd;
  bool buffOn = false; double buffDef = 0, buffT = 0;          // kendine güçlendirme (savunma)
  bool fieldOn = false; double fieldT = 0, fieldTick = 0;      // Kan Yakan Kalkan
  int tg = -1;                                                  // hedef canavar (varlık sırası)
};

}  // namespace engine
