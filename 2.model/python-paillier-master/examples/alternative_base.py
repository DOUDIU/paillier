#!/usr/bin/env python3.4
import math

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
    print('\n')

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

#(g**m * r**n) mod n**2
def encrypt_fpga_example():
    print("Encoding single large positive numbers. BASE={}".format(ExampleEncodedNumber.BASE))
    
    print('Public_key nsquare=0x{:x}\n'.format(public_key.nsquare))

    a = 102545 + (64 ** 8)
    r = 123 + (8 ** 20)#ramdom number

    RESULT_LOG = open("result_log.txt",'w').close()
    data_seperate_printf(public_key.nsquare,128, 4096//128,1)
    data_seperate_printf(public_key.n,128, 4096//128,1)
    data_seperate_printf(a,128, 4096//128,1)
    data_seperate_printf(r,128, 4096//128,1)

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
def encrypt_fpga_v1_example():
    print("Encoding single large positive numbers. BASE={}".format(ExampleEncodedNumber.BASE))
    
    print('Public_key nsquare=0x{:x}\n'.format(public_key.nsquare))

    a = 102545 + (64 ** 8)
    r = 123 + (8 ** 20)#ramdom number

    RESULT_LOG = open("result_log.txt",'w').close()
    data_seperate_printf(public_key.nsquare,128, 4096//128,1)
    data_seperate_printf(public_key.n,128, 4096//128,1)
    data_seperate_printf(a,128, 4096//128,1)
    data_seperate_printf(r,128, 4096//128,1)

    encoded_a = ExampleEncodedNumber.encode(public_key, a)

    print("Checking that decoding gives the same number...")
    assert a == encoded_a.decode()
    print("Encrypting the encoded numbers")
    encrypted_ciphertext = paillier.mulmod(paillier.mulmod(public_key.n, a, public_key.nsquare) + 1 , paillier.powmod(r, public_key.n, public_key.nsquare) , public_key.nsquare)
    print('ciphertext_confirm: 0x{:x}\n'.format(encrypted_ciphertext))
    print('\n1+m*n: 0x{:x}\n'.format(paillier.mulmod(public_key.n, a, public_key.nsquare)+1))
    print('\nr**n : 0x{:x}\n'.format(paillier.powmod(r, public_key.n, public_key.nsquare)))
    encrypted_a = paillier.EncryptedNumber(public_key, encrypted_ciphertext)

    decrypted_but_encoded = private_key.decrypt_encoded(encrypted_a, ExampleEncodedNumber)
    print("Decrypted: {}".format(decrypted_but_encoded.decode()))
    assert a == decrypted_but_encoded.decode()

def homomorphic_addition_example():
    print("Encoding two large positive numbers. BASE={}".format(ExampleEncodedNumber.BASE))

    a = 102545 + (64 ** 8)
    b = 123 + (8 ** 20)
    r = 123 + (8 ** 20) #ramdom number

    encoded_a = ExampleEncodedNumber.encode(public_key, a)
    encoded_b = ExampleEncodedNumber.encode(public_key, b)

    print("Checking that decoding gives the same number...")
    assert a == encoded_a.decode()
    assert b == encoded_b.decode()

    print("Encrypting the encoded numbers")
    encrypted_a = public_key.encrypt(encoded_a,None,r)
    encrypted_b = public_key.encrypt(encoded_b,None,r)

    print("Adding the encrypted numbers")
    encrypted_c = encrypted_a + encrypted_b #EncryptedNumber: E(a + b), calculated by taking the product of E(a) and E(b) modulo n` ** 2
    print('encrypted_c: 0x{:x}\n'.format(encrypted_c.ciphertext(False)))
    print('encrypted_c_verification: 0x{:x}\n'.format(paillier.mulmod(encrypted_a.ciphertext(False), encrypted_b.ciphertext(False), public_key.nsquare)))

    print("Decrypting the one encrypted sum")
    decrypted_but_encoded = private_key.decrypt_encoded(encrypted_c, ExampleEncodedNumber)

    print("Checking the decrypted number is what we started with")

    print("Decrypted: {}".format(decrypted_but_encoded.decode()))
    assert abs((a + b) - decrypted_but_encoded.decode()) < 1e-15

def scalar_postive_multiplication_example():
    print("Encoding a large positive number. BASE={}".format(ExampleEncodedNumber.BASE))

    a = 102545 + (64 ** 8)
    const_scalar = 34+(11**3)
    r = 123 + (8 ** 20) #ramdom number

    encoded_a = ExampleEncodedNumber.encode(public_key, a)

    print("Checking that decoding gives the same number...")
    assert a == encoded_a.decode()

    print("Encrypting the encoded number")
    encrypted_a = public_key.encrypt(encoded_a,None,r)

    print("Multiplying the encrypted number by a scalar")
    encrypted_b = const_scalar * encrypted_a

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

if __name__ == "__main__":
    scalar_negative_multiplication_example()
