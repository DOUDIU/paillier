import math
import random
import gmpy2

import phe.encoding
from phe import paillier

class ExampleEncodedNumber(phe.encoding.EncodedNumber):
    BASE = 64
    LOG2_BASE = math.log(BASE, 2)

n=0xc1df05419c6057e26ebad2d3abd7123cdd612c4cf0c09d1881f83b3ea46ad2f1239e21d0a3a778cfbfa9f4f46a0f355c3c57d0305706482133aa5b0aa7d961798442d0c0a2d7fd48359690c361c66fa0dc7131e9dcf83e11cab3812b22861546a5be250c5ab7d671d5e6129b0ef708e105d2d0ed5bde948bf5c4339c0d7e45b9c3ac4ef3c50af15fbd37492f126c5a518af725228255ab1b6ecab2f668149e3ff74e3cd371e7fadf3edb24476ca0632fa53d0af0840ed39b736a5f08339a21e35a53aa612f73dabd6864bf2dc85b296b4e2a2bddcdabdae21b8c938d1c95d3278213cc126746497a511d8d29aea5ac13d2c5de79b62fb1a1a8e12114c110a8bf
q=0xe40930748c4cc8fe2bf3b56c194415fd1e08df9e174bf74ecc089960fa48143c64fdfeeae3dd9a9fc7932dd676d4110f7be0755d4a8a31f02252f084be03511ff5fd781f17e17dc6c530053829b2b4eab676ed7b9494b822063b4cb912eb3662c873081b60a5376f4ba17c10b3aec703802b4b437c8c6201a3ef1f6ad26ca7a9
p=0xd9a5494352130cb1e50bf14a4d7526d3f341ecaec20771cf0246364aaf97a3c02648abf5f5e927e97dcc8485aabc7139181c9edeb65370174f83e09a818bd0bb2e98a30e1ff8b94655fcd0867d7ab4cd714822085245cf4cb0de82966240856658d3903fc8cd6b5901716c3573ec02c62235ada01abc98b9f9b54a4c9004ee27
public_key = paillier.PaillierPublicKey(n)
private_key = paillier.PaillierPrivateKey(public_key, p, q)

def data_whole_printf(data,file_name):
    RESULT_LOG = open(file_name,'a',encoding="utf-8")
    print('{:x} '.format(data),end='\n',file=RESULT_LOG)


def encrypt_fpga_example(file_name_m,file_name_r,file_name_encrypted):    
    a = random.SystemRandom().randrange(1, n//3)
    r = random.SystemRandom().randrange(1, n//3)

    data_whole_printf(a,file_name_m)
    data_whole_printf(r,file_name_r)

    '''(g**m * r**n) mod n**2'''
    # ciphertext_confirm = paillier.mulmod(paillier.powmod(public_key.g, a, public_key.nsquare) , paillier.powmod(r, public_key.n, public_key.nsquare) , public_key.nsquare)
    '''((1+m*n) * r**n) mod n**2'''
    encrypted_ciphertext = paillier.mulmod(paillier.mulmod(public_key.n, a, public_key.nsquare) + 1 , paillier.powmod(r, public_key.n, public_key.nsquare) , public_key.nsquare)
    data_whole_printf(encrypted_ciphertext,file_name_encrypted)

    encoded_a = ExampleEncodedNumber.encode(public_key, a)
    assert a == encoded_a.decode()
    encrypted_a = paillier.EncryptedNumber(public_key, encrypted_ciphertext)
    decrypted_but_encoded = private_key.decrypt_encoded(encrypted_a, ExampleEncodedNumber)
    assert a == decrypted_but_encoded.decode()

def homomorphic_addition_example(file_name_a,file_name_b,file_name_homomorphic_addition):
    a = random.SystemRandom().randrange(1, n//3)
    b = random.SystemRandom().randrange(1, n//3)
    r = random.SystemRandom().randrange(1, n//3)

    encoded_a = ExampleEncodedNumber.encode(public_key, a)
    encoded_b = ExampleEncodedNumber.encode(public_key, b)
    assert a == encoded_a.decode()
    assert b == encoded_b.decode()

    encrypted_a = public_key.encrypt(encoded_a,None,r)
    encrypted_b = public_key.encrypt(encoded_b,None,r)

    data_whole_printf(encrypted_a.ciphertext(False),file_name_a)
    data_whole_printf(encrypted_b.ciphertext(False),file_name_b)

    encrypted_c = encrypted_a + encrypted_b #EncryptedNumber: E(a + b), calculated by taking the product of E(a) and E(b) modulo n` ** 2
    data_whole_printf(encrypted_c.ciphertext(False),file_name_homomorphic_addition)

    decrypted_but_encoded = private_key.decrypt_encoded(encrypted_c, ExampleEncodedNumber)

    print("Checking the decrypted number is what we started with")
    assert abs((a + b) - decrypted_but_encoded.encoding) < 1e-15 #Not verifying that the decoded number surpasses n // 3

def scalar_postive_multiplication_example(file_name_m,file_name_c,file_name_result):
    a = random.SystemRandom().randrange(1, (n//3)>>1024)
    const_scalar = random.SystemRandom().randrange(1, (n//3)>>1024)
    r = random.SystemRandom().randrange(1, n//3)

    encoded_a = ExampleEncodedNumber.encode(public_key, a)
    assert a == encoded_a.decode()

    encrypted_a = public_key.encrypt(encoded_a,None,r)
    data_whole_printf(encrypted_a.ciphertext(False),file_name_m)
    data_whole_printf(const_scalar,file_name_c)

    encrypted_b = const_scalar * encrypted_a #EncryptedNumber: E(a * scalar), calculated by taking the power exponent of E(a) and scalar modulo n` ** 2
    data_whole_printf(encrypted_b.ciphertext(False),file_name_result)

    decrypted_but_encoded = private_key.decrypt_encoded(encrypted_b, ExampleEncodedNumber)

    assert abs((a * const_scalar) - decrypted_but_encoded.decode()) < 1e-15

def data_record_for_encryption(file_name_m,file_name_r,file_name_encrypted,counts):
    RESULT_LOG = open(file_name_m,'w').close() #clear the file
    RESULT_LOG = open(file_name_r,'w').close() #clear the file
    RESULT_LOG = open(file_name_encrypted,'w').close() #clear the file
    for i in range(counts):
        encrypt_fpga_example(file_name_m,file_name_r,file_name_encrypted)

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
    data_record_for_encryption("../5.data/result_enc_m.txt","../5.data/result_enc_r.txt","../5.data/result_enc_encrypted.txt",10)
    data_record_for_homomorphic_addition("../5.data/homomorphic_addition_a.txt","../5.data/homomorphic_addition_b.txt","../5.data/homomorphic_addition_result.txt",10)
    data_record_for_scalar_postive_multiplication("../5.data/scalar_postive_multiplication_m.txt","../5.data/scalar_postive_multiplication_const.txt","../5.data/scalar_postive_multiplication_result.txt",10)