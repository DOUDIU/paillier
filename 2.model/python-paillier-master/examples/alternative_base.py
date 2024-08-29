#!/usr/bin/env python3.4
import math
import random

import phe.encoding
from phe import paillier

def display_keys(public_key, private_key):
    # print("-----------------------------------------------------------")
    # public_key, private_key = paillier.generate_paillier_keypair(None, 4096)
    print("-----------------------------------------------------------")
    print('n=0x{:x}\n'.format(public_key.n))
    print('nsquare=0x{:x}\n'.format(public_key.nsquare))
    print('g=0x{:x}\n'.format(public_key.g))
    print("-----------------------------------------------------------")
    print('q=0x{:x}\n'.format(private_key.q))
    print('p=0x{:x}\n'.format(private_key.p))
    print('p*q=0x{:x}\n'.format(private_key.p * private_key.q))
    print("-----------------------------------------------------------")

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
    print('\n',file=RESULT_LOG)

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

def data_seperate_printf_byte(data,nbit,n,order):#0 reverse,1 normal
    RESULT_LOG = open("result_log.txt",'a',encoding="utf-8")
    if order==0:
        for i in range(n):
            print('{:x}'.format(data>>(i*nbit)&(2**nbit-1)),end='\n',file=RESULT_LOG)
    else:
        for i in range(n-1,-1,-1):
            print('{:x}'.format(data>>(i*nbit)&(2**nbit-1)),end='\n',file=RESULT_LOG)

def data_whole_printf(data,file_name):#0 reverse,1 normal
    RESULT_LOG = open(file_name,'a',encoding="utf-8")
    print('{:x} '.format(data),end='\n',file=RESULT_LOG)

class ExampleEncodedNumber(phe.encoding.EncodedNumber):
    BASE = 64
    LOG2_BASE = math.log(BASE, 2)


print("Generating paillier keypair")
# public_key, private_key = paillier.generate_paillier_keypair(None,2048)
# display_keys(public_key, private_key)
n=0xc1df05419c6057e26ebad2d3abd7123cdd612c4cf0c09d1881f83b3ea46ad2f1239e21d0a3a778cfbfa9f4f46a0f355c3c57d0305706482133aa5b0aa7d961798442d0c0a2d7fd48359690c361c66fa0dc7131e9dcf83e11cab3812b22861546a5be250c5ab7d671d5e6129b0ef708e105d2d0ed5bde948bf5c4339c0d7e45b9c3ac4ef3c50af15fbd37492f126c5a518af725228255ab1b6ecab2f668149e3ff74e3cd371e7fadf3edb24476ca0632fa53d0af0840ed39b736a5f08339a21e35a53aa612f73dabd6864bf2dc85b296b4e2a2bddcdabdae21b8c938d1c95d3278213cc126746497a511d8d29aea5ac13d2c5de79b62fb1a1a8e12114c110a8bf
q=0xe40930748c4cc8fe2bf3b56c194415fd1e08df9e174bf74ecc089960fa48143c64fdfeeae3dd9a9fc7932dd676d4110f7be0755d4a8a31f02252f084be03511ff5fd781f17e17dc6c530053829b2b4eab676ed7b9494b822063b4cb912eb3662c873081b60a5376f4ba17c10b3aec703802b4b437c8c6201a3ef1f6ad26ca7a9
p=0xd9a5494352130cb1e50bf14a4d7526d3f341ecaec20771cf0246364aaf97a3c02648abf5f5e927e97dcc8485aabc7139181c9edeb65370174f83e09a818bd0bb2e98a30e1ff8b94655fcd0867d7ab4cd714822085245cf4cb0de82966240856658d3903fc8cd6b5901716c3573ec02c62235ada01abc98b9f9b54a4c9004ee27
public_key = paillier.PaillierPublicKey(n)
private_key = paillier.PaillierPrivateKey(public_key, p, q)


def encode_and_encrypt_example():
    print("Encoding a large positive number. With a BASE {} encoding scheme".format(ExampleEncodedNumber.BASE))
    encoded = ExampleEncodedNumber.encode(public_key, 2.1 ** 20)
    print("Checking that decoding gives the same number...")
    assert 2.1 ** 20 == encoded.decode()

    print("Encrypting the encoded number")
    encrypted = public_key.encrypt(encoded)

    print("Decrypting...")
    decrypted_but_encoded = \
        private_key.decrypt_encoded(encrypted, ExampleEncodedNumber)

    print("Checking the decrypted number is what we started with")
    assert abs(2.1 ** 20 - decrypted_but_encoded.decode()) < 1e-12

