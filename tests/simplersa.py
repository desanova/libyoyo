#!/usr/bin/env python
# 
# Simple RSA
# Copyright (c) 2007, Alexey Sudachen
# 

from random import random, randrange
from os import urandom
import sys,struct,time

_there_is_no_more = "there is no more then 500 primes"

first_500_prime_values = [
 2       ,3       ,5       ,7       ,11      ,13      ,17      ,19      ,23      ,29
,31      ,37      ,41      ,43      ,47      ,53      ,59      ,61      ,67      ,71
,73      ,79      ,83      ,89      ,97      ,101     ,103     ,107     ,109     ,113
,127     ,131     ,137     ,139     ,149     ,151     ,157     ,163     ,167     ,173
,179     ,181     ,191     ,193     ,197     ,199     ,211     ,223     ,227     ,229
,233     ,239     ,241     ,251     ,257     ,263     ,269     ,271     ,277     ,281
,283     ,293     ,307     ,311     ,313     ,317     ,331     ,337     ,347     ,349
,353     ,359     ,367     ,373     ,379     ,383     ,389     ,397     ,401     ,409
,419     ,421     ,431     ,433     ,439     ,443     ,449     ,457     ,461     ,463
,467     ,479     ,487     ,491     ,499     ,503     ,509     ,521     ,523     ,541
,547     ,557     ,563     ,569     ,571     ,577     ,587     ,593     ,599     ,601
,607     ,613     ,617     ,619     ,631     ,641     ,643     ,647     ,653     ,659
,661     ,673     ,677     ,683     ,691     ,701     ,709     ,719     ,727     ,733
,739     ,743     ,751     ,757     ,761     ,769     ,773     ,787     ,797     ,809
,811     ,821     ,823     ,827     ,829     ,839     ,853     ,857     ,859     ,863
,877     ,881     ,883     ,887     ,907     ,911     ,919     ,929     ,937     ,941
,947     ,953     ,967     ,971     ,977     ,983     ,991     ,997     ,1009    ,1013
,1019    ,1021    ,1031    ,1033    ,1039    ,1049    ,1051    ,1061    ,1063    ,1069
,1087    ,1091    ,1093    ,1097    ,1103    ,1109    ,1117    ,1123    ,1129    ,1151
,1153    ,1163    ,1171    ,1181    ,1187    ,1193    ,1201    ,1213    ,1217    ,1223
,1229    ,1231    ,1237    ,1249    ,1259    ,1277    ,1279    ,1283    ,1289    ,1291
,1297    ,1301    ,1303    ,1307    ,1319    ,1321    ,1327    ,1361    ,1367    ,1373
,1381    ,1399    ,1409    ,1423    ,1427    ,1429    ,1433    ,1439    ,1447    ,1451
,1453    ,1459    ,1471    ,1481    ,1483    ,1487    ,1489    ,1493    ,1499    ,1511
,1523    ,1531    ,1543    ,1549    ,1553    ,1559    ,1567    ,1571    ,1579    ,1583
,1597    ,1601    ,1607    ,1609    ,1613    ,1619    ,1621    ,1627    ,1637    ,1657
,1663    ,1667    ,1669    ,1693    ,1697    ,1699    ,1709    ,1721    ,1723    ,1733
,1741    ,1747    ,1753    ,1759    ,1777    ,1783    ,1787    ,1789    ,1801    ,1811
,1823    ,1831    ,1847    ,1861    ,1867    ,1871    ,1873    ,1877    ,1879    ,1889
,1901    ,1907    ,1913    ,1931    ,1933    ,1949    ,1951    ,1973    ,1979    ,1987
,1993    ,1997    ,1999    ,2003    ,2011    ,2017    ,2027    ,2029    ,2039    ,2053
,2063    ,2069    ,2081    ,2083    ,2087    ,2089    ,2099    ,2111    ,2113    ,2129
,2131    ,2137    ,2141    ,2143    ,2153    ,2161    ,2179    ,2203    ,2207    ,2213
,2221    ,2237    ,2239    ,2243    ,2251    ,2267    ,2269    ,2273    ,2281    ,2287
,2293    ,2297    ,2309    ,2311    ,2333    ,2339    ,2341    ,2347    ,2351    ,2357
,2371    ,2377    ,2381    ,2383    ,2389    ,2393    ,2399    ,2411    ,2417    ,2423
,2437    ,2441    ,2447    ,2459    ,2467    ,2473    ,2477    ,2503    ,2521    ,2531
,2539    ,2543    ,2549    ,2551    ,2557    ,2579    ,2591    ,2593    ,2609    ,2617
,2621    ,2633    ,2647    ,2657    ,2659    ,2663    ,2671    ,2677    ,2683    ,2687
,2689    ,2693    ,2699    ,2707    ,2711    ,2713    ,2719    ,2729    ,2731    ,2741
,2749    ,2753    ,2767    ,2777    ,2789    ,2791    ,2797    ,2801    ,2803    ,2819
,2833    ,2837    ,2843    ,2851    ,2857    ,2861    ,2879    ,2887    ,2897    ,2903
,2909    ,2917    ,2927    ,2939    ,2953    ,2957    ,2963    ,2969    ,2971    ,2999
,3001    ,3011    ,3019    ,3023    ,3037    ,3041    ,3049    ,3061    ,3067    ,3079
,3083    ,3089    ,3109    ,3119    ,3121    ,3137    ,3163    ,3167    ,3169    ,3181
,3187    ,3191    ,3203    ,3209    ,3217    ,3221    ,3229    ,3251    ,3253    ,3257
,3259    ,3271    ,3299    ,3301    ,3307    ,3313    ,3319    ,3323    ,3329    ,3331
,3343    ,3347    ,3359    ,3361    ,3371    ,3373    ,3389    ,3391    ,3407    ,3413
,3433    ,3449    ,3457    ,3461    ,3463    ,3467    ,3469    ,3491    ,3499    ,3511
,3517    ,3527    ,3529    ,3533    ,3539    ,3541    ,3547    ,3557    ,3559    ,3571
]

