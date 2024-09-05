import math
def print_list(l2d):
    for l in l2d:
        for units in l:
            print('0x{:x} '.format(units),end='')
        print('')
    print('')

def mm(x,k):
    '''
    对x取低k位
    '''
    return x&(2**k-1)

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

def mont_2mont(x,r,m):
    return x*r%m

def mont_check(xx,yy,r,m,k):
    if xx<m and yy<m and math.gcd(r,m)==1 and m>=2**(k-1) and m<2**k and r==2**k:
        return True
    else:
        print('x<m y<m gcd(r,m) m>=2^(k-1) m<2^k r==2^k')
        print(xx<m,yy<m,math.gcd(r,m)==1, m>=2**(k-1), m<2**k,r==2**k)
        return False

def MP(x,y,r,m):
    return x*y*mod_inv(r,m)%m

def REDUCE(t,r,m):
    return t*mod_inv(r,m)%m

def mont_origin(xx,yy,r,m,m1):
    '''
    Montgomery multiplication:
    z=xx*yy*r^(-1) mod m
    m1  = -m^(-1) mod r
    r   = 2**k
    m   :mod值
    k   :总位宽
    '''
    s=xx*yy
    # lamb=((s%r)*m1)%r
    lamb=(s*m1)%r
    t=(s+lamb*m)//r
    if t>=m:
        return t-m
    else:
        return t

def mont_r2mm(xx,yy,m,k):
    '''
    Radix-2 Montgomery multiplication algorithm:
    z=xx*yy*2^(-k) mod m
    or:
    z=xx*yy*r^(-1) mod m
    m   :mod值
    k   :总位宽
    '''
    me_input_log = open("me_input_log.txt",'a',encoding="utf-8")
    print('me_xx={:x}'.format(xx),file=me_input_log)
    print('me_xx={:x}'.format(yy),file=me_input_log)
    print('\n',file=me_input_log)
    s=0
    for i in range(0,k):
        a=s+( (xx>>i)&1==1 )*yy
        if a%2==0:
            s=a//2
        else:
            s=(a+m)//2
    if(s>=m):
        return s-m
    else:
        return s

def mont_r2mm_hd(xx,yy,m,k):
    '''
    Radix-2 Montgomery multiplication algorithm:
    z=xx*yy*2^(-k) mod m
    or:
    z=xx*yy*r^(-1) mod m
    m   :mod值
    k   :总位宽
    这是mont_r2mm硬件实现方法，位宽固定
    '''
    s=0
    for i in range(0,k):
        a=mm(s,k+1)   +   ( (xx>>i)&1==1 )  *   mm(yy,k)
        if a&1==0:
            s=a>>1
        else:
            s=(  mm(a,k+2) + mm(m,k)  )>>1
            s=mm(s,k+2)
    if(s>=m):
        return s-m
    else:
        return s

def mont_imm(x,y,p,nbit,n):
    '''
    1999 C.D. Walter Montgomery exponentiation needs no final subtractions
    return x*y*2^(-nbit) mod p
    n      是组数，n*k=nbit
    '''
    k=nbit//n
    beta=2**k
    if math.gcd(beta,p)!=1:
        return False
    buf=(-1*(mod_inv(mm(p,k),beta)))
    x0=mm(x,k)
    y_=[0 for i in range(n)]
    s =0
    for i in range(n):
        y_[i]=mm(y>>(i*k),k)
    for i in range(n):
        q      = (   mm(s,k)         +x0*y_[i]  )*buf%beta
        s      = (  (s  +   x*y_[i]) +q*p       )//beta
    return s

def mont_imm2(x,y,p,nbit,n):
    '''
    M Morales-Sandoval在文章Novel algorithms and hardware architectures for Montgomery Multiplication over GF (p).
    内引用的MM算法iterative Montgomery multiplication algorithm的原出处算法
    z=x*y*2^(-nbit) mod p
    or:
    z=x*y*r^(-1) mod p
    nbit :总位宽
    p    :即mod值
    n    :是组数，n*k=nbit
    '''
    # k=nbit//n
    # beta=2**k

    # buf=(-1*(mod_inv(p,beta)))%beta
    
    # y0=mm(y,k)
    # A = 0
    # A_=[0 for i in range(n)]
    # x_=[0 for i in range(n)]
    # y_=[0 for i in range(n)]
    # p_=[0 for i in range(n)]
    # bf_=[0 for i in range(n)]
    # bf2_=[0 for i in range(n)]
    # h0=0
    # h1=0
    # aa=0
    # for i in range(n):
    #     x_[i]=mm(  x>>(i*k) ,  k)
    # for i in range(n):
    #     y_[i]=mm(  y>>(i*k) ,  k)
    # for i in range(n):
    #     p_[i]=mm(  p>>(i*k) ,  k)

    # for i in range(n):
    #     ui     = (   mm(A,k)  + x_[i]*y0    )*buf%beta
    #     for j in range(n):
    #         hl0   =x_[i]*y_[j]+h0
    #         h0    =mm(hl0>>k,k)
    #         bf_[j]=mm(hl0,k)
    #     for i in range(n):
    #         aa=aa+bf_[i]*(beta**i)
    #     print('->0x{:x}'.format(aa))
    #     print('-->0x{:x}'.format(x_[i]*y))
    #     A      = (   A+x_[i]*y   + ui*p        )//beta

    # if A>=p:
    #     return A-p
    # else:
    #     return A
    k=nbit//n
    beta=2**k
    buf=(-1*(mod_inv(p,beta)))
    x0=mm(x,k)
    y_=[0 for i in range(n)]
    s =0
    for i in range(n):
        y_[i]=mm(  y>>(i*k) ,  k)
    for i in range(n):
        q      = (   mm(s,k)      + y_[i]*x0      )*buf%beta
        s      = (    s+y_[i]*x   + q*p           )//beta
    if s>=p:
        return s-p
    else:
        return s

