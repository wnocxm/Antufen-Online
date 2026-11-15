#!/bin/sh
# Android sürümünün (APK) içindeki oyun kaynaklarını indirip çıkarır. Çıktı: kaynak/apk/cikti
# APK, deponun Releases bölümünde durur (apk-test / 1028.apk). Depo kökünden çalıştır:  sh tools/apk_cikar.sh
set -e
T=${TMPDIR:-/tmp}/anrufen_apk; mkdir -p "$T"
[ -s "$T/1028.apk" ] || curl -sSL --fail -o "$T/1028.apk" https://github.com/wnocxm/Antufen-Online/releases/download/apk-test/1028.apk
unzip -q -o "$T/1028.apk" 'assets/Resources/*' -d "$T/x"
python3 tools/extract_all.py "$T/x/assets/Resources" kaynak/apk/cikti