ferma_prime_values = [ 3, 5, 17, 257, 65537 ]

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

def ferma_prime_test(p,q=32):
    if q > len(first_500_prime_values)+1:
        raise ValueError(_there_is_no_more)
    for i in xrange(1,q):
        if modexp(first_500_prime_values[i],p-1,p) != 1:
            return False
    return True

def is_prime(p,q=32):
    if q > len(first_500_prime_values)+1:
        raise ValueError(_there_is_no_more)
    if not ferma_prime_test(p,q): return False
    return True

def gen_prime(bits,q=32):
    if q > len(first_500_prime_values)+1:
        raise ValueError(_there_is_no_more)
    while True:
        r = 2L
        for i in xrange(bits-3):
            r = (r << 1) + long(random() * 2)
        r = (r << 1) + 1
        for i in xrange(q):
            if not is_prime(r,q):
                r += 2
            else:
                return r

def first_prime_with(p,s=1):
    if s >= len(first_500_prime_values):
        raise ValueError(_there_is_no_more)
    for i in xrange(s,len(first_500_prime_values)):
        x = first_500_prime_values[i]
        if p%x != 0 : return x
    raise ValueError("nonprime")

def gen_key_pair_(xl,pl,ql,s,fp=50):
    n = 0
    xlL = (1L<<xl*8) - 1
    xlR = (1L<<(xl*8-1))
    while n > xlL or n < xlR:
        p = gen_prime(pl,s)
        q = gen_prime(ql,s)
        n = p * q
    phi = (p-1)*(q-1)
    if not fp:
        e = gen_prime(xl*8/3,s)
    else: 
        f=int(random()*(len(first_500_prime_values)-fp-1)+fp)
        e = first_prime_with(phi,f)
    d = invmod(e,phi)
    return e,d,n

def gen_key_pair_128():
    return gen_key_pair_(16,33,96,300)

def gen_key_pair_256():
    return gen_key_pair_(32,65,192,300)

def gen_key_pair_512():
    return gen_key_pair_(64,123,390,300)

def cipher_N(lx,k,key,n):
    ln =lx * 8;
    m = (1L << ln) -1;
    r = 0
    x = k & m
    r = modexp(x,key,n)
    return r

def cipher_S(lx,s,key,n):
    k = 0L
    if len(s)%lx != 0: s = s + '\0'*(lx-len(s)%lx)
    for i in s: k = (k << 8) + ord(i)
    r = cipher_N(lx,k,key,n)
    s = ''
    while lx: 
        s = chr(r&0xff) + s
        r = r >> 8
        lx = lx - 1
    return s

def cipher_128S(s,key,n): 
    return cipher_S(16,s,key,n)

def cipher_256S(s,key,n): 
    return cipher_S(32,s,key,n)

def cipher_512S(s,key,n): 
    return cipher_S(64,s,key,n)