def mont_iddmm(xx,yy,p,nbit,n):
    '''
    这是Dorian Amiet根据M Morales-Sandoval的iddmm算法改写的版本,修正了carry bit的问题
    文章：Flexible FPGA-Based Architectures for Curve Point Multiplication over GF(p)
    return xx*yy*2^(-nbit) mod p
    n      是分组数
    '''
    # print('\nmont_iddmm-----------------------------------------------------------------')
    # RESULT_LOG = open("iddmm_log.txt",'w').close()
    k=nbit//n
    beta=2**k
    # print('gcd(p,beta):{}'.format(math.gcd(p,beta)))
    if math.gcd(p,beta)!=1:
        return 0
    p1=(-1*(mod_inv(p,beta)))%beta    
    # print('p1:0x{:x}'.format(p1))
    carry=0
    a  = [0 for i in range(n+1)]
    x_ = [0 for i in range(n+1)]
    y_ = [0 for i in range(n  )]
    p_ = [0 for i in range(n+1)]
    for i in range(n):
        x_[i] = mm(xx>>(i*k),k)
        y_[i] = mm(yy>>(i*k),k)
        p_[i] = mm(p >>(i*k),k)
        
    X_MUL_Y = open("X_MUL_Y.txt",'w').close()
    X_MUL_Y = open("X_MUL_Y.txt",'a',encoding="utf-8")
    X_MUL_Y_ADV = open("X_MUL_Y_ADV.txt",'w').close()
    X_MUL_Y_ADV = open("X_MUL_Y_ADV.txt",'a',encoding="utf-8")
    F_S = open("s.txt",'w').close()
    F_S = open("s.txt",'a',encoding="utf-8")
    F_Q = open("q.txt",'w').close()
    F_Q = open("q.txt",'a',encoding="utf-8")
    F_Q_MUL_P = open("Q_MUL_P.txt",'w').close()
    F_Q_MUL_P = open("Q_MUL_P.txt",'a',encoding="utf-8")
    F_u = open("u.txt",'w').close()
    F_u = open("u.txt",'a',encoding="utf-8")
    F_c = open("c.txt",'w').close()
    F_c = open("c.txt",'a',encoding="utf-8")
    F_carry = open("carry.txt",'w').close()
    F_carry = open("carry.txt",'a',encoding="utf-8")
    F_a = open("a.txt",'w').close()
    F_a = open("a.txt",'a',encoding="utf-8")
    for i in range(n):
        c = 0
        print('Record X_MUL_Y, i ={:x}'.format(i),end='\n',file=X_MUL_Y)
        print('Record X_MUL_Y_ADV, i ={:x}'.format(i),end='\n',file=X_MUL_Y_ADV)
        print('Record S, i ={:x}'.format(i),end='\n',file=F_S)
        print('Record q, i ={:x}'.format(i),end='\n',file=F_Q)
        print('Record Q_MUL_P, i ={:x}'.format(i),end='\n',file=F_Q_MUL_P)
        print('Record u, i ={:x}'.format(i),end='\n',file=F_u)
        print('Record c, i ={:x}'.format(i),end='\n',file=F_c)
        print('Record carry, i ={:x}'.format(i),end='\n',file=F_carry)
        print('Record a, i ={:x}'.format(i),end='\n',file=F_a)
        for j in range(n+1):
            print('{:x}'.format(carry),end='\n',file=F_carry)

            s = x_[j]*y_[i]
            print('{:x}'.format(s),end='\n',file=X_MUL_Y)

            s = a[j]+s
            print('{:x}'.format(a[j]),end='\n',file=F_a)
            s = mm(s,2*k)
            if j==n:
                s = s+carry
            print('{:x}'.format(s),end='\n',file=F_S)

            if j==0:#the number of DSPs could be optimized.
                q=(mm(x_[j]*y_[i],k)+a[j])*mm(p1,k)
                q = mm(q,k)
                # q = mm(s,k)*mm(p1,k)%beta
            print('{:x}'.format(q),end='\n',file=F_Q)

            r   = q*p_[j]
            print('{:x}'.format(r),end='\n',file=F_Q_MUL_P)

            buf0 = s + c + r
            u   =  mm(buf0,k)
            c   = (buf0>>k)
            print('{:x}'.format(u),end='\n',file=F_u)
            print('{:x}'.format(c),end='\n',file=F_c)
            if j>0:
                a[j-1] = u
        carry = c&1
    a[n] = carry
    res = a
    su  = 0
    for i in range(len(res)):
        su = su+res[i]*(beta**i)
    # print('su       ={:x}'.format(su),end='\n')
    # print(' p       ={:x}'.format(p),end='\n')
    if su >= p:
        su = su - p
    # print('result   ={:x}'.format(su),end='\n')
    #print('\n----------------------------------------------------------------------------')
    return su

def mont_iddmm1(xx,yy,p,nbit,n):
    '''
    M Morales-Sandoval在文章Novel algorithms and hardware architectures for Montgomery Multiplication over GF (p).
    内提出的MM算法1(iddmm1):Novel iterative digit-digit Montgomery multiplication algorithm
    该算法的carry bit存在缺陷，并不是每次都正确。
    return xx*yy*2^(-nbit) mod p
    n      是分组数
    '''
    print('\nmont_iddmm1-----------------------------------------------------------------')
    k=nbit//n
    beta=2**k
    # print('gcd(p,beta):{}'.format(math.gcd(p,beta)))
    if math.gcd(p,beta)!=1:
        return 0
    p1=(-1*(mod_inv(p,beta)))%beta    
    cs=0
    cr=0
    cu=0
    a=[[0 for i in range(n+1)]for i in range(n+1)]
    print_list(a)
    x_=[0 for i in range(n+1)]
    y_=[0 for i in range(n  )]
    p_=[0 for i in range(n+1)]
    for i in range(n):
        x_[i]=(xx>>(i*k))&((2**k)-1)
        y_[i]=(yy>>(i*k))&((2**k)-1)
        p_[i]=(p >>(i*k))&((2**k)-1)
    
    for i in range(n):
        cs=0
        cr=0
        cu=0
        for j in range(n+1):
            buf=a[i][j]+x_[j]*y_[i]+cs
            cs =(buf>>k)&(2**k-1)
            s  = buf    &(2**k-1)
            if j==0:
                q=s*p1%beta
                # q=s*p1&(2**k-1)
            buf1= q*p_[j]+cr
            cr  = (buf1>>k)&(2**k-1)
            r   =  buf1    &(2**k-1)

            buf2= s+r    +cu
            cu  = (buf2>>k)&1
            u   =  buf2    &(2**k-1)
            if j>0:
                a[i+1][j-1]=u
            
            print(i,j,'------------------------------------------')
            print('{:x} {:x} {:x}'.format(buf,buf1,buf2))
            print('{:x} {:x} {:x} {:x}'.format(q,s,r,cu))
    print_list(a)
    res=a[n][:]
    print('a[n][:]:')
    for ii in range(len(res)):
        print('0x{:x}'.format(res[ii]),end=' ')
    su=0
    print('')
    for i in range(len(res)-1):
        su=su+res[i]*(beta**i)
    print('return:\n{:x}'.format(su))
    print('\n----------------------------------------------------------------------------')
    return su

def mont_iddmm2(xx,yy,p,nbit,n):
    '''
    M Morales-Sandoval在文章Novel algorithms and hardware architectures for Montgomery Multiplication over GF (p).
    内提出的MM算法2(iddmm2):Novel iterative digit-digit Montgomery multiplication algorithm
    该算法同样存在缺陷
    return xx*yy*2^(-nbit) mod p
    n      是分组数
    '''
    print('\nmont_iddmm2-----------------------------------------------------------------')
    k=nbit//n
    beta=2**k
    a=[[0 for i in range(n+1)]for i in range(n+2)]
    p1=(-1*(mod_inv(p,beta)))%beta
    x_=[0 for i in range(n+1)]
    y_=[0 for i in range(n+1)]
    p_=[0 for i in range(n+1)]
    for i in range(n):
        x_[i]=(xx>>(i*k))&((2**k)-1)
        y_[i]=(yy>>(i*k))&((2**k)-1)
        p_[i]=(p >>(i*k))&((2**k)-1)
    c=0
    s=0
    q=0
    u=0
    print('\np1=0x{:x}  k*n=nbit {}*{}={}'.format(p1,k,n,nbit))
    print('\n{:x}'.format(((2**(2*k))-1)))
    print_list(a)
    print('x_ ',end='')
    for i in range(len(x_)):
        print('{:4x}'.format(x_[i]),end=' ')
    print('\ny_ ',end='')
    for i in range(len(y_)):
        print('{:4x}'.format(y_[i]),end=' ')
    print('\np_ ',end='')
    for i in range(len(p_)):
        print('{:4x}'.format(p_[i]),end=' ')
    print('')

    for i in range(n+1):
        c=0
        for j in range(n+1): 
            s=a[i][j]+x_[j]*y_[i]
            # print('\ns :{:x}'.format(s))
            if j==0:
                q=(  (s&(2**k-1))  *p1)%beta
                print('q {:x} s {:x} p1 {:x} beta {:x} slowk {:x}'.format(q,s,p1,beta,s&(2**k-1)))
            buf=s+(q*p_[j])+c
            c=(buf>>k)
            u=buf&((2**k)-1)
            print('buf {:x} c {:x} u {:x} s {:x} R {:x} '.format(buf,c,u,s,q*p_[j]))
            if j>0:
                a[i+1][j-1]=u
            # if i==n and j==n:
            #     print('u={:x}'.format(c))
    print_list(a)
    res=a[n+1][:]
    print('a[n+1][:]:')
    su=0
    for i in range(len(res)-1):
        su=su+res[i]*(beta**i)
        print('{:x} '.format(res[i]),end='')
    print('\n----------------------------------------------------------------------------')
    return su

