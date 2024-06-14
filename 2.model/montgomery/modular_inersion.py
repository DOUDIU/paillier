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




if __name__=='__main__':
    
    a = 0x123456
    p = 0xefee431
    result_inverse=mod_inv(a,p)
    print('result_inverse:\n0x{:x}\n'.format(result_inverse))
    result_inverse=Dual_field_extended_Euclidean_modular_inversion_algorithm(a,p)
    print('result_inverse:\n0x{:x}\n'.format(result_inverse))
