#
#   Name        :mm hardware verify
#   Description :Montgomery快速模乘，硬件模型验证算法
#   Orirgin     :20200622
#               :20200817
#   Author      :helrori2011@gmail.com
#
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
    print('\nmont_iddmm-----------------------------------------------------------------')
    k=nbit//n
    beta=2**k
    print('gcd(p,beta):{}'.format(math.gcd(p,beta)))
    if math.gcd(p,beta)!=1:
        return 0
    p1=(-1*(mod_inv(p,beta)))%beta    
    print('p1:0x{:x}'.format(p1))
    carry=0
    a  = [0 for i in range(n+1)]
    x_ = [0 for i in range(n+1)]
    y_ = [0 for i in range(n  )]
    p_ = [0 for i in range(n+1)]
    for i in range(n):
        x_[i] = mm(xx>>(i*k),k)
        y_[i] = mm(yy>>(i*k),k)
        p_[i] = mm(p >>(i*k),k)
    for i in range(n):
        c = 0
        for j in range(n+1):
            s = a[j]+x_[j]*y_[i]
            s = mm(s,2*k)
            if j==0:
                q = mm(s,k)*mm(p1,k)%beta
            if j==n:
                s = s+carry
            r   = q*p_[j]
            buf0= s+r+c
            u   =  mm(buf0,k)
            c   = (buf0>>k)
            if j>0:
                a[j-1] = u
        carry = c&1
    a[n] = carry
    res = a
    su  = 0
    for i in range(len(res)):
        su = su+res[i]*(beta**i)
    if su >= p:
        su = su - p
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
            print('128\'h{:x},'.format(data>>(i*nbit)&(2**nbit-1)),end='\n',file=RESULT_LOG)
        print('--------------------------------------------------',end='\n',file=RESULT_LOG)
    else:
        print('--------------------------------------------------',end='\n',file=RESULT_LOG)
        for i in range(n-1,-1,-1):
            # print('128\'h{:x},'.format(data>>(i*nbit)&(2**nbit-1)),end='\n')
            print('128\'h{:x},'.format(data>>(i*nbit)&(2**nbit-1)),end='\n',file=RESULT_LOG)
        print('--------------------------------------------------',end='\n',file=RESULT_LOG)
    print('\n')

