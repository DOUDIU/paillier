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
    if order==0:
        for i in range(n):
            print('128\'h{:x},'.format(data>>(i*nbit)&(2**nbit-1)),end='\n')
    else:
        for i in range(n-1,-1,-1):
            print('128\'h{:x},'.format(data>>(i*nbit)&(2**nbit-1)),end='\n')
    print('\n')

def RSA2048_test(xx,yy,p,nbit):

    result0 = fastExpMod(xx,yy,p)   
    print('mont_r2mm_hd():\n0x{:x}\n'.format(result0))

    rou = fastExpMod(2,2*nbit,p)
    # data_seperate_printf(rou,128,nbit//128,1)
    result = mont_r2mm(rou,1,p,nbit)
    # data_seperate_printf(result,128,nbit//128,1)
    result2 = mont_r2mm(xx,rou,p,nbit)

    for(i) in range(nbit-1,-1,-1):
        result = mont_r2mm(result,result,p,nbit)
        if((yy>>i)&1==1):
            result = mont_r2mm(result,result2,p,nbit)
        num = (yy>>i)&1
    result = mont_r2mm(result,1,p,nbit)
    
    if result0==result:
        print('mont_iddmm()==x*y*r^(-1)modm  match!')
    else:
        print('mont_iddmm()==x*y*r^(-1)modm  dont match!')

    # print('mont_r2mm_hd():\n0x{:x}\n'.format(result0))
    # print('mont_r2mm_hd():\n0x{:x}\n'.format(result))

    return 0



def main():

    k = 2048
    x = 0xABA5E025B607AA14F7F1B8CC88D6EC01C2D17C536508E7FA10114C9437D9616C9E1C689A4FC54744FA7DFE66D6C2FCF86E332BFD6195C13FE9E331148013987A947D9556A27A326A36C84FB38BFEFA0A0FFA2E121600A4B6AA4F9AD2F43FB1D5D3EB5EABA13D3B382FED0677DF30A089869E4E93943E913D0DC099AA320B8D8325B2FC5A5718B19254775917ED48A34E86324ADBC8549228B5C7BEEEFA86D27A44CEB204BE6F315B138A52EC714888C8A699F6000D1CD5AB9BF261373A5F14DA1F568BE70A0C97C2C3EFF0F73F7EBD47B521184DC3CA932C91022BF86DD029D21C660C7C6440D3A3AE799097642F0507DFAECAC11C2BD6941CBC66CEDEEAB744
    y = 0xD091BE9D9A4E98A172BD721C4BC50AC3F47DAA31522DB869EB6F98197E63535636C8A6F0BA2FD4C154C762738FBC7B38BDD441C5B9A43B347C5B65CFDEF4DCD355E5E6F538EFBB1CC161693FA2171B639A2967BEA0E3F5E429D991FE1F4DE802D2A1D600702E7D517B82BFFE393E090A41F57E966A394D34297842552E15550B387E0E485D81C8CCCAAD488B2C07A1E83193CE757FE00F3252E4BD670668B1728D73830F7AE7D1A4C02E7AFD913B3F011782422F6DE4ED0EF913A3A261176A7D922E65428AE7AAA2497BB75BFC52084EF9F74190D0D24D581EB0B3DAC6B5E44596881200B2CE5D0FB2831D65F036D8E30D5F42BECAB3A956D277E3510DF8CBA9
    m = 0xD27BF9F01E2A901DB957879F45F697330D21A21095DA4FA7D3AAB75454A8E9F0F4EA531ECE34F0C3BA9E02EB27D8F0DBE78EEDE4AC84061BEEF162D00B55C0DD772D28F23E994899AA19B9BEA7B12A8027A32A92190A3630E249544675488121565A23548FCD36F5382EEB993DB9CE3F526F20AB355E82D963D59541BC1161E211A03E3B372560840C57E12BD2F40EAC5FFCEC01B3F07C378C0A60B74BEF7B572764C88A4F98B61FA8CCD905AFAE779E6193378304D8EB17695CE71A173AC3DE11271753C48DB58546E5AF9917C1CEBBA5BB1AF3FCE3DF9516C0C95C9BC14BB65D1C53078C06C81AC0F3ED0D8634260E47BF780CF4F4996084DF732935194417

    # k = 2048
    # x = 0x22b9488b532b70043ed0116220ef1c91f03830dcb5aa255c18484dae2ce4cecc8d2ac76151d7d63ce985a13be321ae1f53c33dd2565b46b5088fb1404ca4f4f6c00a21fc4068148cdc1a69a535175244ce0bd94257080365bcc7a5c6bed0f259897930aa8e4c75428ef16f770d4e01a15a9d2ca9cb1948989992a669155c108502a5c88b0a895715edc45226c9d5ba6d293c88c3aaa2bc414ec01841a9589234e68d80f5588fbf366684e32e516092385bd202b0b2fe2a23bd088d47dcd9d956f74506cbe2c28457abec5e600b8cca286f2ca5ba6265d50d8b6429791613ad97c872f0349151830a0c41bd1d786bf68cbf721d374d2520f1dc76a11ced37b118
    # y = 0x010001
    # m = 0xDC1B56F36E933EC234545C4715370B14CAE00EA9376E9F65DE2C1361F116F05A4C2FF556FF0052F8E2D3434FF5E843A6B246449DE6C8F04C7CA821EFFBAA1DBCC7A1B903A05B7671BB6D0FD8639D492C5B74C2C91510E3B006B227CBF14A694C21A98A4B1A2474613ECD29405863716CF3DF5D3160ED0B992A25B35626E67FF1AA9242ED3A1F7EAD7C638B26DBE3624B6712055E101C07761FA6EFE38D915006F52BB4D76E52F13EAD7D04B046FB4ACFC02A57E02CF28CC1AFC3D22B572669A99EE7D357B840BC8BFA4EB1BBAD287824D93AC259D59EBBAA798ED0F026E5A0E05392683A68B16964160DF9366AF79B0AA8D95FA996E636022E584863A3F4E0D1

    # data_seperate_printf(m,128,k//128,1)
    # beta=2**k
    # p1=((-1*(mod_inv(m,beta)))%beta)%(2**128)
    # print('m1=(-1*(mod_inv(m,2**K)))%2**K:\n0x{:x}\n'.format(p1))

    RSA2048_test(x,y,m,k)

    return 0

if __name__=='__main__':
    main()
    

c2bccf96fa8eb0551be06506b4b4401057c5c4a1c20790a174d4dba9f09a4de88c671e6abe7adcdd085af635d9fc2f9755b43511aa74e372f484299ff9c408109d05711fb36e2d6ba6640d9e4a49de55113e9fa04ac8332671f2b4977299e20f76c5cabeb59488fcb8501ca0c8c873470f4e411ea69903537bfb7be54add3e16

16a5831ec2bccf96f3dd402cfa8eb055fef8d90b1be065063a3a7d54b4b4401002db743257c5c4a19b6cbe12c20790a189ec1a2974d4dba9a6ff5292f09a4de8a5c125768c671e6ad9eded25be7adcdd0eec2bef085af63512003869d9fc2f976404db8a55b435111a76c802aa74e372c38af53bf484299f14499f54f9c408104de8214a9d05711fded05643b36e2d6bed9d534fa6640d9e6f50b7a54a49de5546dab86f113e9fa0d46919174ac833268bbb3dbf71f2b4971497093e7299e20f919836f876c5cabec8035c83b59488fcc8984848b8501ca07a55850ec8c87347084324500f4e411eb072536ba69903531021a3957bfb7be5f80feab34add3e16