def fastExpMod(b, e, m):
    result = 1
    while e != 0:
        if (e&1) == 1:
            # ei = 1, then mul
            result = (result * b) % m
        e >>= 1
        # b, b^2, b^4, b^8, ... , b^(2^n)
        b = (b*b) % m
    return result

def data_seperate_printf(data,nbit,n,order):#0 reverse,1 normal
    RESULT_LOG = open("result_log.txt",'a',encoding="utf-8")
    if order==0:
        print('--------------------------------------------------',end='\n',file=RESULT_LOG)
        for i in range(n):
            # print('128\'h{:x},'.format(data>>(i*nbit)&(2**nbit-1)),end='\n')
            print('{:x}'.format(data>>(i*nbit)&(2**nbit-1)),end='\n',file=RESULT_LOG)
        print('--------------------------------------------------',end='\n',file=RESULT_LOG)
    else:
        print('--------------------------------------------------',end='\n',file=RESULT_LOG)
        for i in range(n-1,-1,-1):
            # print('128\'h{:x},'.format(data>>(i*nbit)&(2**nbit-1)),end='\n')
            print('{:x}'.format(data>>(i*nbit)&(2**nbit-1)),end='\n',file=RESULT_LOG)
        print('--------------------------------------------------',end='\n',file=RESULT_LOG)
    print('\n')

def RSA2048_test(xx,yy,p,nbit):
    
    RESULT_LOG = open("result_log.txt",'w').close()
    RESULT_LOG = open("me_input_log.txt",'w').close()

    result0 = fastExpMod(xx,yy,p)   
    # print('mont_r2mm_hd():\n0x{:x}\n'.format(result0))

    rou = fastExpMod(2,2*nbit,p)
    # data_seperate_printf(rou,128,nbit//128,1)

    #two calculation methods are equivalent for result
    # result = mont_r2mm(rou,1,p,nbit)
    result = fastExpMod(2,nbit,p)
    # data_seperate_printf(result,128,nbit//128,1)

    result2 = mont_r2mm(xx,rou,p,nbit)
    # print('result2:\n0x{:x}\n'.format(result2))
    # data_seperate_printf(result2,128,nbit//128,1)

    for(i) in range(nbit-1,-1,-1):
        print('result={:x}'.format(result))
        result = mont_r2mm(result,result,p,nbit)
        print('result={:x}'.format(result))
        # data_seperate_printf(result,128,nbit//128,1)
        if((yy>>i)&1==1):
            result = mont_r2mm(result,result2,p,nbit)
            # data_seperate_printf(result,128,nbit//128,1)
        num = (yy>>i)&1
    result = mont_r2mm(result,1,p,nbit)
    # data_seperate_printf(result,128,nbit//128,1)
    
    if result0==result:
        print('mont_iddmm()==x*y*r^(-1)modm  match!')
    else:
        print('mont_iddmm()==x*y*r^(-1)modm  dont match!')

    # print('mont_r2mm_hd():\n0x{:x}\n'.format(result0))
    # print('mont_r2mm_hd():\n0x{:x}\n'.format(result))

    return 0

def montgomery_mul_test():
    #return x*y mod m
    # k = 2048
    # x = 0xABA5E025B607AA14F7F1B8CC88D6EC01C2D17C536508E7FA10114C9437D9616C9E1C689A4FC54744FA7DFE66D6C2FCF86E332BFD6195C13FE9E331148013987A947D9556A27A326A36C84FB38BFEFA0A0FFA2E121600A4B6AA4F9AD2F43FB1D5D3EB5EABA13D3B382FED0677DF30A089869E4E93943E913D0DC099AA320B8D8325B2FC5A5718B19254775917ED48A34E86324ADBC8549228B5C7BEEEFA86D27A44CEB204BE6F315B138A52EC714888C8A699F6000D1CD5AB9BF261373A5F14DA1F568BE70A0C97C2C3EFF0F73F7EBD47B521184DC3CA932C91022BF86DD029D21C660C7C6440D3A3AE799097642F0507DFAECAC11C2BD6941CBC66CEDEEAB744
    # y = 0xD091BE9D9A4E98A172BD721C4BC50AC3F47DAA31522DB869EB6F98197E63535636C8A6F0BA2FD4C154C762738FBC7B38BDD441C5B9A43B347C5B65CFDEF4DCD355E5E6F538EFBB1CC161693FA2171B639A2967BEA0E3F5E429D991FE1F4DE802D2A1D600702E7D517B82BFFE393E090A41F57E966A394D34297842552E15550B387E0E485D81C8CCCAAD488B2C07A1E83193CE757FE00F3252E4BD670668B1728D73830F7AE7D1A4C02E7AFD913B3F011782422F6DE4ED0EF913A3A261176A7D922E65428AE7AAA2497BB75BFC52084EF9F74190D0D24D581EB0B3DAC6B5E44596881200B2CE5D0FB2831D65F036D8E30D5F42BECAB3A956D277E3510DF8CBA9
    # m = 0xD27BF9F01E2A901DB957879F45F697330D21A21095DA4FA7D3AAB75454A8E9F0F4EA531ECE34F0C3BA9E02EB27D8F0DBE78EEDE4AC84061BEEF162D00B55C0DD772D28F23E994899AA19B9BEA7B12A8027A32A92190A3630E249544675488121565A23548FCD36F5382EEB993DB9CE3F526F20AB355E82D963D59541BC1161E211A03E3B372560840C57E12BD2F40EAC5FFCEC01B3F07C378C0A60B74BEF7B572764C88A4F98B61FA8CCD905AFAE779E6193378304D8EB17695CE71A173AC3DE11271753C48DB58546E5AF9917C1CEBBA5BB1AF3FCE3DF9516C0C95C9BC14BB65D1C53078C06C81AC0F3ED0D8634260E47BF780CF4F4996084DF732935194417
    k = 4096
    x = 0xc1df0542cbba9f6aed3aeeb7401bb37903c58d9d5f21d65ad1b98dcdea604d1c93002beae5e3ba36e68c53947334535de07fa62dae8dab29a705764d6361d337bb8f8b2eb7544d4d712448daab680c1a23e1a1ba6f85f82c796d8ac217525ec6351e343ccab4d1081fa4b3cd63a8ad43d70848b8fc6c47672bc104c8e0c70a7ed425406b85000155592afd87614ce8fb8b69e1a113a78b1d62fc60d72fbb16b0577f67c5068d4d3a149920a9574965fecb6c2cc3243acc4673fc5610f2fcb59ffe99b9a19e5cbe58c395a594a0c0b53320271837ed95054f858a97e561b3145391ab16dcbbe5e58da8e7dec86babca61e844a72f26bf3f52d87bd7a4f58113f32a6b621a0430
    y =  0x6ba000aae20213f722fc5470729ad8c24582b0a2770f4d03cacace6d643e651b3693808cdb14d627e66041a01d0b880b6ef860f128dc00763a17e8ba2ab82d8ab74abf1f8fefb8084c79fea078d240f9494e015693644635d3666a738e44cd1fb2d2bba34fa9229c630c1214fd0da66429175f7c0b25e19ff5d8c30a95c3ff70bffcbbffe9f71a5184eb10d8db7ea06a0b7a3bed231377d8e2635da172fe2f9ee2976a8661384cd36092502be1117958dd2252d84ecb53d63ab1d04be31f760212af374c8ca98d1a7e7ff29c24b7a9c25b3ed35c3c2be6e625033ae984a61426af0239b50b0ae849384e14120366b6e6233bc679d74362ca5c0ac2278762821bf4e67587acfb1f5386615fa7c2670cc010f322cf6731fd4120f7bf5c1fa33186c9e14c325bd9ef9439c15aa06101167d29fd728f42a66b04eea3db148ada8b23e680706b56d39c1724af0bf491075de4f6c18592054345a7ffe93b14d10e6532512dc88a4b43c51b8dd43dd80a31232e33882a7f3c0ae1364e2cd2bbe99113be5a98ca21cc10e3aaff2f53ff8f1e7125df9f31683fca3fd08474702171f46f7278edc0cc248a2d3d5d3a82515bb2c5d6b16880499bf455a41291e1a88e373fb6bcde50818f640570928e34371de7aa86df6e792c98fe8002807e016f6e27b47e127a6877402aaf23dde9b00b1520551678990e9d17cae6f8b0a8208391db5780
    m = 0x92d20837163355491353a40bfbed6afffb000939ca99e2dcb7e96c94d9e6ff1b54db47d62fa87283db4ef47e8119e2cb0d126f44ef110cd64d6493014fbee11fce25ad01515ed88bef11f595cc5b107aed44c3aecf42318a0e9dc2431934703c219abc2ee926037fbd46e2b2465b19b3110e3ccdbdfbe0daadefe22a725ef38bc2371fdc5e9cfb439ea6ac84b3e424e71cc3a263dc8cb4642042d01abe4e54416d821fae3e588950e16d5bdc76fc0629b4829eabad9ad1535fc322dc0ad791ca8a353157ab771cc0eafb621a07b0ce0998a65541754ffeedb756ff3ca3b606dea2b63fa2483a5dda07c17496f556f441e4c09fbb079cbbb8279c01fca24b56bf32e9902603d670439cee8a4f9730281ca7e736783300f69b64cce28fb565b99599758f8c8e5d58ce03af202cfe8d88092884f15b5a76578db8bf6a32cf7e2d78a758c60de9e6cf037bd2a6c7d22c670b8b384722fef18a9870588c1368f3c1f82caa709eff78cfdb2a3594bce3977875c0c30e464a5fc136225c7e206ba599b14ec856a9a230bca081331c969774eb112295c0670d4cb20723ceaa02e0ff4879a508052dad14c59f1787572686d68c51eb3ce8f505e141803ec18bc77c4986a7ea1dd24c13c7bb976496361ad38078e2daaf39f049a489793e2b46643b3eb3f168a3ad29eb4accb4ca422e7dd70e809f4ad5ed15d295f6765773bb5d851b3e81


    # print('x*y*(2^2048)%m       :\n0x{:x}\n'.format(mont_r2mm(x,y,m,k)))

    rou = fastExpMod(2,2*k,m)
    result0 = mont_r2mm(x,rou,m,k)  
    print('result0              :\n0x{:x}\n'.format(result0))
    result1 = mont_r2mm(y,rou,m,k)  
    print('result1              :\n0x{:x}\n'.format(result1))
    result2 = mont_r2mm(result0,result1,m,k)  
    print('result2              :\n0x{:x}\n'.format(result2))
    result3 = mont_r2mm(result2,1,m,k)  
    print('montgomery_mul_test  :\n0x{:x}\n'.format(result3))
    print('confirm result()     :\n0x{:x}\n'.format(x*y%m))

