// Ağ (aşama 1) sınaması: kayıttan yeniden oynatma (agtest.cpp; docs/10-ag.md).
#pragma once
#include <cstdint>
#include <string>

#include "core/json.h"
#include "engine/world.h"

namespace agtest {
// bot oynar, kaydı (başlangıç + yönler + komutlar + özetler) JSON olarak döner
std::string botRun(engine::Assets& as, engine::Balance& bal, const core::Json& save, uint32_t seed, double clock0, double seconds, uint32_t botSeed, uint64_t* finalDigest = nullptr);
// kaydı yeni dünyada yeniden oynatır; rapor JSON'u (aynı / farklı özet sayısı, ilk fark adımı)
std::string replay(engine::Assets& as, engine::Balance& bal, const core::Json& rec, uint64_t* finalDigest = nullptr);
}
