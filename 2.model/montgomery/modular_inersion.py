import math

# def Dual_field_extended_Euclidean_modular_inversion_algorithm(x,y):
#     field = 0 #prime field or binary field？
#     if x&1==0 & y&1==0 :
#         return 0
#     u = x
#     v = y
#     A = 1
#     B = 0
#     C = 0
#     D = 1
#     while u != 0 :
#         label.forkA
#         if u&1 == 0 :
#             u = u >> 1
#             if A&1==0 & B&1==0 :
#                 A = A >> 1
#                 B = B >> 1
#             else :
#                 A = binary_plus(A,y)>>1
#                 B = binary_minor(B,x)>>1
#         # if field==0 & forkA(u,v,A,B,C,D,x,y,field)&1==0 :
#         #     goto .forkA
#         # else :
#         #     goto .forkB
#         # label .forkB
#         if v&1 == 0 :
#             v = v >> 1
#             if C&1==0 & D&1==0 :
#                 C = C >> 1
#                 D = D >> 1
#             else :
#                 C = binary_plus(C,y)>>1
#                 D = binary_minor(D,x)>>1
#         # if field==0 & v&1==0 :
#         #     goto .forkB
#         # else :
#         #     goto .forkC
#         # label .forkC
#         if u >= v :
#             u = binary_minor(u,v)
#             A = binary_minor(A,C)
#             B = binary_minor(B,D)
#             if field == 1 :
#                 A = A % x
#                 B = B % x
#         else :
#             v = binary_minor(v,u)
#             C = binary_minor(C,A)
#             D = binary_minor(D,B)
#             if field == 1 :
#                 C = C % x
#                 D = D % x
#     if v!=1 :
#         return 0
#     elif D<=0 & field==1 :
#         z = x + D
#     else :
#         z = D
#     return z


#using Extend - Eculid to get modular inversion
def mod_inv(a,m):
    if math.gcd(a,m)!=1:
        return None
    u1,u2,u3 = 1,0,a
    v1,v2,v3 = 0,1,m
    while v3!=0:
        q = u3//v3
        v1,v2,v3,u1,u2,u3 = (u1-q*v1),(u2-q*v2),(u3-q*v3),v1,v2,v3
    return u1%m

def binary_plus(x,y):
    return x ^ y
    # return x + y

def binary_minor(x,y):
    return x ^ y
    # return x - y

def forkC(u,v,A,B,C,D,x,y,field):
    if u[0] >= v[0] :
        u[0] = binary_minor(u[0],v[0])
        A[0] = binary_minor(A[0],C[0])
        B[0] = binary_minor(B[0],D[0])
        if field == 1 :
            A[0] = A[0] % x
            B[0] = B[0] % x
    else :
        v[0] = binary_minor(v[0],u[0])
        C[0] = binary_minor(C[0],A[0])
        D[0] = binary_minor(D[0],B[0])
        if field == 1 :
            C[0] = C[0] % x
            D[0] = D[0] % x
            
def forkB(u,v,A,B,C,D,x,y,field):
    if v[0]&1 == 0 :
        v[0] = v[0] >> 1
        if (C[0]&1==0) & (D[0]&1==0) :
            C[0] = C[0] >> 1
            D[0] = D[0] >> 1
        else :
            C[0] = binary_plus(C[0],y)>>1
            D[0] = binary_minor(D[0],x)>>1  
    if (field==0) & (v[0]&1==0) :
        forkB(u,v,A,B,C,D,x,y,field)
    else :
        forkC(u,v,A,B,C,D,x,y,field)  

def forkA(u,v,A,B,C,D,x,y,field):
    if u[0]&1 == 0 :
        u[0] = u[0] >> 1
        if (A[0]&1==0) & (B[0]&1==0) :
            A[0] = A[0] >> 1
            B[0] = B[0] >> 1
        else :
            A[0] = binary_plus(A[0],y)>>1
            B[0] = binary_minor(B[0],x)>>1
    if (field==0) & (u[0]&1==0) :
        forkA(u,v,A,B,C,D,x,y,field)
    else :
        forkB(u,v,A,B,C,D,x,y,field)

#[1] Bie M , Wei L I , Chen T ,et al.An energy-efficient reconfigurable asymmetric modular cryptographic operation unit for RSA and ECC[J].信息与电子工程前沿:英文版, 2022, 23(1):11.
#Any problems with the code below?
def Dual_field_extended_Euclidean_modular_inversion_algorithm(x,y):
    field = 0 #prime field or binary field？
    if (x&1==0) & (y&1==0) :
        return 0
    u = [0]
    v = [0]
    A = [0]
    B = [0]
    C = [0]
    D = [0]
    u[0] = x
    v[0] = y
    A[0] = 1
    B[0] = 0
    C[0] = 0
    D[0] = 1
    while u[0] != 0 :
        forkA(u,v,A,B,C,D,x,y,field)
    if v[0] != 1 :
        return 0
    elif (D[0]<=0) & (field==1) :
        z = x[0] + D[0]
    else :
        z = D[0]
    return z