def rsa_test():

    k = 4096
    m = 0X92d20837163355491353a40bfbed6afffb000939ca99e2dcb7e96c94d9e6ff1b54db47d62fa87283db4ef47e8119e2cb0d126f44ef110cd64d6493014fbee11fce25ad01515ed88bef11f595cc5b107aed44c3aecf42318a0e9dc2431934703c219abc2ee926037fbd46e2b2465b19b3110e3ccdbdfbe0daadefe22a725ef38bc2371fdc5e9cfb439ea6ac84b3e424e71cc3a263dc8cb4642042d01abe4e54416d821fae3e588950e16d5bdc76fc0629b4829eabad9ad1535fc322dc0ad791ca8a353157ab771cc0eafb621a07b0ce0998a65541754ffeedb756ff3ca3b606dea2b63fa2483a5dda07c17496f556f441e4c09fbb079cbbb8279c01fca24b56bf32e9902603d670439cee8a4f9730281ca7e736783300f69b64cce28fb565b99599758f8c8e5d58ce03af202cfe8d88092884f15b5a76578db8bf6a32cf7e2d78a758c60de9e6cf037bd2a6c7d22c670b8b384722fef18a9870588c1368f3c1f82caa709eff78cfdb2a3594bce3977875c0c30e464a5fc136225c7e206ba599b14ec856a9a230bca081331c969774eb112295c0670d4cb20723ceaa02e0ff4879a508052dad14c59f1787572686d68c51eb3ce8f505e141803ec18bc77c4986a7ea1dd24c13c7bb976496361ad38078e2daaf39f049a489793e2b46643b3eb3f168a3ad29eb4accb4ca422e7dd70e809f4ad5ed15d295f6765773bb5d851b3e81
    x = 0X7ffffffef380fcff68e38a9fcc30b4c64e94dbc4f2b03a88ae0650f51f46fe1f4f10ba102d77eb77c1547e0c40e6d7aeb05539c308ea01dafb6da33649210fab2cdd38a580091aaec64d74192431c00cce4f4c752498e88aaa5ccc010b2317db8e01cf660e1dc9ba01154024448965f8209721d391f8422ef2e1817ac4240be53bfc0f05b7336e172e271c9e9fcd38057746bbe8f5bb1907ab681ae012395e78e531f5291340108b4f8b182614a29fa0c7a44032229fe3fb3af01a5577cf335f318c1ecc70b613e7532ab85dc087c618020e949640cb14a3dbf634fa0b48f0098c9e9ee4861a5e6193f2a9241e28d1f4d3c9a8f11c460943dbd7b7b06f18fe75454e20593388dcaa8b98aabe293987d22e2725251d6ebf2729cde05db076ed775b7f369d1f9e1109812960b8b76e333bcca8aaa98931c2937cadb68a4ffc6c54eff9a6bcb77da76dc02fcb83167105319dd5a25f19d6ef0b214927120635e665afe46f681259247978d4a6853bb3cac03bc554d07003496f6b8b624bfec45f4cfb24acded0aeb074e8f70df1813ebb26bd5fe26be2a627684d793a8a052e3a9476a1d9697dd9e27beb4db7ad01eb8b0a3b5c7717d716ebd30727cc7786a17f09b04d6b94a56d9f70ac514e026f42834486e6a0852ce00808c7222cc02f90802ab22509fe316612d10d60359087ab7a23be6348b73f6704e6fde2ed070c500db0
    y = 0X9ffff4f73caff09ff67fc82fe8f5988fe76cff5b4241f1f3f3f4ccb35f29fff573f617bc077c80165ec5270c0b863fc231ae96dd5d933e9a98abdaf3d6e852e98149945ab1a9a90e38e07c3017c1273b18598d87b59a289de9d7c5bc5c6f64cccdbcbec42c289c8b1b799f8454cba6b89e5976a84c19217d64ddde5af42e37ab465928d068deaa3a0270b8d062dbe0b737667c3afd065871532081e72bc1f79e1d7ebd1fb933ec3555a8e986f949f72ca11bc2fbe4c704b20838c68b707d9f3db1d8ae45b44b6bd36a58bfbf7d565347a6c6e20130c84f1bad77f6251e81dfb6ffa9a508d64db7d2fe48b5e4ebe68e7c8d62cdf5ab1c2ca8c2d2e835a1423acbef65956c980dfb62b3a405b9efbc93283d5071c2129b831481c537cc5be8f1d2723f1168f797bde736c1f73054d7d0dc97538fba25bb3e38703934d8fc46ad22eb23ea409184c3dba8241efc92ce5a6728f4385da637bc23ef7acb506d0543804ae7d660926a82406f9d3206376d5454466ecde2246a125c99aebdf16743d55cfb1c4ab0fdb8387320d541a94e3c5aa6038466eaa18682a163d571db3214de448b3d4d7a632bc60f0a524a041cd6e72a75dbc9f6bb63743df3c3c0d4649a28bd0bbeee569182303a66b830a2273b8df05c712adadf2bcb75244a66826265da778e0c3b45a20d6c962fd203e708ff62dd29b9edd90f2afd2bfe92014968e4396a

    # data_seperate_printf(m,128,k//128,1)
    # beta=2**k
    # p1=((-1*(mod_inv(m,beta)))%beta)%(2**128)#The lower 128-bit data is reserved.
    # print('m1=(-1*(mod_inv(m,2**K)))%2**K:\n0x{:x}\n'.format(p1))


    # RESULT_LOG = open("result_log.txt",'w').close()
    # rou = fastExpMod(2,2*k,m)
    # print('rou=:\n0x{:x}\n'.format(rou))
    # data_seperate_printf(rou,128,k//128,1)
    # result = fastExpMod(2,k,m)
    # data_seperate_printf(result,128,k//128,1)


    RSA2048_test(x,y,m,k)

    return 0

