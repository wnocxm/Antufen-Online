import sys,struct; sys.path.insert(0,'tools')
from godat import named
def isstr(b,i):
    if i+4>len(b): return None
    n=struct.unpack_from('<I',b,i)[0]
    if not (1<=n<=400 and i+4+2*n<=len(b)): return None
    try: s=b[i+4:i+4+2*n].decode('utf-16le')
    except UnicodeDecodeError: return None
    if not all(c.isprintable() for c in s): return None
    if n<=2 and not any(ord(c)>0x2e80 for c in s): return None
    return s
def toks(b):
    out=[];i=0
    while i<len(b):
        s=isstr(b,i)
        if s is not None: out.append(s); i+=4+2*len(s); continue
        if i+4<=len(b): out.append(struct.unpack_from('<i',b,i)[0]); i+=4
        else: out.append('b:'+b[i:].hex()); break
    return out
def table(f): return {i:(n,toks(d)) for i,n,d in named('files/%s.godat'%f)}
if __name__=='__main__':
    T=table(sys.argv[1]); ks=list(T)[:int(sys.argv[2]) if len(sys.argv)>2 else 10]
    for k in ks:
        n,t=T[k]; print(k,[x if not isinstance(x,str) else x[:16] for x in t])