#[1]胡锦,李勇彬.一种改进的模逆算法与硬件实现[J].湖南大学学报:自然科学版, 2022, 49(2):5.
def stein_improve(a,p):
    x = a
    y = p
    # g = 1
    while (x&1==0) and (y&1==0) : 
        x = x>>1
        y = y>>1
        # g = g<<1
    if x&1==0 :
        u = y
        v = x
        A = 0
        C = 1
        B = 1
        D = 0
    else :
        u = x
        v = y
        A = 1
        C = 0
        B = 0
        D = 1
    while u!=0 :
        if v&1==0 :
            v = v>>1
            if C&1==0 and D&1==0 :
                C = C>>1
                D = D>>1
            else :
                C = (C+y)>>1
                D = (D-x)>>1
        if u>=v :
            u = v
            v = u-v
            A = C
            C = A-C
            B = D
            D = B-D
        else :
            v = v-u
            C = C-A
            D = D-B
    #gcd(a,p) = u * g
    return A % y



if __name__=='__main__':
    # a = 0x12345623
    # p = 0xefee431213
    a=0x39979947f84591c7011dc06e677dc75ce460fd29a14d022555732743a714c8cf18ff8ebe1a8b01aabd6d421cf63ee8f0870f09badc9224f9fed2af198c5da91847bb617d0e28a369453604f44580667d19c6cbf1365dc89c74126ac7c4ff6f974fdb853bf92e50975dd7c5e6e3bed5c2c20b11011a8f308c56d193bf1461326716180d26596840499b727663b9271e7ad17020b0202ffeb0f83d610245b396e63ea93b568be6ad20dcf85bd66411987b9c99a9756a6b21c03e7d16d9807cf9b1f63208f216144c08c5c571343d1d05032239a444b890d96abed9f0cbacfbbfab6f2f28f1460f6ed4e906b303d12bf4f1ec40d1a7d4a572dfa8b09a0fa5730ff88981780bb3f309afc99fab51bba5b1e5c768809c880bda44efa7cfbb03ac9d317cd6211d142fd3eb964d872d3a8f833a19a0c0b825bdf7972a22e3133a538a063430cfef88eb7aa8f028d88a7272678ccb0deff5bd7ae373a62ffa5789c874dac229ecda874772927346cf18c197bae55c93c16eeacbea4acc52a6abd20e95f0aa41adb389c6468400741f2a27fbee12e8de39d80f67fa81e252caa8d46903016e3202345b9abeab552d7f912d346ce1603e209010af32ef06b3286e86daeb8ced3dfc0a45097f952aade6a537c61f26a2e1c47658ce092e9b6c29a02604523b931dd247099e3123c04a84ebad9f2f569be1df94c3fe93f1c92358cd60233349
    p=0x92d20837163355491353a40bfbed6afffb000939ca99e2dcb7e96c94d9e6ff1b54db47d62fa87283db4ef47e8119e2cb0d126f44ef110cd64d6493014fbee11fce25ad01515ed88bef11f595cc5b107aed44c3aecf42318a0e9dc2431934703c219abc2ee926037fbd46e2b2465b19b3110e3ccdbdfbe0daadefe22a725ef38bc2371fdc5e9cfb439ea6ac84b3e424e71cc3a263dc8cb4642042d01abe4e54416d821fae3e588950e16d5bdc76fc0629b4829eabad9ad1535fc322dc0ad791ca8a353157ab771cc0eafb621a07b0ce0998a65541754ffeedb756ff3ca3b606dea2b63fa2483a5dda07c17496f556f441e4c09fbb079cbbb8279c01fca24b56bf32e9902603d670439cee8a4f9730281ca7e736783300f69b64cce28fb565b99599758f8c8e5d58ce03af202cfe8d88092884f15b5a76578db8bf6a32cf7e2d78a758c60de9e6cf037bd2a6c7d22c670b8b384722fef18a9870588c1368f3c1f82caa709eff78cfdb2a3594bce3977875c0c30e464a5fc136225c7e206ba599b14ec856a9a230bca081331c969774eb112295c0670d4cb20723ceaa02e0ff4879a508052dad14c59f1787572686d68c51eb3ce8f505e141803ec18bc77c4986a7ea1dd24c13c7bb976496361ad38078e2daaf39f049a489793e2b46643b3eb3f168a3ad29eb4accb4ca422e7dd70e809f4ad5ed15d295f6765773bb5d851b3e81

    result_inverse=mod_inv(a,p)
    print('result_inverse:\n0x{:x}\n'.format(result_inverse))
    # result_inverse=Dual_field_extended_Euclidean_modular_inversion_algorithm(a,p)
    # print('result_inverse:\n0x{:x}\n'.format(result_inverse))
    stein_improve(a,p)
    print('result_inverse:\n0x{:x}\n'.format(result_inverse))
 