def iddmm_test():
    
    # K   = 128   
    # N   = 16    
    # big_x = 0xABA5E025B607AA14F7F1B8CC88D6EC01C2D17C536508E7FA10114C9437D9616C9E1C689A4FC54744FA7DFE66D6C2FCF86E332BFD6195C13FE9E331148013987A947D9556A27A326A36C84FB38BFEFA0A0FFA2E121600A4B6AA4F9AD2F43FB1D5D3EB5EABA13D3B382FED0677DF30A089869E4E93943E913D0DC099AA320B8D8325B2FC5A5718B19254775917ED48A34E86324ADBC8549228B5C7BEEEFA86D27A44CEB204BE6F315B138A52EC714888C8A699F6000D1CD5AB9BF261373A5F14DA1F568BE70A0C97C2C3EFF0F73F7EBD47B521184DC3CA932C91022BF86DD029D21C660C7C6440D3A3AE799097642F0507DFAECAC11C2BD6941CBC66CEDEEAB744
    # big_y = 0xD091BE9D9A4E98A172BD721C4BC50AC3F47DAA31522DB869EB6F98197E63535636C8A6F0BA2FD4C154C762738FBC7B38BDD441C5B9A43B347C5B65CFDEF4DCD355E5E6F538EFBB1CC161693FA2171B639A2967BEA0E3F5E429D991FE1F4DE802D2A1D600702E7D517B82BFFE393E090A41F57E966A394D34297842552E15550B387E0E485D81C8CCCAAD488B2C07A1E83193CE757FE00F3252E4BD670668B1728D73830F7AE7D1A4C02E7AFD913B3F011782422F6DE4ED0EF913A3A261176A7D922E65428AE7AAA2497BB75BFC52084EF9F74190D0D24D581EB0B3DAC6B5E44596881200B2CE5D0FB2831D65F036D8E30D5F42BECAB3A956D277E3510DF8CBA9
    # big_m = 0xD27BF9F01E2A901DB957879F45F697330D21A21095DA4FA7D3AAB75454A8E9F0F4EA531ECE34F0C3BA9E02EB27D8F0DBE78EEDE4AC84061BEEF162D00B55C0DD772D28F23E994899AA19B9BEA7B12A8027A32A92190A3630E249544675488121565A23548FCD36F5382EEB993DB9CE3F526F20AB355E82D963D59541BC1161E211A03E3B372560840C57E12BD2F40EAC5FFCEC01B3F07C378C0A60B74BEF7B572764C88A4F98B61FA8CCD905AFAE779E6193378304D8EB17695CE71A173AC3DE11271753C48DB58546E5AF9917C1CEBBA5BB1AF3FCE3DF9516C0C95C9BC14BB65D1C53078C06C81AC0F3ED0D8634260E47BF780CF4F4996084DF732935194417

    # K       = 128
    # N       = 32 
    # big_m = 0x92d20837163355491353a40bfbed6afffb000939ca99e2dcb7e96c94d9e6ff1b54db47d62fa87283db4ef47e8119e2cb0d126f44ef110cd64d6493014fbee11fce25ad01515ed88bef11f595cc5b107aed44c3aecf42318a0e9dc2431934703c219abc2ee926037fbd46e2b2465b19b3110e3ccdbdfbe0daadefe22a725ef38bc2371fdc5e9cfb439ea6ac84b3e424e71cc3a263dc8cb4642042d01abe4e54416d821fae3e588950e16d5bdc76fc0629b4829eabad9ad1535fc322dc0ad791ca8a353157ab771cc0eafb621a07b0ce0998a65541754ffeedb756ff3ca3b606dea2b63fa2483a5dda07c17496f556f441e4c09fbb079cbbb8279c01fca24b56bf32e9902603d670439cee8a4f9730281ca7e736783300f69b64cce28fb565b99599758f8c8e5d58ce03af202cfe8d88092884f15b5a76578db8bf6a32cf7e2d78a758c60de9e6cf037bd2a6c7d22c670b8b384722fef18a9870588c1368f3c1f82caa709eff78cfdb2a3594bce3977875c0c30e464a5fc136225c7e206ba599b14ec856a9a230bca081331c969774eb112295c0670d4cb20723ceaa02e0ff4879a508052dad14c59f1787572686d68c51eb3ce8f505e141803ec18bc77c4986a7ea1dd24c13c7bb976496361ad38078e2daaf39f049a489793e2b46643b3eb3f168a3ad29eb4accb4ca422e7dd70e809f4ad5ed15d295f6765773bb5d851b3e81
    # big_x = 0x7ffffffef380fcff68e38a9fcc30b4c64e94dbc4f2b03a88ae0650f51f46fe1f4f10ba102d77eb77c1547e0c40e6d7aeb05539c308ea01dafb6da33649210fab2cdd38a580091aaec64d74192431c00cce4f4c752498e88aaa5ccc010b2317db8e01cf660e1dc9ba01154024448965f8209721d391f8422ef2e1817ac4240be53bfc0f05b7336e172e271c9e9fcd38057746bbe8f5bb1907ab681ae012395e78e531f5291340108b4f8b182614a29fa0c7a44032229fe3fb3af01a5577cf335f318c1ecc70b613e7532ab85dc087c618020e949640cb14a3dbf634fa0b48f0098c9e9ee4861a5e6193f2a9241e28d1f4d3c9a8f11c460943dbd7b7b06f18fe75454e20593388dcaa8b98aabe293987d22e2725251d6ebf2729cde05db076ed775b7f369d1f9e1109812960b8b76e333bcca8aaa98931c2937cadb68a4ffc6c54eff9a6bcb77da76dc02fcb83167105319dd5a25f19d6ef0b214927120635e665afe46f681259247978d4a6853bb3cac03bc554d07003496f6b8b624bfec45f4cfb24acded0aeb074e8f70df1813ebb26bd5fe26be2a627684d793a8a052e3a9476a1d9697dd9e27beb4db7ad01eb8b0a3b5c7717d716ebd30727cc7786a17f09b04d6b94a56d9f70ac514e026f42834486e6a0852ce00808c7222cc02f90802ab22509fe316612d10d60359087ab7a23be6348b73f6704e6fde2ed070c500db0
    # big_y = 0x915f94ab9c50ca4ab4eeed592a9beaa5ad6f3ab8cde33356263b7ca1cd6327f93abe0f5f621642eb55318e74137d0b258ebc8b10a00cab3ffe67b8e78a16a98e4ddb4c9ac0c0a08302a84f682ca131a477edce6c0888a7d3b0aa71c00185447b162a3b903f9853566121da8222821f4429e054b3919b6c6c038207f135accb78acd282aca5f291fca5ea2cc846ae54dffe7b604b0be2fe402bcb234c62e040177915fd96957f012fc6c3c43fa5b2e41107252f907ab98a98c4d0dd09e90ef2e0f4a75b8a7d8b166e180cb21a76528f23f9a7752b5ac26ac1e8c15c514343b84b3b1450e77af95bdf8148328d73d65a6cd4479f00aaf1fe6a7641a67c0515e8f6e169cc22bf64c781c30d0a498b07001a95d7776b9beb874091aeaabc1594693fd8ea828ac8251e7835669e4adb373a0f24428720ad662853fbb3f3f4d95cf52de704570cefbc67502abb2837ea155c3df5e87eb6400b55d7ec696534b23ed3774ed73d9fc2788919bf9d984c670019bd4d0a8c0ba1be9c46ce46811a7f8fbaea6e74eb0c8d4989c5f7f7ba424a380576979df18527249a66e10251090d2bad6a25fa45d9a2ce695e98e2ae4f3b06c5f3c72909e099111c79ca5511174ff3fb35f3e16d1d8e50675156b0f608a0c7d82b62d7b109a4be8fceb700f50b47c35664ce312818a6f6c0b2ff78a1ac2de5674a4fcaa08ceba5ea9d842695dd79db7aa0

    # K       = 128
    # N       = 32 
    # big_m = 0x92d20837163355491353a40bfbed6afffb000939ca99e2dcb7e96c94d9e6ff1b54db47d62fa87283db4ef47e8119e2cb0d126f44ef110cd64d6493014fbee11fce25ad01515ed88bef11f595cc5b107aed44c3aecf42318a0e9dc2431934703c219abc2ee926037fbd46e2b2465b19b3110e3ccdbdfbe0daadefe22a725ef38bc2371fdc5e9cfb439ea6ac84b3e424e71cc3a263dc8cb4642042d01abe4e54416d821fae3e588950e16d5bdc76fc0629b4829eabad9ad1535fc322dc0ad791ca8a353157ab771cc0eafb621a07b0ce0998a65541754ffeedb756ff3ca3b606dea2b63fa2483a5dda07c17496f556f441e4c09fbb079cbbb8279c01fca24b56bf32e9902603d670439cee8a4f9730281ca7e736783300f69b64cce28fb565b99599758f8c8e5d58ce03af202cfe8d88092884f15b5a76578db8bf6a32cf7e2d78a758c60de9e6cf037bd2a6c7d22c670b8b384722fef18a9870588c1368f3c1f82caa709eff78cfdb2a3594bce3977875c0c30e464a5fc136225c7e206ba599b14ec856a9a230bca081331c969774eb112295c0670d4cb20723ceaa02e0ff4879a508052dad14c59f1787572686d68c51eb3ce8f505e141803ec18bc77c4986a7ea1dd24c13c7bb976496361ad38078e2daaf39f049a489793e2b46643b3eb3f168a3ad29eb4accb4ca422e7dd70e809f4ad5ed15d295f6765773bb5d851b3e81
    # big_x = 0x6d2df7c8e9ccaab6ecac5bf40412950004fff6c635661d234816936b261900e4ab24b829d0578d7c24b10b817ee61d34f2ed90bb10eef329b29b6cfeb0411ee031da52feaea1277410ee0a6a33a4ef8512bb3c5130bdce75f1623dbce6cb8fc3de6543d116d9fc8042b91d4db9a4e64ceef1c33242041f2552101dd58da10c743dc8e023a16304bc6159537b4c1bdb18e33c5d9c23734b9bdfbd2fe541b1abbe927de051c1a776af1e92a4238903f9d64b7d615452652eaca03cdd23f5286e3575cacea85488e33f15049de5f84f31f66759aabe8ab0011248a900c35c49f9215d49c05db7c5a225f83e8b690aa90bbe1b3f6044f8634447d863fe035db4a940cd166fd9fc298fbc631175b068cfd7e35818c987ccff09649b331d704a9a466a668a707371a2a731fc50dfd3017277f6d77b0ea4a589a872474095cd3081d28758a739f2161930fc842d59382dd398f474c7b8dd010e75678fa773ec970c3e07d3558f6100873024d5ca6b431c68878a3f3cf1b9b5a03ec9dda381df945a664eb137a9565dcf435f7ecce369688b14eedd6a3f98f2b34df8dc3155fd1f00b7865af7fad252eb3a60e878a8d9792973ae14c3170afa1ebe7fc13e743883b6795815e22db3ec3844689b69c9e52c7f871d2550c60fb65b7686c1d4b99bc4c14c0e975c52d614b5334b35bdd18228f17f60b52a12ea2d6a0989a88c44a27ae4c17f
    # big_y = 0x6d2df7c8e9ccaab6ecac5bf40412950004fff6c635661d234816936b261900e4ab24b829d0578d7c24b10b817ee61d34f2ed90bb10eef329b29b6cfeb0411ee031da52feaea1277410ee0a6a33a4ef8512bb3c5130bdce75f1623dbce6cb8fc3de6543d116d9fc8042b91d4db9a4e64ceef1c33242041f2552101dd58da10c743dc8e023a16304bc6159537b4c1bdb18e33c5d9c23734b9bdfbd2fe541b1abbe927de051c1a776af1e92a4238903f9d64b7d615452652eaca03cdd23f5286e3575cacea85488e33f15049de5f84f31f66759aabe8ab0011248a900c35c49f9215d49c05db7c5a225f83e8b690aa90bbe1b3f6044f8634447d863fe035db4a940cd166fd9fc298fbc631175b068cfd7e35818c987ccff09649b331d704a9a466a668a707371a2a731fc50dfd3017277f6d77b0ea4a589a872474095cd3081d28758a739f2161930fc842d59382dd398f474c7b8dd010e75678fa773ec970c3e07d3558f6100873024d5ca6b431c68878a3f3cf1b9b5a03ec9dda381df945a664eb137a9565dcf435f7ecce369688b14eedd6a3f98f2b34df8dc3155fd1f00b7865af7fad252eb3a60e878a8d9792973ae14c3170afa1ebe7fc13e743883b6795815e22db3ec3844689b69c9e52c7f871d2550c60fb65b7686c1d4b99bc4c14c0e975c52d614b5334b35bdd18228f17f60b52a12ea2d6a0989a88c44a27ae4c17f

    # K       = 128
    # N       = 32 
    # big_m = 0x92d20837163355491353a40bfbed6afffb000939ca99e2dcb7e96c94d9e6ff1b54db47d62fa87283db4ef47e8119e2cb0d126f44ef110cd64d6493014fbee11fce25ad01515ed88bef11f595cc5b107aed44c3aecf42318a0e9dc2431934703c219abc2ee926037fbd46e2b2465b19b3110e3ccdbdfbe0daadefe22a725ef38bc2371fdc5e9cfb439ea6ac84b3e424e71cc3a263dc8cb4642042d01abe4e54416d821fae3e588950e16d5bdc76fc0629b4829eabad9ad1535fc322dc0ad791ca8a353157ab771cc0eafb621a07b0ce0998a65541754ffeedb756ff3ca3b606dea2b63fa2483a5dda07c17496f556f441e4c09fbb079cbbb8279c01fca24b56bf32e9902603d670439cee8a4f9730281ca7e736783300f69b64cce28fb565b99599758f8c8e5d58ce03af202cfe8d88092884f15b5a76578db8bf6a32cf7e2d78a758c60de9e6cf037bd2a6c7d22c670b8b384722fef18a9870588c1368f3c1f82caa709eff78cfdb2a3594bce3977875c0c30e464a5fc136225c7e206ba599b14ec856a9a230bca081331c969774eb112295c0670d4cb20723ceaa02e0ff4879a508052dad14c59f1787572686d68c51eb3ce8f505e141803ec18bc77c4986a7ea1dd24c13c7bb976496361ad38078e2daaf39f049a489793e2b46643b3eb3f168a3ad29eb4accb4ca422e7dd70e809f4ad5ed15d295f6765773bb5d851b3e81
    # big_x = 0x5b3c79741549edb3cfa435ec3658f9a1e3851eb89578184d3211d16d8301feac6e344ea52938af825d9c192e9cf7d8126f87a306462580c5f037719ee010123815dcbf70f2e7fd6c3ef5151072b1bdc841cf27ed8daed3f56798c4a3000e64ef02c6a96b4fe0ede0024b968f641550697364386ddb60e3d27074c78f32d3f50b7df51c860725c40420aed07295ccb45d5c2b508e6f5c56d0502b1cd8078342da541b93752507d20f04315e90d19875541808eb9dbc3278b8ed2d0d4c28891db296a74f3b76fd8b81a7cedc4f439efa159ed76724cc551be0d1f05d0f35739d5f23ba6b560ea8567457fb669ca9eef8550ebeaace53ce1c866ae4e6de6b6a4d617bb77ca72fda2cbe4bddae2a0983a133dd3af895b747de0d5efbadb2e97da51e8d4a1746321a4e7380551a8b40d0c80aa9b8e2aa281e2fae18b783b584fd2efd52d3a208a3bea1da7a0750317f3e12d67646849cb97ae5508cabe2bfacaaaba01372d38f22744b67055900556784824f329626655d0b7792d8ab80c08a0f0e33c7df6b52709117e4ffbcf65492de2691d1271c8c29e2d3d845f6a8c43cccca8ef05c2aff8ecc15e52e32151090d9d6b63b437a88e9ab12a1a42f5a0639d66552b80c89333a8c2ae1ad7bd9d40bcbbb7445954b4615d636e323e7c7d8d1b19d16320069e41ca37f938b1a4b17e837cd05e5c4cab9ed9db2e5649e0dddb42fdf91
    # big_y = 0x5b3c79741549edb3cfa435ec3658f9a1e3851eb89578184d3211d16d8301feac6e344ea52938af825d9c192e9cf7d8126f87a306462580c5f037719ee010123815dcbf70f2e7fd6c3ef5151072b1bdc841cf27ed8daed3f56798c4a3000e64ef02c6a96b4fe0ede0024b968f641550697364386ddb60e3d27074c78f32d3f50b7df51c860725c40420aed07295ccb45d5c2b508e6f5c56d0502b1cd8078342da541b93752507d20f04315e90d19875541808eb9dbc3278b8ed2d0d4c28891db296a74f3b76fd8b81a7cedc4f439efa159ed76724cc551be0d1f05d0f35739d5f23ba6b560ea8567457fb669ca9eef8550ebeaace53ce1c866ae4e6de6b6a4d617bb77ca72fda2cbe4bddae2a0983a133dd3af895b747de0d5efbadb2e97da51e8d4a1746321a4e7380551a8b40d0c80aa9b8e2aa281e2fae18b783b584fd2efd52d3a208a3bea1da7a0750317f3e12d67646849cb97ae5508cabe2bfacaaaba01372d38f22744b67055900556784824f329626655d0b7792d8ab80c08a0f0e33c7df6b52709117e4ffbcf65492de2691d1271c8c29e2d3d845f6a8c43cccca8ef05c2aff8ecc15e52e32151090d9d6b63b437a88e9ab12a1a42f5a0639d66552b80c89333a8c2ae1ad7bd9d40bcbbb7445954b4615d636e323e7c7d8d1b19d16320069e41ca37f938b1a4b17e837cd05e5c4cab9ed9db2e5649e0dddb42fdf91

    K       = 256
    N       = 16
    big_m = 0xff5f4906fd176bc241535c78955d02f4d0acf376d736ae280077887200c758b7781b4432fa8baca2a81ad6fb0817051a00fccf8e15c63048681bcf8342b56433abd550affa489b289cd4f0482adce321c8cf4374ce15267692dfc8b0da108f4bb0e922d4a28402ef785c2516f6296486f8505ac3df05c0f953acce65e2dc5f1e59965ded73fa18ffb482ad1a2e5433d4df8211de12a3e7a71a1a084fed671fb11eeaf76f640c4fd549ea307b6622f798f027786e79232206de1507281d84c719209d408bc85f9ed2e1b82ecf72ff805a45221dc712c45a8dbc375e9b64227ec6b659a75fc5b5e051e776bcd9f4f6d82ebaff89a48c8494d6ed072372b846156af229994baab390ec57c00130255acc2cdf975783df4678153f0ca51b854425b1568b5b8b53239f50dd39fc53c3d41827a0687c435f6de5e98843def3fb7b0f7e701cdfb51517d6628392bd9291c16282556f5581766dd6a0a426a35312237399f93ad69502592c0f6d1864ba0b75600ee04cb406bcb833bc98527a0ac1249c6a918456b06f24611770c1708426b4d9041f7fe83be68fbc7018e461951d234ebf00227b4301911e24055c745203c888276f4db0c05f66514ae4e6b4bf4c8914e36c4a94bf57bf807dd40c7572d1a99c27d9f58af0877bb217c081d750d5edbe3c45eafc3ea6786560fa819873452cc8bffc7ab998ab70496b77fdadffb7ef2621
    big_x = 0x7ffffffef380fcff68e38a9fcc30b4c64e94dbc4f2b03a88ae0650f51f46fe1f4f10ba102d77eb77c1547e0c40e6d7aeb05539c308ea01dafb6da33649210fab2cdd38a580091aaec64d74192431c00cce4f4c752498e88aaa5ccc010b2317db8e01cf660e1dc9ba01154024448965f8209721d391f8422ef2e1817ac4240be53bfc0f05b7336e172e271c9e9fcd38057746bbe8f5bb1907ab681ae012395e78e531f5291340108b4f8b182614a29fa0c7a44032229fe3fb3af01a5577cf335f318c1ecc70b613e7532ab85dc087c618020e949640cb14a3dbf634fa0b48f0098c9e9ee4861a5e6193f2a9241e28d1f4d3c9a8f11c460943dbd7b7b06f18fe75454e20593388dcaa8b98aabe293987d22e2725251d6ebf2729cde05db076ed775b7f369d1f9e1109812960b8b76e333bcca8aaa98931c2937cadb68a4ffc6c54eff9a6bcb77da76dc02fcb83167105319dd5a25f19d6ef0b214927120635e665afe46f681259247978d4a6853bb3cac03bc554d07003496f6b8b624bfec45f4cfb24acded0aeb074e8f70df1813ebb26bd5fe26be2a627684d793a8a052e3a9476a1d9697dd9e27beb4db7ad01eb8b0a3b5c7717d716ebd30727cc7786a17f09b04d6b94a56d9f70ac514e026f42834486e6a0852ce00808c7222cc02f90802ab22509fe316612d10d60359087ab7a23be6348b73f6704e6fde2ed070c500db0
    big_y = 0x9ffff4f73caff09ff67fc82fe8f5988fe76cff5b4241f1f3f3f4ccb35f29fff573f617bc077c80165ec5270c0b863fc231ae96dd5d933e9a98abdaf3d6e852e98149945ab1a9a90e38e07c3017c1273b18598d87b59a289de9d7c5bc5c6f64cccdbcbec42c289c8b1b799f8454cba6b89e5976a84c19217d64ddde5af42e37ab465928d068deaa3a0270b8d062dbe0b737667c3afd065871532081e72bc1f79e1d7ebd1fb933ec3555a8e986f949f72ca11bc2fbe4c704b20838c68b707d9f3db1d8ae45b44b6bd36a58bfbf7d565347a6c6e20130c84f1bad77f6251e81dfb6ffa9a508d64db7d2fe48b5e4ebe68e7c8d62cdf5ab1c2ca8c2d2e835a1423acbef65956c980dfb62b3a405b9efbc93283d5071c2129b831481c537cc5be8f1d2723f1168f797bde736c1f73054d7d0dc97538fba25bb3e38703934d8fc46ad22eb23ea409184c3dba8241efc92ce5a6728f4385da637bc23ef7acb506d0543804ae7d660926a82406f9d3206376d5454466ecde2246a125c99aebdf16743d55cfb1c4ab0fdb8387320d541a94e3c5aa6038466eaa18682a163d571db3214de448b3d4d7a632bc60f0a524a041cd6e72a75dbc9f6bb63743df3c3c0d4649a28bd0bbeee569182303a66b830a2273b8df05c712adadf2bcb75244a66826265da778e0c3b45a20d6c962fd203e708ff62dd29b9edd90f2afd2bfe92014968e4396a

    mont_iddmm_result = mont_iddmm(big_x,big_y,big_m,K*N,N)
    print('mont_iddmm_result:\n0x{:x}'.format(mont_iddmm_result))
    mont_iddmm_result_verified = big_x*big_y*mod_inv(2**(K*N),big_m) % big_m
    print('mont_iddmm_result_verified:\n0x{:x}\n'.format(mont_iddmm_result_verified))
    assert  mont_iddmm_result == mont_iddmm_result_verified