def mod_inv(a,m):
    if math.gcd(a,m)!=1:
        return None
    u1,u2,u3 = 1,0,a
    v1,v2,v3 = 0,1,m
    while v3!=0:
        q = u3//v3
        v1,v2,v3,u1,u2,u3 = (u1-q*v1),(u2-q*v2),(u3-q*v3),v1,v2,v3
    return u1%m

#(L(c^lamda mod n^2) * mu) mod n
def decrypt_fpga_example( n, lamba, mu, cyphertext):
    inverse_modular = ((p-1)*(q-1)) + n
    n_inverse = mod_inv(public_key.n, inverse_modular)

    result_step1 = paillier.powmod(cyphertext, lamba, n ** 2) - 1
    print('result_step1: 0x{:x}\n'.format(result_step1))
    result_step2 = paillier.mulmod(result_step1, n_inverse, inverse_modular)
    decrypt_text = paillier.mulmod(result_step2, mu, n)

    while 1:
        a = 1
    # print('optimized decrypion result: 0x\n{:x}'.format(decrypt_text))
    return decrypt_text

#CRT
def decrypt_crt_example( p, q, g,cyphertext):
    """Precomputed"""
    p_inverse = paillier.invert(p, 2 ** p)
    q_inverse = paillier.invert(q, 2 ** q)
    hp=paillier.invert(paillier.mulmod(paillier.powmod(g, p-1, p * p) - 1,p_inverse,2 ** p),  p)
    hq=paillier.invert(paillier.mulmod(paillier.powmod(g, q-1, q * q) - 1,q_inverse,2 ** q),  q)
    """Precomputed"""

    """
    Mp=mulmod(mulmod(powmod(cyphertext, p-1, p * p) - 1, p_inverse, 2 ** p), hp, p)
    Mq=mulmod(mulmod(powmod(cyphertext, q-1, q * q) - 1, q_inverse, 2 ** q), hq, q)
    u = mulmod(Mq - Mp, p_inverse, q)
    decrypt_text = Mp + (u * p)
    """
    decrypt_text = paillier.mulmod(paillier.mulmod(paillier.powmod(cyphertext, p-1, p * p) - 1, p_inverse, 2 ** p), hp, p)  +  (paillier.mulmod(paillier.mulmod(paillier.mulmod(paillier.powmod(cyphertext, q-1, q * q) - 1, q_inverse, 2 ** q), hq, q) - paillier.mulmod(paillier.mulmod(paillier.powmod(cyphertext, p-1, p * p) - 1, p_inverse, 2 ** p), hp, p), p_inverse, q))

    return decrypt_text

