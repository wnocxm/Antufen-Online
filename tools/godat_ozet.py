# -*- coding: utf-8 -*-
# godat özeti (Python tarafı): her kayıt için numara, ad (onaltılık), açılmış boy, CRC32.
# C++ native/src/tools/godat_dump.cpp ile aynı biçim; eşitlik testi tools/test/godat_esitlik.py.
# Kullanım: python3 tools/godat_ozet.py <dosya.godat>
import sys, zlib, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from godat import named

def ozet(path):
    out = []
    E = named(path)
    out.append('kayıt\t%d' % len(E))
    for i, name, data in E:
        out.append('%d\t%s\t%d\t%08x' % (i, name.encode('latin1').hex(), len(data), zlib.crc32(data) & 0xffffffff))
    return '\n'.join(out) + '\n'

if __name__ == '__main__':
    sys.stdout.write(ozet(sys.argv[1]))
