import math
def k_w(x, width):
    return x & (2**width-1)

#algorithm : Parallel high-radix nonrestoring division - 1993
def phrnd(x, y):
    n = 4096
    m = 2048
    q = 0
    R = 0
    for(i) in range(0,n-m,1):
        if x > 0 :
            x = (x<<1) - (y<<m)
        else :
            x = (x<<1) + (y<<m)
        if x > 0 :
            q = q + (1<<(m-i-1))
        else :
            q = q
    if x < 0 :
        x = (x + (y<<m)) 
    R = x >> m
    quotient = q 
    remainder = R
    print('quotient             :\n0x{:x}\n'.format(quotient))
    print('remainder            :\n0x{:x}\n'.format(remainder))

#algorithm : 基于Knuth大数除法的西电硕士论文： 一种基于verilog的大整数除法器的实现 - 2015 写的有点问题还
def Knuth_division(x, y):
    b = 64
    b_max = 2**b
    n = 2048 // b
    m = (4096 // b) - n

    q_tem = []
    q = 0
    p = 0
    quotient = 0
    while (y>>(2048-b)) < (b_max/2) :
        x = x << 1
        y = y << 1
    y1 = y >> (2048-b)
    for(i) in range(0,m,1):
        q_tem.append(0)
        if (x >> (4096-b*(i+1)))&(b_max-1) == (y >> (2048-b*(i+1)))&(b_max-1) :
            q_tem[i] = b_max - 1
        else :
            q_tem[i] = (((x>>(4096-b*(i+1)))&(b_max-1))*b_max-((x>>(4096-b*(i+2)))&(b_max-1))) // ((y >> (2048-b*(1)))&(b_max-1))
        print('q_tem                :\n0x{:x}\n'.format(q_tem[i]))
        p = q_tem[i] * y
        # print('p                    :\n0x{:x}\n'.format(p))
        for(j) in range(0,2,1):
            x_shift_value = (x >> ((n - i - 1)*b)) & (2**((n+1)*b)-1)
            print('p                :\n0x{:x}\n'.format(p))
            print('x                :\n0x{:x}\n'.format(x))
            print('x_shift_value    :\n0x{:x}\n'.format(x_shift_value))
            if p  > x_shift_value :#p>[x0-xn]
                # print('p                :\n0x{:x}\n'.format(p))
                # print('x                :\n0x{:x}\n'.format(x))
                # print('x_shift_value    :\n0x{:x}\n'.format(x_shift_value))
                q_tem[i] = q_tem[i] - 1
                p = p - y
        x = x - (p<<((m-1-i)*b))
    for i in range(0,m,1):
        quotient = quotient + (q_tem[i] << ((n-1-i)*b))
    print('quotient             :\n0x{:x}\n'.format(quotient))

    # right value of quotient 0xb291bdfd051365546581c6824136e0ec65d75545cd25dddec707d4321ccf5c5dedf6b2893d34816d52717085f4a4be6c81b6236a968858a44ff49b70cb104d7cc9cbbade29ce3f515049d6fe19c03eebd16a7875365210493e68ba6ac0d865c0a4f7ef62d323c9e19c5a42b7c0e09b8282c18dc91155c76455d46c46771aa1814858944e9451d277dc9908bbb5dcd603b0ae7f5350de885fd66fd4950307942420d8a3973d06450b9c1d664e560fb317685e99f056f70220101ea8f6ba1091e8cfdc131c601f4a67d86dbb15895d5fba887ea7ea982c275b8efc1d5854f3d121014d1fdc9211f9930f2b630731379108682e2abc53c71b8611a8e6b23f430bdd
    # result of quotient 0xb291bdfd051365546581c6824136e0ec65d75545cd25dddd8fac237b69fd7136d756be3c3768f0cc10bca8ecdaf29d9420093e26fb587ab4829abee3df33ff83f1680d3d008e84909de0e15f18f22c03f5697f2017378cbbecc429e7d58ec772e482e75b981c729afb3cfd067a11cda112aec1c3a17f7ffc18890d1a3f328fc3b47fdf5b12a7cad4b17e99d3de4436f730b8261af29e8553367b4a59207b4e64399fb4c931aed6df6a939d2697c9fa6d7334bdd231cf59601718a4225cd531a1e3a981c69a3cf7cd8c2b00310c1f1866ff73759544785bb433a251289743f2802d5aedf4f79cbd422f5e5ccd263ddccc71ac5da12bbb4238710e7be0e175fe2b
    # p                :
    # 0x7620c9157a1030b72f4aaf43fed7d78e3f8ef6444db98e1abf6491d06fc73fa82582597f8af90a993e280c0f7a32de83a53cfe87eb6e80db61f9d2ba3e453a6a54abad77fd53f81a02b102116d22070299e52be75c18c07ead10498738d85b27d0d0d2a547388db7fdc4179fabee3a9979e6aeff770d105d2e831262d5191ab8fa575deacdade34185ce258b9a7c8217d1ceb1747814b28b0613163d6d9c2eec35b3e6285e6a48a40a581b9e94c57c8f99943c9c6ce36f088f8d5c40e6771cbe94140e9ba2a0f7359226bb64ccdb9f7193ef1f4a8917483c10e1a9b456b46f24f8780a7e049d316e410008beb106955b1a6250a9dd7c94eefcf6e68c8b974685743ea13d4936c7f1

    # x                :
    # 0x17620c9157a1030b70ddc264c06cade7cb2b296e94aac3a23d94845cf6915653633f12bb3f83395bb62782fc60fcf01222c1e383bb2b35b4140851ec887f3c6167cabf67a541403091e7a647e68d200d9dbf00a34c6b966637c98c866289d7bd6d436d4808d5953c74063765df0ab04aa5c7548fd0589569a164489efe71be6ee5bc86297e9d3ebd409699ea366603d2851bf3f15a50bcb9fb0d021125f0b6f2bdfa358a4d447c4d1935068e4eb8ee2b08533faebec35b2fd8cc34e7b54c3d19bcf00869f503ee9b0e0c114aeaa48b2d204e74240fb9c34b00cba0428129edfabbacc2264b00dd9dad8c81aba2c8c92acde9f1a8244871b8b726053ae4a1653c064cce28fb565b99599758f8c8e5d58ce03af202cfe8d88092884f15b5a76578db8bf6a32cf7e2d78a758c60de9e6cf037bd2a6c7d22c670b8b384722fef18a9870588c1368f3c1f82caa709eff78cfdb2a3594bce3977875c0c30e464a5fc136225c7e206ba599b14ec856a9a230bca081331c969774eb112295c0670d4cb20723ceaa02e0ff4879a508052dad14c59f1787572686d68c51eb3ce8f505e141803ec18bc77c4986a7ea1dd24c13c7bb976496361ad38078e2daaf39f049a489793e2b46643b3eb3f168a3ad29eb4accb4ca422e7dd70e809f4ad5ed15d295f6765773bb5d851b3e81

    # x_shift_value    :
    # 0x7620c9157a1030b70ddc264c06cade7cb2b296e94aac3a23d94845cf6915653633f12bb3f83395bb62782fc60fcf01222c1e383bb2b35b4140851ec887f3c6167cabf67a541403091e7a647e68d200d9dbf00a34c6b966637c98c866289d7bd6d436d4808d5953c74063765df0ab04aa5c7548fd0589569a164489efe71be6ee5bc86297e9d3ebd409699ea366603d2851bf3f15a50bcb9fb0d021125f0b6f2bdfa358a4d447c4d1935068e4eb8ee2b08533faebec35b2fd8cc34e7b54c3d19bcf00869f503ee9b0e0c114aeaa48b2d204e74240fb9c34b00cba0428129edfabbacc2264b00dd9dad8c81aba2c8c92acde9f1a8244871b8b726053ae4a1653c064cce28fb565b995

def phrnd_optimize_division(x,y):
    n = 4096
    m = 2048
    x_high_2048 = k_w(x >> (n-m),m)
    x_low_2048 = k_w(x,n-m)
    x_high_2048 = x_high_2048 - y
    for(i) in range(0,n-m,1):
        x_high_2048 = k_w(x_high_2048 << 1,m) + k_w(x_low_2048 >> (n-m-1-i),1)
        x_new = (x_high_2048 << (n-m)) + x_low_2048
        if  x_new > 0:
            x_high_2048 = x_high_2048 - y
            x_low_2048 = x_low_2048 | (1<<(n-m-1-i))
        else:
            x_high_2048 = x_high_2048 + y
            x_low_2048 = x_low_2048 & ((2**2048-1) - (1<<(n-m-1-i)))
    x_new = (x_high_2048 << (n-m)) + x_low_2048
    if  x_new < 0:
        x_high_2048 = x_high_2048 + y
    x_new = (x_high_2048 << (n-m)) + x_low_2048
    quotient = k_w(x_new,2048)
    remainder =k_w(x_high_2048,2048)
    print('quotient             :\n0x{:x}\n'.format(quotient))
    print('remainder            :\n0x{:x}\n'.format(remainder))

def modular_division():
    print('modular_division-----------------------------------------------------------------')
    x =  0x92d20837163355491353a40bfbed6afffb000939ca99e2dcb7e96c94d9e6ff1b54db47d62fa87283db4ef47e8119e2cb0d126f44ef110cd64d6493014fbee11fce25ad01515ed88bef11f595cc5b107aed44c3aecf42318a0e9dc2431934703c219abc2ee926037fbd46e2b2465b19b3110e3ccdbdfbe0daadefe22a725ef38bc2371fdc5e9cfb439ea6ac84b3e424e71cc3a263dc8cb4642042d01abe4e54416d821fae3e588950e16d5bdc76fc0629b4829eabad9ad1535fc322dc0ad791ca8a353157ab771cc0eafb621a07b0ce0998a65541754ffeedb756ff3ca3b606dea2b63fa2483a5dda07c17496f556f441e4c09fbb079cbbb8279c01fca24b56bf32e9902603d670439cee8a4f9730281ca7e736783300f69b64cce28fb565b99599758f8c8e5d58ce03af202cfe8d88092884f15b5a76578db8bf6a32cf7e2d78a758c60de9e6cf037bd2a6c7d22c670b8b384722fef18a9870588c1368f3c1f82caa709eff78cfdb2a3594bce3977875c0c30e464a5fc136225c7e206ba599b14ec856a9a230bca081331c969774eb112295c0670d4cb20723ceaa02e0ff4879a508052dad14c59f1787572686d68c51eb3ce8f505e141803ec18bc77c4986a7ea1dd24c13c7bb976496361ad38078e2daaf39f049a489793e2b46643b3eb3f168a3ad29eb4accb4ca422e7dd70e809f4ad5ed15d295f6765773bb5d851b3e81
    y = 0xD27BF9F01E2A901DB957879F45F697330D21A21095DA4FA7D3AAB75454A8E9F0F4EA531ECE34F0C3BA9E02EB27D8F0DBE78EEDE4AC84061BEEF162D00B55C0DD772D28F23E994899AA19B9BEA7B12A8027A32A92190A3630E249544675488121565A23548FCD36F5382EEB993DB9CE3F526F20AB355E82D963D59541BC1161E211A03E3B372560840C57E12BD2F40EAC5FFCEC01B3F07C378C0A60B74BEF7B572764C88A4F98B61FA8CCD905AFAE779E6193378304D8EB17695CE71A173AC3DE11271753C48DB58546E5AF9917C1CEBBA5BB1AF3FCE3DF9516C0C95C9BC14BB65D1C53078C06C81AC0F3ED0D8634260E47BF780CF4F4996084DF732935194417
    quotient = x // y 
    remainder = x % y
    print('quotient             :\n0x{:x}\n'.format(quotient))
    print('remainder            :\n0x{:x}\n'.format(remainder))

    # phrnd(x,y)
    phrnd_optimize_division(x, y)




if __name__=='__main__':
    modular_division()

