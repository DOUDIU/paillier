import binascii
import os

COMPARE_COUNTS = 100000

def hex_data_to_bin_file(txt_file_path, bin_file_path):
    with open(txt_file_path, 'r') as txt_file:
        hex_data_list = txt_file.readlines()

    with open(bin_file_path, 'wb') as bin_file:
        for hex_data in hex_data_list:
            hex_data = hex_data.strip(' \n')  # 去掉回车符
            while len(hex_data) < 2048 // 4:  # 2048 位 = 2048 // 4 个十六进制字符
                hex_data = '0' + hex_data
            if len(hex_data) % 2!= 0:  # 如果长度为奇数，去掉最后一个字符
                hex_data = hex_data[:-1]
            try:
                bin_data = binascii.unhexlify(hex_data)
                bin_file.write(bin_data)
            except binascii.Error as e:
                print(f"Error processing data: {hex_data}. Error: {e}")

def convert_endianness(hex_str):
    byte_array = bytearray.fromhex(hex_str)
    reversed_bytes = bytearray(reversed(byte_array))
    return ''.join(f'{b:02x}' for b in reversed_bytes)

def compare_lines(file1_path, file2_path, compare_num=100):
    try:
        with open(file1_path, 'r') as file1, open(file2_path, 'r') as file2:
            for line_num in range(compare_num):
                line1 = file1.readline().strip()
                line2 = file2.readline().strip()
                line2 = line2.lstrip('0')
                if line1!= line2:
                    print(f"Line {line_num + 1} is different: {line1} != {line2}")
                    return False
            return True
    except FileNotFoundError:
        return False

current_directory = './data'
os.chdir('./data')
# current_directory = os.getcwd()
# txt_files = [f for f in os.listdir(current_directory) if f.endswith('.txt')]
# for file in txt_files:
#     print(file)
#     new_file = file.replace('.txt', '.bin')
#     hex_data_to_bin_file(file, new_file)

with open('result_enc.bin', 'rb') as bin_file:
    with open('result_enc_fpga_big_end.txt', 'w') as txt_file:
        for _ in range(COMPARE_COUNTS):
            data = bin_file.read(4096 // 8)
            hex_data = ''.join(f'{byte:02x}' for byte in data)
            txt_file.write(hex_data + '\n')

with open('result_enc_fpga_big_end.txt', 'r') as input_file:
    lines = input_file.readlines()
    big_endian_lines = []
    for line in lines:
        small_endian_hex = line.strip()
        big_endian_hex = convert_endianness(small_endian_hex)
        big_endian_lines.append(big_endian_hex + '\n')

with open('result_enc_fpga_small_end.txt', 'w') as output_file:
    output_file.writelines(big_endian_lines)

file1 = "result_enc_encrypted.txt"
file2 = "result_enc_fpga_small_end.txt"

if compare_lines(file1, file2, COMPARE_COUNTS):
    print("两个文件相同。")
else:
    print("两个文件不相同。")
