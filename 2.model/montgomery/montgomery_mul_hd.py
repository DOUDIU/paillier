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
    data_seperate_printf(rou,128,nbit//128,1)

    #two calculation methods are equivalent for result
    # result = mont_r2mm(rou,1,p,nbit)
    result = fastExpMod(2,nbit,p)

    data_seperate_printf(result,128,nbit//128,1)
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

    k = 4096
    m = 0Xff5f4906fd176bc241535c78955d02f4d0acf376d736ae280077887200c758b7781b4432fa8baca2a81ad6fb0817051a00fccf8e15c63048681bcf8342b56433abd550affa489b289cd4f0482adce321c8cf4374ce15267692dfc8b0da108f4bb0e922d4a28402ef785c2516f6296486f8505ac3df05c0f953acce65e2dc5f1e59965ded73fa18ffb482ad1a2e5433d4df8211de12a3e7a71a1a084fed671fb11eeaf76f640c4fd549ea307b6622f798f027786e79232206de1507281d84c719209d408bc85f9ed2e1b82ecf72ff805a45221dc712c45a8dbc375e9b64227ec6b659a75fc5b5e051e776bcd9f4f6d82ebaff89a48c8494d6ed072372b846156af229994baab390ec57c00130255acc2cdf975783df4678153f0ca51b854425b1568b5b8b53239f50dd39fc53c3d41827a0687c435f6de5e98843def3fb7b0f7e701cdfb51517d6628392bd9291c16282556f5581766dd6a0a426a35312237399f93ad69502592c0f6d1864ba0b75600ee04cb406bcb833bc98527a0ac1249c6a918456b06f24611770c1708426b4d9041f7fe83be68fbc7018e461951d234ebf00227b4301911e24055c745203c888276f4db0c05f66514ae4e6b4bf4c8914e36c4a94bf57bf807dd40c7572d1a99c27d9f58af0877bb217c081d750d5edbe3c45eafc3ea6786560fa819873452cc8bffc7ab998ab70496b77fdadffb7ef2621
    x = 0X7ffffffef380fcff68e38a9fcc30b4c64e94dbc4f2b03a88ae0650f51f46fe1f4f10ba102d77eb77c1547e0c40e6d7aeb05539c308ea01dafb6da33649210fab2cdd38a580091aaec64d74192431c00cce4f4c752498e88aaa5ccc010b2317db8e01cf660e1dc9ba01154024448965f8209721d391f8422ef2e1817ac4240be53bfc0f05b7336e172e271c9e9fcd38057746bbe8f5bb1907ab681ae012395e78e531f5291340108b4f8b182614a29fa0c7a44032229fe3fb3af01a5577cf335f318c1ecc70b613e7532ab85dc087c618020e949640cb14a3dbf634fa0b48f0098c9e9ee4861a5e6193f2a9241e28d1f4d3c9a8f11c460943dbd7b7b06f18fe75454e20593388dcaa8b98aabe293987d22e2725251d6ebf2729cde05db076ed775b7f369d1f9e1109812960b8b76e333bcca8aaa98931c2937cadb68a4ffc6c54eff9a6bcb77da76dc02fcb83167105319dd5a25f19d6ef0b214927120635e665afe46f681259247978d4a6853bb3cac03bc554d07003496f6b8b624bfec45f4cfb24acded0aeb074e8f70df1813ebb26bd5fe26be2a627684d793a8a052e3a9476a1d9697dd9e27beb4db7ad01eb8b0a3b5c7717d716ebd30727cc7786a17f09b04d6b94a56d9f70ac514e026f42834486e6a0852ce00808c7222cc02f90802ab22509fe316612d10d60359087ab7a23be6348b73f6704e6fde2ed070c500db0
    y = 0X9ffff4f73caff09ff67fc82fe8f5988fe76cff5b4241f1f3f3f4ccb35f29fff573f617bc077c80165ec5270c0b863fc231ae96dd5d933e9a98abdaf3d6e852e98149945ab1a9a90e38e07c3017c1273b18598d87b59a289de9d7c5bc5c6f64cccdbcbec42c289c8b1b799f8454cba6b89e5976a84c19217d64ddde5af42e37ab465928d068deaa3a0270b8d062dbe0b737667c3afd065871532081e72bc1f79e1d7ebd1fb933ec3555a8e986f949f72ca11bc2fbe4c704b20838c68b707d9f3db1d8ae45b44b6bd36a58bfbf7d565347a6c6e20130c84f1bad77f6251e81dfb6ffa9a508d64db7d2fe48b5e4ebe68e7c8d62cdf5ab1c2ca8c2d2e835a1423acbef65956c980dfb62b3a405b9efbc93283d5071c2129b831481c537cc5be8f1d2723f1168f797bde736c1f73054d7d0dc97538fba25bb3e38703934d8fc46ad22eb23ea409184c3dba8241efc92ce5a6728f4385da637bc23ef7acb506d0543804ae7d660926a82406f9d3206376d5454466ecde2246a125c99aebdf16743d55cfb1c4ab0fdb8387320d541a94e3c5aa6038466eaa18682a163d571db3214de448b3d4d7a632bc60f0a524a041cd6e72a75dbc9f6bb63743df3c3c0d4649a28bd0bbeee569182303a66b830a2273b8df05c712adadf2bcb75244a66826265da778e0c3b45a20d6c962fd203e708ff62dd29b9edd90f2afd2bfe92014968e4396a


    # data_seperate_printf(m,128,k//128,1)
    beta=2**k
    p1=((-1*(mod_inv(m,beta)))%beta)%(2**128)#The lower 128-bit data is reserved.
    print('m1=(-1*(mod_inv(m,2**K)))%2**K:\n0x{:x}\n'.format(p1))

    # RSA2048_test(x,y,m,k)

    return 0

if __name__=='__main__':
    main()


    


    # k = 2048
    # x = 0xABA5E025B607AA14F7F1B8CC88D6EC01C2D17C536508E7FA10114C9437D9616C9E1C689A4FC54744FA7DFE66D6C2FCF86E332BFD6195C13FE9E331148013987A947D9556A27A326A36C84FB38BFEFA0A0FFA2E121600A4B6AA4F9AD2F43FB1D5D3EB5EABA13D3B382FED0677DF30A089869E4E93943E913D0DC099AA320B8D8325B2FC5A5718B19254775917ED48A34E86324ADBC8549228B5C7BEEEFA86D27A44CEB204BE6F315B138A52EC714888C8A699F6000D1CD5AB9BF261373A5F14DA1F568BE70A0C97C2C3EFF0F73F7EBD47B521184DC3CA932C91022BF86DD029D21C660C7C6440D3A3AE799097642F0507DFAECAC11C2BD6941CBC66CEDEEAB744
    # y = 0xD091BE9D9A4E98A172BD721C4BC50AC3F47DAA31522DB869EB6F98197E63535636C8A6F0BA2FD4C154C762738FBC7B38BDD441C5B9A43B347C5B65CFDEF4DCD355E5E6F538EFBB1CC161693FA2171B639A2967BEA0E3F5E429D991FE1F4DE802D2A1D600702E7D517B82BFFE393E090A41F57E966A394D34297842552E15550B387E0E485D81C8CCCAAD488B2C07A1E83193CE757FE00F3252E4BD670668B1728D73830F7AE7D1A4C02E7AFD913B3F011782422F6DE4ED0EF913A3A261176A7D922E65428AE7AAA2497BB75BFC52084EF9F74190D0D24D581EB0B3DAC6B5E44596881200B2CE5D0FB2831D65F036D8E30D5F42BECAB3A956D277E3510DF8CBA9
    # m = 0xD27BF9F01E2A901DB957879F45F697330D21A21095DA4FA7D3AAB75454A8E9F0F4EA531ECE34F0C3BA9E02EB27D8F0DBE78EEDE4AC84061BEEF162D00B55C0DD772D28F23E994899AA19B9BEA7B12A8027A32A92190A3630E249544675488121565A23548FCD36F5382EEB993DB9CE3F526F20AB355E82D963D59541BC1161E211A03E3B372560840C57E12BD2F40EAC5FFCEC01B3F07C378C0A60B74BEF7B572764C88A4F98B61FA8CCD905AFAE779E6193378304D8EB17695CE71A173AC3DE11271753C48DB58546E5AF9917C1CEBBA5BB1AF3FCE3DF9516C0C95C9BC14BB65D1C53078C06C81AC0F3ED0D8634260E47BF780CF4F4996084DF732935194417

    # k = 2048
    # x = 0x22b9488b532b70043ed0116220ef1c91f03830dcb5aa255c18484dae2ce4cecc8d2ac76151d7d63ce985a13be321ae1f53c33dd2565b46b5088fb1404ca4f4f6c00a21fc4068148cdc1a69a535175244ce0bd94257080365bcc7a5c6bed0f259897930aa8e4c75428ef16f770d4e01a15a9d2ca9cb1948989992a669155c108502a5c88b0a895715edc45226c9d5ba6d293c88c3aaa2bc414ec01841a9589234e68d80f5588fbf366684e32e516092385bd202b0b2fe2a23bd088d47dcd9d956f74506cbe2c28457abec5e600b8cca286f2ca5ba6265d50d8b6429791613ad97c872f0349151830a0c41bd1d786bf68cbf721d374d2520f1dc76a11ced37b118
    # y = 0x010001
    # m = 0xDC1B56F36E933EC234545C4715370B14CAE00EA9376E9F65DE2C1361F116F05A4C2FF556FF0052F8E2D3434FF5E843A6B246449DE6C8F04C7CA821EFFBAA1DBCC7A1B903A05B7671BB6D0FD8639D492C5B74C2C91510E3B006B227CBF14A694C21A98A4B1A2474613ECD29405863716CF3DF5D3160ED0B992A25B35626E67FF1AA9242ED3A1F7EAD7C638B26DBE3624B6712055E101C07761FA6EFE38D915006F52BB4D76E52F13EAD7D04B046FB4ACFC02A57E02CF28CC1AFC3D22B572669A99EE7D357B840BC8BFA4EB1BBAD287824D93AC259D59EBBAA798ED0F026E5A0E05392683A68B16964160DF9366AF79B0AA8D95FA996E636022E584863A3F4E0D1