def encrypt_L_encode(lx,s,Sx=False):
    bits = 0L
    bits_cnt = 0
    if Sx:
        s = struct.pack(">H",len(s)) + s
    else:
        s = struct.pack(">i",len(s)) + s
    r = ''
    while len(s):
        if len(s) > lx:
            ss = s[0:lx]
            s = s[lx:]
        else:
            ss = s
            s = ''
        hi = ord(ss[0])
        if bits_cnt % 8 == 7 : bits_cnt += 1
        if hi & 0x80:
            ss = chr(hi&0x7f) + ss[1:]
            bits |= (1L << bits_cnt)
        bits_cnt += 1
        r = r + ss
    r_bits = ''
    #print hex(bits),bits_cnt
    while bits_cnt > 0:
        r_bits = r_bits + chr(bits&0xff)
        bits_cnt -= 8
        bits >>= 8
    r = r + r_bits
    return r

def encrypt_L(lx,s,key,n,Sx=False):
    s = encrypt_L_encode(lx,s,Sx)
    r = ''
    while len(s):
        if len(s) > lx:
            ss = s[0:lx]
            s = s[lx:]
        else:
            ss = s
            s = ''
        r = r + cipher_S(lx,ss,key,n)
    return r

def encrypt_128L(s,key,n,Sx=False): 
    return encrypt_L(16,s,key,n,Sx)

def encrypt_256L(s,key,n,Sx=False): 
    return encrypt_L(32,s,key,n,Sx)

def encrypt_512L(s,key,n,Sx=False): 
    return encrypt_L(64,s,key,n,Sx)

def decrypt_L_decode(lx,s,Sx=False):
    bits = 0L
    bits_cnt = 0
    if Sx:
        sl = struct.unpack(">H",s[0:2])[0]
        sbits = s[2+sl:]
        s = s[0:sl+2]
    else:
        sl = struct.unpack(">i",s[0:4])[0]
        sbits = s[4+sl:]
        s = s[0:sl+4]
    
    bits = 0L
    bits_cnt = 0
    r = ''
    for i in sbits:
        bits |= long(ord(i)) << bits_cnt
        bits_cnt += 8
    #print hex(bits),bits_cnt
    bits_cnt = 0
    while len(s):
        if len(s) > lx:
            ss = s[0:lx]
            s = s[lx:]
        else:
            ss = s
            s = ''
        if bits_cnt % 8 == 7 : bits_cnt += 1
        if bits & (1L << bits_cnt): ss = chr(ord(ss[0])|0x80) + ss[1:]
        bits_cnt += 1
        r = r + ss
    if Sx:
        return r[2:]
    else:
        return r[4:]

def decrypt_L(lx,s,key,n,Sx=False):
    r = ''
    while len(s):
        if len(s) > lx:
            ss = s[0:lx]
            s = s[lx:]
        else:
            ss = s
            s = ''
        r = r + cipher_S(lx,ss,key,n)
    r = decrypt_L_decode(lx,r,Sx)
    return r

def decrypt_128L(s,key,n,Sx=False): 
    return decrypt_L(16,s,key,n,Sx)

def decrypt_256L(s,key,n,Sx=False): 
    return decrypt_L(32,s,key,n,Sx)

def decrypt_512L(s,key,n,Sx=False):
    return decrypt_L(64,s,key,n,Sx)


def miller_rabin_pass(a, s, d, n):
    a_to_power = pow(a, d, n)
    if a_to_power == 1:
        return True
    for i in xrange(s-1):
        if a_to_power == n - 1:
            return True
        a_to_power = (a_to_power * a_to_power) % n
    return a_to_power == n - 1


def miller_rabin(n):
    d = n - 1
    s = 0
    while d % 2 == 0:
        d >>= 1
        s += 1

    for repeat in xrange(20):
        a = 0
        while a == 0:
            a = randrange(n)
        if not miller_rabin_pass(a, s, d, n):
            return False
    return True


def gen_prime2(bits):
    while True:
        r = 2L
        for i in xrange(bits-3):
            r = (r << 1) + long(random() * 2)
        r = (r << 1) + 1
        if miller_rabin(r):
            return r

if __name__ == '__main__':

    t0 = time.time()
    Q = gen_prime(1024,150)
    print time.time() - t0
    print Q
    t0 = time.time()
    Q = gen_prime2(1024)
    print time.time() - t0
    print Q
    
    
    sys.exit(0)
    
    for i in range(1):
        pub,pri,n = gen_key_pair_128()
        for j in range(100):
            print '--- %d:%d -----' %(i,j)
            s = urandom(156)
            r = encrypt_128L(s,pub,n)
            v = decrypt_128L(r,pri,n)
            if v != s:
                print ''
                print 'test step %d:'%i
                print 'S:',repr(s)
                print 'R:',repr(r)    
                print 'V:',repr(v)
                print "test failed!"
                sys.exit(-1)
            else:
                print 'S:'+repr(s)
                print 'E:'+repr(r)
