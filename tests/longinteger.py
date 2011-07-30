
import sys, os, random

def modexp(p,e,mod):
    r = 1
    t = p
    while e:
        if e & 1:
            r = (r * t) % mod
        e = e >> 1
        t = (t * t) % mod
    return r

def invmod(p,mod):
    b = mod
    c = p
    i = 0
    j = 1
    while c:
        x = b / c
        y = b % c
        b = c
        c = y
        i, j = j, (i-(j*x))
    if i < 0: i += mod
    return i

def gen_long(l = 0):
    if not l:
        l = int(random.random()*64) + 1;
    Q = os.urandom(l)
    L = 0L
    for i in range(l):
        L = L << 8 | ord(Q[i])
    return L

def gen_mul(n):
    for i in range(n):
        a = gen_long()
        b = gen_long()
        r = a * b
        print '*',a,b,0,r

def gen_add(n):
    for i in range(n):
        a = gen_long()
        b = gen_long()
        r = a + b
        print '+',a,b,0,r

def gen_sub(n):
    for i in range(n):
        a = gen_long()
        b = gen_long()
        r = a - b
        print '-',a,b,0,r

def gen_div(n):
    for i in range(n):
        a = gen_long()
        while True:
            b = gen_long()
            if b: break
        if b > a : a,b = b,a
        r = a / b
        print '/',a,b,0,r

def gen_mod(n):
    for i in range(n):
        a = gen_long()
        while True:
            b = gen_long()
            if b: break
        if b > a : a,b = b,a
        r = a % b
        print '%',a,b,0,r

def gen_modexp(n):
    for i in range(n):
        a = gen_long()
        b = gen_long()
        while True:
            c = gen_long()
            if c: break
        r = modexp(a,b,c)
        print '**%',a,b,c,r

def gen_mulmod(n):
    for i in range(n):
        a = gen_long()
        b = gen_long()
        while True:
            c = gen_long()
            if c: break
        r = a*b % c
        print '*%',a,b,c,r

def gen_invmod(n):
    for i in range(n):
        a = gen_long()
        while True:
            b = gen_long()
            if b: break
        r = invmod(a,b)
        print '*/%',a,b,0,r

def gen_lshift(n):
    for i in range(n):
        a = gen_long()
        b = int(random.random()*127)+1
        c = b
        r = a
        while c:
            if c > 8:
                r = r << 8
                c -= 8
            else:
                r = r << c
                c = 0
        print '<<',a,b,r&0xffffffff,r

def gen_rshift(n):
    for i in range(n):
        a = gen_long()
        b = int(random.random()*127)+1
        c = b
        r = a
        while c:
            if c > 8:
                r = r >> 8
                c -= 8
            else:
                r = r >> c
                c = 0
        print '>>',a,b,r&0xffffffff,r

if len(sys.argv) > 1:
    N = int(sys.argv[1])
else:
    N = 100

gen_invmod(N)
gen_rshift(N)
gen_lshift(N)
gen_sub(N)
gen_add(N)
gen_mod(N)
gen_div(N)
gen_mul(N)
gen_modexp(N)
gen_mulmod(N)

def test():
    a = gen_long()
    while True:
        b = gen_long()
        if b and b > 0: break;
    if ((a%b)*(a%b))%b != (a*a)%b:
        raise Exception("failed")
        
        
#for i in range(1000):
#    test()
