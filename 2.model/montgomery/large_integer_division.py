

def modular_diversion():
    print('modular_diversion-----------------------------------------------------------------')
    x =  0x92d20837163355491353a40bfbed6afffb000939ca99e2dcb7e96c94d9e6ff1b54db47d62fa87283db4ef47e8119e2cb0d126f44ef110cd64d6493014fbee11fce25ad01515ed88bef11f595cc5b107aed44c3aecf42318a0e9dc2431934703c219abc2ee926037fbd46e2b2465b19b3110e3ccdbdfbe0daadefe22a725ef38bc2371fdc5e9cfb439ea6ac84b3e424e71cc3a263dc8cb4642042d01abe4e54416d821fae3e588950e16d5bdc76fc0629b4829eabad9ad1535fc322dc0ad791ca8a353157ab771cc0eafb621a07b0ce0998a65541754ffeedb756ff3ca3b606dea2b63fa2483a5dda07c17496f556f441e4c09fbb079cbbb8279c01fca24b56bf32e9902603d670439cee8a4f9730281ca7e736783300f69b64cce28fb565b99599758f8c8e5d58ce03af202cfe8d88092884f15b5a76578db8bf6a32cf7e2d78a758c60de9e6cf037bd2a6c7d22c670b8b384722fef18a9870588c1368f3c1f82caa709eff78cfdb2a3594bce3977875c0c30e464a5fc136225c7e206ba599b14ec856a9a230bca081331c969774eb112295c0670d4cb20723ceaa02e0ff4879a508052dad14c59f1787572686d68c51eb3ce8f505e141803ec18bc77c4986a7ea1dd24c13c7bb976496361ad38078e2daaf39f049a489793e2b46643b3eb3f168a3ad29eb4accb4ca422e7dd70e809f4ad5ed15d295f6765773bb5d851b3e81
    y = 0xD27BF9F01E2A901DB957879F45F697330D21A21095DA4FA7D3AAB75454A8E9F0F4EA531ECE34F0C3BA9E02EB27D8F0DBE78EEDE4AC84061BEEF162D00B55C0DD772D28F23E994899AA19B9BEA7B12A8027A32A92190A3630E249544675488121565A23548FCD36F5382EEB993DB9CE3F526F20AB355E82D963D59541BC1161E211A03E3B372560840C57E12BD2F40EAC5FFCEC01B3F07C378C0A60B74BEF7B572764C88A4F98B61FA8CCD905AFAE779E6193378304D8EB17695CE71A173AC3DE11271753C48DB58546E5AF9917C1CEBBA5BB1AF3FCE3DF9516C0C95C9BC14BB65D1C53078C06C81AC0F3ED0D8634260E47BF780CF4F4996084DF732935194417
    quotient = x // y 
    remainder = x % y
    print('quotient             :\n0x{:x}\n'.format(quotient))
    print('remainder            :\n0x{:x}\n'.format(remainder))

    #algorithm : Parallel high-radix nonrestoring division - 1993
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

    #algorithm : 西电硕士论文： 一种基于verilog的大整数除法器的实现 - 2015
    


    # x_high_2048 = x >> 2048
    # x_low_2048 = x & (2^2048-1)
    # x_high_2048 = x_high_2048 - y
    # for(i) in range(0,4096-2048,1):
    #     x_high_2048 = (x_high_2048 << (1+2048-i)) + (x_low_2048 & (2^(2048-i)-1))
    #     if x_high_2048 > 0:
    #         x_high_2048 = x_high_2048 - y
    #         x_low_2048 = (x_low_2048 >> (2048-i)) << (2048-i) + 1
    #     else:
    #         x_high_2048 = x_high_2048 + y
    #         x_low_2048 = (x_low_2048 >> (2048-i)) << (2048-i) + 0

    # if x_high_2048 < 0:
    #     x_high_2048 = x_high_2048 + y
    # quotient = x_high_2048 & (2^2048-1)
    # remainder = x_low_2048 & (2^2048-1)
    # print('quotient             :\n0x{:x}\n'.format(quotient))
    # print('remainder            :\n0x{:x}\n'.format(remainder))


if __name__=='__main__':
    modular_diversion()