def RSA2048_test(xx,yy,p,nbit):
    
    RESULT_LOG = open("result_log.txt",'w').close()

    result0 = fastExpMod(xx,yy,p)   
    print('mont_r2mm_hd():\n0x{:x}\n'.format(result0))

    rou = fastExpMod(2,2*nbit,p)
    # data_seperate_printf(rou,128,nbit//128,1)

    #two calculation methods are equivalent for result
    # result = mont_r2mm(rou,1,p,nbit)
    result = fastExpMod(2,nbit,p)
    # data_seperate_printf(result,128,nbit//128,1)

    result2 = mont_r2mm(xx,rou,p,nbit)
    # data_seperate_printf(result2,128,nbit//128,1)

    for(i) in range(nbit-1,-1,-1):
        result = mont_r2mm(result,result,p,nbit)
        data_seperate_printf(result,128,nbit//128,1)
        if((yy>>i)&1==1):
            result = mont_r2mm(result,result2,p,nbit)
            data_seperate_printf(result,128,nbit//128,1)
        num = (yy>>i)&1
    result = mont_r2mm(result,1,p,nbit)
    data_seperate_printf(result,128,nbit//128,1)
    
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

def main():

    k = 4096
    m = 0Xff5f4906fd176bc241535c78955d02f4d0acf376d736ae280077887200c758b7781b4432fa8baca2a81ad6fb0817051a00fccf8e15c63048681bcf8342b56433abd550affa489b289cd4f0482adce321c8cf4374ce15267692dfc8b0da108f4bb0e922d4a28402ef785c2516f6296486f8505ac3df05c0f953acce65e2dc5f1e59965ded73fa18ffb482ad1a2e5433d4df8211de12a3e7a71a1a084fed671fb11eeaf76f640c4fd549ea307b6622f798f027786e79232206de1507281d84c719209d408bc85f9ed2e1b82ecf72ff805a45221dc712c45a8dbc375e9b64227ec6b659a75fc5b5e051e776bcd9f4f6d82ebaff89a48c8494d6ed072372b846156af229994baab390ec57c00130255acc2cdf975783df4678153f0ca51b854425b1568b5b8b53239f50dd39fc53c3d41827a0687c435f6de5e98843def3fb7b0f7e701cdfb51517d6628392bd9291c16282556f5581766dd6a0a426a35312237399f93ad69502592c0f6d1864ba0b75600ee04cb406bcb833bc98527a0ac1249c6a918456b06f24611770c1708426b4d9041f7fe83be68fbc7018e461951d234ebf00227b4301911e24055c745203c888276f4db0c05f66514ae4e6b4bf4c8914e36c4a94bf57bf807dd40c7572d1a99c27d9f58af0877bb217c081d750d5edbe3c45eafc3ea6786560fa819873452cc8bffc7ab998ab70496b77fdadffb7ef2621
    x = 0X7ffffffef380fcff68e38a9fcc30b4c64e94dbc4f2b03a88ae0650f51f46fe1f4f10ba102d77eb77c1547e0c40e6d7aeb05539c308ea01dafb6da33649210fab2cdd38a580091aaec64d74192431c00cce4f4c752498e88aaa5ccc010b2317db8e01cf660e1dc9ba01154024448965f8209721d391f8422ef2e1817ac4240be53bfc0f05b7336e172e271c9e9fcd38057746bbe8f5bb1907ab681ae012395e78e531f5291340108b4f8b182614a29fa0c7a44032229fe3fb3af01a5577cf335f318c1ecc70b613e7532ab85dc087c618020e949640cb14a3dbf634fa0b48f0098c9e9ee4861a5e6193f2a9241e28d1f4d3c9a8f11c460943dbd7b7b06f18fe75454e20593388dcaa8b98aabe293987d22e2725251d6ebf2729cde05db076ed775b7f369d1f9e1109812960b8b76e333bcca8aaa98931c2937cadb68a4ffc6c54eff9a6bcb77da76dc02fcb83167105319dd5a25f19d6ef0b214927120635e665afe46f681259247978d4a6853bb3cac03bc554d07003496f6b8b624bfec45f4cfb24acded0aeb074e8f70df1813ebb26bd5fe26be2a627684d793a8a052e3a9476a1d9697dd9e27beb4db7ad01eb8b0a3b5c7717d716ebd30727cc7786a17f09b04d6b94a56d9f70ac514e026f42834486e6a0852ce00808c7222cc02f90802ab22509fe316612d10d60359087ab7a23be6348b73f6704e6fde2ed070c500db0
    y = 0X9ffff4f73caff09ff67fc82fe8f5988fe76cff5b4241f1f3f3f4ccb35f29fff573f617bc077c80165ec5270c0b863fc231ae96dd5d933e9a98abdaf3d6e852e98149945ab1a9a90e38e07c3017c1273b18598d87b59a289de9d7c5bc5c6f64cccdbcbec42c289c8b1b799f8454cba6b89e5976a84c19217d64ddde5af42e37ab465928d068deaa3a0270b8d062dbe0b737667c3afd065871532081e72bc1f79e1d7ebd1fb933ec3555a8e986f949f72ca11bc2fbe4c704b20838c68b707d9f3db1d8ae45b44b6bd36a58bfbf7d565347a6c6e20130c84f1bad77f6251e81dfb6ffa9a508d64db7d2fe48b5e4ebe68e7c8d62cdf5ab1c2ca8c2d2e835a1423acbef65956c980dfb62b3a405b9efbc93283d5071c2129b831481c537cc5be8f1d2723f1168f797bde736c1f73054d7d0dc97538fba25bb3e38703934d8fc46ad22eb23ea409184c3dba8241efc92ce5a6728f4385da637bc23ef7acb506d0543804ae7d660926a82406f9d3206376d5454466ecde2246a125c99aebdf16743d55cfb1c4ab0fdb8387320d541a94e3c5aa6038466eaa18682a163d571db3214de448b3d4d7a632bc60f0a524a041cd6e72a75dbc9f6bb63743df3c3c0d4649a28bd0bbeee569182303a66b830a2273b8df05c712adadf2bcb75244a66826265da778e0c3b45a20d6c962fd203e708ff62dd29b9edd90f2afd2bfe92014968e4396a

    # data_seperate_printf(m,128,k//128,1)
    # beta=2**k
    # p1=((-1*(mod_inv(m,beta)))%beta)%(2**128)#The lower 128-bit data is reserved.
    # print('m1=(-1*(mod_inv(m,2**K)))%2**K:\n0x{:x}\n'.format(p1))


    # RESULT_LOG = open("result_log.txt",'w').close()
    # rou = fastExpMod(2,2*k,m)
    # data_seperate_printf(rou,128,k//128,1)
    # result = fastExpMod(2,k,m)
    # data_seperate_printf(result,128,k//128,1)


    # RSA2048_test(x,y,m,k)

    return 0

if __name__=='__main__':
    # main()
    montgomery_mul_test() 


# result0              :
# 0x951f01eb532bd0fb7a568bd22f7096016d32af84b721593062a0c92c4d8d61bad0fb759f56e3d8760b0ef1ca473e2ee2c936232a81bb83faa06e24048c3d63a3fb513a274bc11a036892a06efd1bdd51d8db4421b3fbc54770ca48442339a5e7072af42a77dec36b7b9a8219eb3607b24297cb827c5e0a3d3c5f3de53318b0e4b0face58687bff3d2d05a65b72ff5d2a39f857466a66dfdb644f09039a0b3f04222ed8c1b4b936fa286b0777d2fdc66ba9b80ac5739c8861c480977fca2761954443ee6209e65edc431f60d2ba10d2795d6803385c90f8b5630b0dcb2a39358d730005afa6d7916708c0fbf3e614b366059cc6509c837d529d07e17ebd886e65be6f68f6e7f87a20870e8ff1c6d4a6dc58584671ca1801af2a575830d7ae46de951f6a835a982c667a3af53605b1e87ab13d85ce849e69f70b8beaa5049f52616f0ca551971a70b12c474d41001d5c9b08942cf665a034c9f9801e874503c3964975efc869aea8c794917c52419ebdc99567eaf1a649450295a6388b591dcf0b8eddeaaaf0b279eab7150a011371938db8c77ccefd460bccc66a87801d71f878746831de60d31f3480c26da4c41aafd4ba0d7779927322b2c846b49ea48e16bfc93a06d786f857f6f85728981176b93ad7b2824ac132cb84e41fea497ddd34ffad64197c6d38d6f0f40f94db04062678b0992e69c8c4f8752907fde997943ef

# result1              :
# 0x83164d9d5a964097d674a0f04cebda7a961f61936e15832946f1fd75d533d4153356b96cd6228f90bb16afe09eac08ecbe3cf737bd63b200a4a8c40879be0df1eb8234bdcfa14debf4813b6ac2783ee707a6ac7f7a395eb8b09ff20e0f47e56a0868d0b0b94a5870ab96e7ea32614e5340e139ef2287b25f5cafabe51bf8934360a139d607aa7d255944f5ca7b89dd808a5cb0859841a7e647a6a54418960debb4a2abe9220d046026c5bf6ea84e7d1f3753a68b985c855cefd0df282f7d773c0af0d565b3fbd59fba8b01ca276273480984d8b7d6379f1f01ec9c659d16d357b4136ba0eef2c2e107ef8a417c7ee51a732ef856839b4d5f261f95136fdbbae9daf0f69524a64b40f2200f087107ec58930b1a428d376591a39b1dc6a7c159c66727f66e7c7cba9b6567eab1a540e13cacecd0f29f97115338a8afd393a230357d09a40d0e0b2427f3a4237869ef791606e036ba4595369329ce8b593e172be972fb3411869053445ea96351ad988a5fd5fb9381460d8da15582febd81d08cca75c4869c3e2e970ed3afd92717058fc71715c6b0f17e30df71560e35d385f510997a821ac76c8245d0c0bf6097be691026fd5d1c5ed44cf1724b980a90e24a623761d4a22b998be263a2fbe0637efd8d126e34eccd6c61dd8e8b2a16b49bc87df7306a4eab9b4c2bb215ae501d9f8a7817c85822e4f2dd3e64aa17052bcee518

# result2              :
# 0x5a22cbea5a14f9d2acaa955349721f5af8019c64842d38887d2306bb5a320c50e3f021745d29434fe9dd133d117ddaf70f9d5b7ef6490a9e4296f214e8693e7266f172fd370055ff1a83169a542d0919e02d31542a9536a3c3bda7f32085f909bb7edb6a7d8e5247644b39ceddfe88f915f5cd325c7888e10bc6d78d4e506330dc12e44d50174c73bdaca2c7dbf2469945990d4c15e53894482381068e4b703c4f876bcb244966d25a9f8816119a6ab7d9a467a6e23e71146e7f2e813dad5d68d45509cb08cb545a4da8c603b7ed3ada2698898c603fd28f3774e9409ab8a1408b29458462af414c2e62a511ba323138cd2810b4c01879e2c3bcc65fb15e845b7b85f157564d0cacc0a1f35b6da23cdb7307feec1857bd5306b23f08660142687ba9b6a34ce0d1be420b5142cdca1fcc82729108aa516ec524e59f60ecea6faefe21c75b728cd112ae80a2d756652dd8ad55daf7be615194f7328d1b9d4d7a28addce5409e9e1d44d5394e587f6e3e36d62df168096cea16d081047a56919c398386f72531727c2eab865746fee2555e96fe457ae9f4b51523c34dc74c3eff1d6163da88640939ac89bd4681de48adf0a8b4cd8220387c7975dc0e7a1adeac1820b8c30a29b9eac9f9efad551841f8262cd051fd549a1b25e5a6d30bac6ac27e245d8ed500c9a3eb51fabee32b98fa7eda922bcfabb4803f9ce9eefba400b398

# montgomery_mul_test  :
# 0x39979947f84591c7011dc06e677dc75ce460fd29a14d022555732743a714c8cf18ff8ebe1a8b01aabd6d421cf63ee8f0870f09badc9224f9fed2af198c5da91847bb617d0e28a369453604f44580667d19c6cbf1365dc89c74126ac7c4ff6f974fdb853bf92e50975dd7c5e6e3bed5c2c20b11011a8f308c56d193bf1461326716180d26596840499b727663b9271e7ad17020b0202ffeb0f83d610245b396e63ea93b568be6ad20dcf85bd66411987b9c99a9756a6b21c03e7d16d9807cf9b1f63208f216144c08c5c571343d1d05032239a444b890d96abed9f0cbacfbbfab6f2f28f1460f6ed4e906b303d12bf4f1ec40d1a7d4a572dfa8b09a0fa5730ff88981780bb3f309afc99fab51bba5b1e5c768809c880bda44efa7cfbb03ac9d317cd6211d142fd3eb964d872d3a8f833a19a0c0b825bdf7972a22e3133a538a063430cfef88eb7aa8f028d88a7272678ccb0deff5bd7ae373a62ffa5789c874dac229ecda874772927346cf18c197bae55c93c16eeacbea4acc52a6abd20e95f0aa41adb389c6468400741f2a27fbee12e8de39d80f67fa81e252caa8d46903016e3202345b9abeab552d7f912d346ce1603e209010af32ef06b3286e86daeb8ced3dfc0a45097f952aade6a537c61f26a2e1c47658ce092e9b6c29a02604523b931dd247099e3123c04a84ebad9f2f569be1df94c3fe93f1c92358cd60233349

# confirm result()     :
# 0x39979947f84591c7011dc06e677dc75ce460fd29a14d022555732743a714c8cf18ff8ebe1a8b01aabd6d421cf63ee8f0870f09badc9224f9fed2af198c5da91847bb617d0e28a369453604f44580667d19c6cbf1365dc89c74126ac7c4ff6f974fdb853bf92e50975dd7c5e6e3bed5c2c20b11011a8f308c56d193bf1461326716180d26596840499b727663b9271e7ad17020b0202ffeb0f83d610245b396e63ea93b568be6ad20dcf85bd66411987b9c99a9756a6b21c03e7d16d9807cf9b1f63208f216144c08c5c571343d1d05032239a444b890d96abed9f0cbacfbbfab6f2f28f1460f6ed4e906b303d12bf4f1ec40d1a7d4a572dfa8b09a0fa5730ff88981780bb3f309afc99fab51bba5b1e5c768809c880bda44efa7cfbb03ac9d317cd6211d142fd3eb964d872d3a8f833a19a0c0b825bdf7972a22e3133a538a063430cfef88eb7aa8f028d88a7272678ccb0deff5bd7ae373a62ffa5789c874dac229ecda874772927346cf18c197bae55c93c16eeacbea4acc52a6abd20e95f0aa41adb389c6468400741f2a27fbee12e8de39d80f67fa81e252caa8d46903016e3202345b9abeab552d7f912d346ce1603e209010af32ef06b3286e86daeb8ced3dfc0a45097f952aade6a537c61f26a2e1c47658ce092e9b6c29a02604523b931dd247099e3123c04a84ebad9f2f569be1df94c3fe93f1c92358cd60233349