def data_seperate_printf_new(data,nbit,n,order,file_path):#0 reverse,1 normal
    RESULT_LOG = open(file_path,'w').close()
    RESULT_LOG = open(file_path,'a',encoding="utf-8")
    if order==0:
        for i in range(n):
            # print('128\'h{:x},'.format(data>>(i*nbit)&(2**nbit-1)),end='\n')
            print('{:x}'.format(data>>(i*nbit)&(2**nbit-1)),end='\n',file=RESULT_LOG)
    else:
        for i in range(n-1,-1,-1):
            # print('128\'h{:x},'.format(data>>(i*nbit)&(2**nbit-1)),end='\n')
            print('{:x}'.format(data>>(i*nbit)&(2**nbit-1)),end='\n',file=RESULT_LOG)
    print('\n')

# def seperate_mul():
#     n = 
#     x = [0 for i in range(n)]
#     y = [0 for i in range(n)]
#     for i in range(n):
#         x_[i] = mm(xx>>(i*k),k)
#         y_[i] = mm(yy>>(i*k),k)


if __name__=='__main__':
    # RESULT_LOG = open("result_log.txt",'w').close()
    # a = 0xa23f8540376d6cdc766d1ed79b923b3d0ceafc02c3d8b7d2bd24cc4a6b0e595d4e7feb630ab20352027ae7a7077b0cce9070fb17aa7b40eafd6fcf13bec5cb81ac3e4e45ca09f13847d13c1cc653912f99709e98b2334edf4bdd0776c2fcb0d96b059a6e963cce35abce84186866e50e555ddf482a13e999beb9af1c8a03fb9e956a16cab697ced16c5262a94473f5284901b5a57b12302f0e634e8c3d660178ee227e8cc4dcc720156655ceff69cb8e0acbdfd4838134ae69680f35a175a2c85e5228c4fc28eaf1e88c4c86acb0f53b044c3db982c583121632b3a48259ad37ee28e475ca99c13c516e4fa4523ac2ea6c570ffaf70def26b6b7b6a65be121b
    # data_seperate_printf(a,32,4096//32,0)
    # b = 0x227a17f9e237a17b6ebc0e56c2d4df4274c226869c9822b41b1f09489787c0ca0b41de5892e6b76137da44a11f5fbea20036e11ad41e9f6ad2f59f4774618145abd9e71bb258af3b074f89c22687144181bcf0ed26a94631ac51d3fee64523ec5f880c0d784e43d1c3d6891fa91ee35f1ffb32c06809fc5bc400e5ba5f432cf6ada02c1b36c13de5d6287d689d7a97dcd206e8f8847683e2176ba6f887505a289dc81d0da54afb49bfcf68b69fc4c6facb49e58d382b547efda94e7cf1583abdd71cefccb847094023976e175aa0f0c76e1007ca8971ff7beda4a0cdc508d369c68abe11d8a8938d0b3a1f02230b3ac3a57328e6d7904d66e67b4fb58172c483
    # data_seperate_printf(b,32,4096//32,0)
    
    # rsa_test()
    # montgomery_mul_test()
    iddmm_test()

    # m = 0x92d20837163355491353a40bfbed6afffb000939ca99e2dcb7e96c94d9e6ff1b54db47d62fa87283db4ef47e8119e2cb0d126f44ef110cd64d6493014fbee11fce25ad01515ed88bef11f595cc5b107aed44c3aecf42318a0e9dc2431934703c219abc2ee926037fbd46e2b2465b19b3110e3ccdbdfbe0daadefe22a725ef38bc2371fdc5e9cfb439ea6ac84b3e424e71cc3a263dc8cb4642042d01abe4e54416d821fae3e588950e16d5bdc76fc0629b4829eabad9ad1535fc322dc0ad791ca8a353157ab771cc0eafb621a07b0ce0998a65541754ffeedb756ff3ca3b606dea2b63fa2483a5dda07c17496f556f441e4c09fbb079cbbb8279c01fca24b56bf32e9902603d670439cee8a4f9730281ca7e736783300f69b64cce28fb565b99599758f8c8e5d58ce03af202cfe8d88092884f15b5a76578db8bf6a32cf7e2d78a758c60de9e6cf037bd2a6c7d22c670b8b384722fef18a9870588c1368f3c1f82caa709eff78cfdb2a3594bce3977875c0c30e464a5fc136225c7e206ba599b14ec856a9a230bca081331c969774eb112295c0670d4cb20723ceaa02e0ff4879a508052dad14c59f1787572686d68c51eb3ce8f505e141803ec18bc77c4986a7ea1dd24c13c7bb976496361ad38078e2daaf39f049a489793e2b46643b3eb3f168a3ad29eb4accb4ca422e7dd70e809f4ad5ed15d295f6765773bb5d851b3e81
    # file_path = '1.RTL/data/ram_me_m.txt'
    # data_seperate_printf_new(m,128,4096//128,0,file_path)

    # file_path = '1.RTL/data/ram_me_rou.txt'
    # rou = fastExpMod(2,4096*2,m)
    # data_seperate_printf_new(rou,128,4096//128,0,file_path)

    # file_path = '1.RTL/data/ram_me_result.txt'
    # result = fastExpMod(2,4096,m)
    # data_seperate_printf_new(result,128,4096//128,0,file_path)

    # file_path = '1.RTL/data/ram_me_result_backup.txt'
    # data_seperate_printf_new(result,128,4096//128,0,file_path)