#(L(c^lamda mod n^2) * mu) mod n
def decrypt_example():
    RESULT_LOG = open("result_log.txt",'w').close()
    # print("Encoding a large positive number. With a BASE {} encoding scheme".format(ExampleEncodedNumber.BASE))
    # original_data = random.SystemRandom().randrange(1, n//3)
    original_data = 102545 + (64 ** 8)
    # print("original data: 0x\n{:x}".format(original_data))
    encoded = ExampleEncodedNumber.encode(public_key, original_data)

    # print("Encrypting the encoded number")
    encrypted = public_key.encrypt(encoded)

    # print("Decrypting...")
    decrypted_but_encoded = private_key.decrypt_encoded(encrypted, ExampleEncodedNumber)

    lamda = math.lcm(private_key.p - 1, private_key.q - 1)
    mu = paillier.invert(lamda, public_key.n)

    # file_path = '1.RTL/data/ram_lamda.txt'
    # data_seperate_printf_new(lamda,128,4096//128,0,file_path)
    # file_path = '1.RTL/data/ram_mu.txt'
    # data_seperate_printf_new(mu,128,4096//128,0,file_path)
    # file_path = '1.RTL/data/ram_N.txt'
    # data_seperate_printf_new(public_key.n,128,4096//128,0,file_path)

    # data_seperate_printf(lamda,128, 4096//128,1)
    # data_seperate_printf(mu,128, 4096//128,1)
    # data_seperate_printf(encrypted.ciphertext(False),128, 4096//128,1)

    enc_ciphertext = 0x2d46fce2a9a239735393f40689a3de6c2a7d72710510a6e96e1c05f70b07c020a6d3722b3bc964e7e380fb7c6a5f5105f4dd8de256af6bf7397ca64b2beb57f4c766ca4e0a9dbcdb7bf02f238e6274a36477a9f69f7e4696187b755e7280039d906e3f53a3f724a1c6c4d7566cce7bde3e36e2651e9cbcf90aac31bf7342a57c65766defb6c504e928df700aaad3700490a942d8589a87bd8a592b8b50b2ed947bc2268448f80073d1590746f897fd89f47d4c20c24a11d112ed6408ecc6168c18e5f4dc586d61fc440b3742de816e2b3e7f28e338849fd6b5a56f57751ec4f0ad24eecf286b5e1ee037bbb0b35f735d18dfa24fab9a2083b50f329fc9b0638280d06001753efaf62521c9cfe8488ad91dcb932843789273609e88aef2a941df49a5b56c9cec3f40ee7eda1678490db6099ee8087c1fbd877aefde8b54d034f3b044fc897670b453871db2ea47efb8d62be1592d34ce44351a9e0e0f065ac5cdc4cf44af5542941bf4d96b9bf2b31e37cafdf5373b8c11a7d3907c8fff7e7d2ced30a3ef89305acc7e1beb513b3cdb212f243109555b6b4be5a548063c0c88a866786e25e26da72bc94331b6506d17f77a7266c7303bf1596fd4603cbbaae24e6c150a8e9ffe4bc1c4ea66d3c60ce01c13b0d6d27b5e99a57e7d28c7fdd1db1af26e7771fd0425a0a4e6cdfd11c2f7dbc82c5c674fe9b19f3b7edac8e9fd6f16
    data_seperate_printf(enc_ciphertext,128, 4096//128,1)

    a = paillier.powmod(enc_ciphertext, lamda, public_key.nsquare)
    b = (a - 1) // public_key.n
    c = b * mu % public_key.n
    # print("Decrypted: 0x{:x}".format(c))
    # print('official decrypted: 0x{:x}'.format(decrypted_but_encoded.decode()))

    opt_dec_result = decrypt_fpga_example(public_key.n, lamda, mu, enc_ciphertext)

    assert c == decrypted_but_encoded.decode()
    assert c == opt_dec_result, "c = 0x{:x}\n opt = 0x{:x}\n".format(c, opt_dec_result)

    # print("Checking the decrypted number is what we started with")
    # assert abs(original_data - decrypted_but_encoded.decode()) < 1e-12

#(g**m * r**n) mod n**2
def encrypt_fpga_example():
    print("Encoding single large positive numbers. BASE={}".format(ExampleEncodedNumber.BASE))
    
    print('Public_key nsquare=0x{:x}\n'.format(public_key.nsquare))

    a = 102545 + (64 ** 8)
    r = 123 + (8 ** 20)#ramdom number

    # RESULT_LOG = open("result_log.txt",'w').close()
    # data_seperate_printf(public_key.nsquare,128, 4096//128,1)
    # data_seperate_printf(public_key.n,128, 4096//128,1)
    # data_seperate_printf(a,128, 4096//128,1)
    # data_seperate_printf(r,128, 4096//128,1)

    encoded_a = ExampleEncodedNumber.encode(public_key, a)

    print("Checking that decoding gives the same number...")
    assert a == encoded_a.decode()

    print("Encrypting the encoded numbers")
    encrypted_a = public_key.encrypt(encoded_a,None,r)
    # verification
    ciphertext_confirm = paillier.mulmod(paillier.powmod(public_key.g, a, public_key.nsquare) , paillier.powmod(r, public_key.n, public_key.nsquare) , public_key.nsquare)
    print('ciphertext_confirm: 0x{:x}\n'.format(ciphertext_confirm))
    print('\ng**m: 0x{:x}\n'.format(paillier.powmod(public_key.g, a, public_key.nsquare)))
    print('\nr**n: 0x{:x}\n'.format(paillier.powmod(r, public_key.n, public_key.nsquare)))

    decrypted_but_encoded = private_key.decrypt_encoded(encrypted_a, ExampleEncodedNumber)
    print("Decrypted: {}".format(decrypted_but_encoded.decode()))
    assert a == decrypted_but_encoded.decode()

#((1+m*n) * r**n) mod n**2
def encrypt_fpga_v1_example(file_name_m,file_name_r,file_name_encrypted):
    print("Encoding single large positive numbers. BASE={}".format(ExampleEncodedNumber.BASE))
    
    a = random.SystemRandom().randrange(1, n//3)
    r = random.SystemRandom().randrange(1, n//3)

    data_whole_printf(a,file_name_m)
    data_whole_printf(r,file_name_r)

    encoded_a = ExampleEncodedNumber.encode(public_key, a)

    print("Checking that decoding gives the same number...")
    assert a == encoded_a.decode()
    print("Encrypting the encoded numbers")
    encrypted_ciphertext = paillier.mulmod(paillier.mulmod(public_key.n, a, public_key.nsquare) + 1 , paillier.powmod(r, public_key.n, public_key.nsquare) , public_key.nsquare)
    data_whole_printf(encrypted_ciphertext,file_name_encrypted)
    encrypted_a = paillier.EncryptedNumber(public_key, encrypted_ciphertext)

    decrypted_but_encoded = private_key.decrypt_encoded(encrypted_a, ExampleEncodedNumber)
    assert a == decrypted_but_encoded.decode()

def homomorphic_addition_example(file_name_a,file_name_b,file_name_homomorphic_addition):
    print("Encoding two large positive numbers. BASE={}".format(ExampleEncodedNumber.BASE))

    a = random.SystemRandom().randrange(1, n//3)
    b = random.SystemRandom().randrange(1, n//3)
    r = random.SystemRandom().randrange(1, n//3)

    encoded_a = ExampleEncodedNumber.encode(public_key, a)
    encoded_b = ExampleEncodedNumber.encode(public_key, b)

    print("Checking that decoding gives the same number...")
    assert a == encoded_a.decode()
    assert b == encoded_b.decode()

    print("Encrypting the encoded numbers")
    encrypted_a = public_key.encrypt(encoded_a,None,r)
    encrypted_b = public_key.encrypt(encoded_b,None,r)

    data_whole_printf(encrypted_a.ciphertext(False),file_name_a)
    data_whole_printf(encrypted_b.ciphertext(False),file_name_b)

    print("Adding the encrypted numbers")
    encrypted_c = encrypted_a + encrypted_b #EncryptedNumber: E(a + b), calculated by taking the product of E(a) and E(b) modulo n` ** 2
    data_whole_printf(encrypted_c.ciphertext(False),file_name_homomorphic_addition)

    print("Decrypting the one encrypted sum")
    decrypted_but_encoded = private_key.decrypt_encoded(encrypted_c, ExampleEncodedNumber)

    print("Checking the decrypted number is what we started with")
    # assert abs((a + b) - decrypted_but_encoded.decode()) < 1e-15
    assert abs((a + b) - decrypted_but_encoded.encoding) < 1e-15 #Not verifying that the decoded number surpasses n // 3

def scalar_postive_multiplication_example(file_name_m,file_name_c,file_name_result):
    print("Encoding a large positive number. BASE={}".format(ExampleEncodedNumber.BASE))

    # a = 102545 + (64 ** 8)
    # const_scalar = 34+(11**3)
    # r = 123 + (8 ** 20) #ramdom number

    a = random.SystemRandom().randrange(1, (n//3)>>1024)
    const_scalar = random.SystemRandom().randrange(1, (n//3)>>1024)
    r = random.SystemRandom().randrange(1, n//3)

    encoded_a = ExampleEncodedNumber.encode(public_key, a)

    print("Checking that decoding gives the same number...")
    assert a == encoded_a.decode()

    print("Encrypting the encoded number")
    encrypted_a = public_key.encrypt(encoded_a,None,r)
    data_whole_printf(encrypted_a.ciphertext(False),file_name_m)
    data_whole_printf(const_scalar,file_name_c)

    print("Multiplying the encrypted number by a scalar")
    encrypted_b = const_scalar * encrypted_a #EncryptedNumber: E(a * scalar), calculated by taking the power exponent of E(a) and scalar modulo n` ** 2
    data_whole_printf(encrypted_b.ciphertext(False),file_name_result)

    # print('encrypted_b: 0x{:x}\n'.format(encrypted_b.ciphertext(False)))
    # print('encrypted_b_verification: 0x{:x}\n'.format(paillier.powmod(encrypted_a.ciphertext(False), const_scalar, public_key.nsquare)))

    print("Decrypting the one encrypted sum")
    decrypted_but_encoded = private_key.decrypt_encoded(encrypted_b, ExampleEncodedNumber)

    print("Checking the decrypted number is what we started with")
    assert abs((a * const_scalar) - decrypted_but_encoded.decode()) < 1e-15

# (inv(c, n^2) ** (-const_scalar)) mod n^2
def scalar_negative_multiplication_example():
    print("Encoding a large positive number. BASE={}".format(ExampleEncodedNumber.BASE))

    a = 102545 + (64 ** 8)
    const_scalar = -(34+(11**3))
    r = 123 + (8 ** 20) #ramdom number

    encoded_a = ExampleEncodedNumber.encode(public_key, a)

    print("Checking that decoding gives the same number...")
    assert a == encoded_a.decode()

    print("Encrypting the encoded number")
    encrypted_a = public_key.encrypt(encoded_a,None,r)

    print("Multiplying the encrypted number by a scalar")
    ciphertext_a = encrypted_a.ciphertext(False)
    ciphertext_a_inv = paillier.invert(ciphertext_a, public_key.nsquare)
    scalar_negative_multiplication = paillier.powmod(ciphertext_a_inv , -const_scalar, public_key.nsquare)
    print("Homomorphic multiplication: 0x{:x}\n".format(scalar_negative_multiplication))
    
    print("Decrypting the one encrypted sum")
    encrypted_a = paillier.EncryptedNumber(public_key, scalar_negative_multiplication)
    decrypted_but_encoded = private_key.decrypt_encoded(encrypted_a, ExampleEncodedNumber)
    print("Decrypted: 0x{:x}".format(decrypted_but_encoded.encoding))

    print("Checking the decrypted number is what we started with")
    assert abs((a * const_scalar) - decrypted_but_encoded.decode()) < 1e-15

def data_record_for_encryption(file_name_m,file_name_r,file_name_encrypted,counts):
    RESULT_LOG = open(file_name_m,'w').close() #clear the file
    RESULT_LOG = open(file_name_r,'w').close() #clear the file
    RESULT_LOG = open(file_name_encrypted,'w').close() #clear the file
    for i in range(counts):
        encrypt_fpga_v1_example(file_name_m,file_name_r,file_name_encrypted)

def data_record_for_homomorphic_addition(file_name_a,file_name_b,file_name_homomorphic_addition,counts):
    RESULT_LOG = open(file_name_a,'w').close() #clear the file
    RESULT_LOG = open(file_name_b,'w').close() #clear the file
    RESULT_LOG = open(file_name_homomorphic_addition,'w').close() #clear the file
    for i in range(counts):
        homomorphic_addition_example(file_name_a,file_name_b,file_name_homomorphic_addition)

def data_record_for_scalar_postive_multiplication(file_name_m,file_name_c,file_name_result,counts):
    RESULT_LOG = open(file_name_m,'w').close() #clear the file
    RESULT_LOG = open(file_name_c,'w').close() #clear the file
    RESULT_LOG = open(file_name_result,'w').close() #clear the file
    for i in range(counts):
        scalar_postive_multiplication_example(file_name_m,file_name_c,file_name_result)

if __name__ == "__main__":
    # data_record_for_encryption("../5.data/result_enc_m.txt","../5.data/result_enc_r.txt","../5.data/result_enc_encrypted.txt",10)
    # data_record_for_homomorphic_addition("../5.data/homomorphic_addition_a.txt","../5.data/homomorphic_addition_b.txt","../5.data/homomorphic_addition_result.txt",10)
    # data_record_for_scalar_postive_multiplication("../5.data/scalar_postive_multiplication_m.txt","../5.data/scalar_postive_multiplication_const.txt","../5.data/scalar_postive_multiplication_result.txt",10)

    # for i in range(1000):
        decrypt_example()
