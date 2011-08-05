import sys, os, os.path
os.chdir(os.path.abspath(os.path.dirname(__file__)))
import simplersa

N = 1
QL = 4096
Q = [ simplersa.gen_key_pair_(512,1097,2000,300,0) for i in range(N) ]

NN = 1
for q in (Q):
    NN = NN + 1
    print " public = "+str(q[0])    
    print " private = "+str(q[1])    
    print " module = "+str(q[2])    

#print "\n*/"
#print "RSA_VALUE_TYPE partner_keys_E[] = {"
#for q in (Q):
#    S = ""
#    k = q[1] # priv
#    for i in range(512/(4*8)):
#        S += "0x%08x," % (k&0x0ffffffffL)
#        k >>= 32
#    print "  {"+S+"},"    
#print "  };"
#print "RSA_VALUE_TYPE partner_keys_N[] = {"
#for q in (Q):
#    S = ""
#    k = q[2] # mod
#    for i in range(512/(4*8)):
#        S += "0x%08x," % (k&0x0ffffffffL)
#        k >>= 32
#    print "  {"+S+"},"    
#print "  };"
