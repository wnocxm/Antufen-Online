import sys,struct,re
sys.path.insert(0,'tools')
from godat import records
def lstrings(b):
    out=[];i=0
    while i+4<=len(b):
        n=struct.unpack_from('<I',b,i)[0]
        if 1<=n<=400 and i+4+2*n<=len(b):
            raw=b[i+4:i+4+2*n]
            try:
                s=raw.decode('utf-16le')
                if all(c.isprintable() or c in '\n\r\t' for c in s):
                    out.append((i,s)); i+=4+2*n; continue
            except UnicodeDecodeError: pass
        i+=1
    return out
def dump(f, maxrec=99999, filt=None):
    for id_,b in records('files/'+f)[:maxrec]:
        ss=[s for o,s in lstrings(b)]
        if filt: ss=[s for s in ss if filt(s)]
        if ss: print(id_,' | '.join(x.replace('\n','⏎') for x in ss))
if __name__=='__main__':
    dump(sys.argv[1], int(sys.argv[2]) if len(sys.argv)>2 else 99999, (lambda s: re.search('[一-鿿]',s)) )
