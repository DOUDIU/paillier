import binascii
import os

COMPARE_COUNTS = 100000

def hex_data_to_bin_file(txt_file_path, bin_file_path, data_length):
    with open(txt_file_path, 'r') as txt_file:
        hex_data_list = txt_file.readlines()

    with open(bin_file_path, 'wb') as bin_file:
        for hex_data in hex_data_list:
            hex_data = hex_data.strip(' \n')
            while len(hex_data) < data_length // 4:
                hex_data = '0' + hex_data
            if len(hex_data) % 2!= 0:
                # hex_data = hex_data[:-1]
                print(f"Data length is not even: {hex_data}")
            try:
                bin_data = binascii.unhexlify(hex_data)
                bin_file.write(bin_data)
            except binascii.Error as e:
                print(f"Error processing data: {hex_data}. Error: {e}")

def convert_endianness(hex_str):
    byte_array = bytearray.fromhex(hex_str)
    reversed_bytes = bytearray(reversed(byte_array))
    return ''.join(f'{b:02x}' for b in reversed_bytes)

def translate_txt_to_bin(srcdir_path, dstdir_path, data_length):
    current_directory = os.getcwd()
    subfolder_file_path = os.path.join(current_directory, srcdir_path)
    txt_files = [f for f in os.listdir(subfolder_file_path) if f.endswith('.txt')]
    for file in txt_files:
        print(file)
        new_file = os.path.join(dstdir_path, file.replace('.txt', '.bin'))
        file = os.path.join(srcdir_path, file)
        hex_data_to_bin_file(file, new_file, data_length)

def bin_data_to_txt_file(src_file, dst_file):
    with open(src_file, 'rb') as bin_file:
        big_endian_lines = []
        for _ in range(COMPARE_COUNTS):
            if "dec" in src_file:
                data = bin_file.read(2048 // 8)
            else:
                data = bin_file.read(4096 // 8)
            small_endian_hex = ''.join(f'{byte:02x}' for byte in data)
            big_endian_hex = convert_endianness(small_endian_hex)
            big_endian_lines.append(big_endian_hex + '\n')

    with open(dst_file, 'w') as output_file:
        output_file.writelines(big_endian_lines)

def translate_bin_to_txt(srcdir_path, dstdir_path):
    current_directory = os.getcwd()
    subfolder_file_path = os.path.join(current_directory, srcdir_path)
    bin_files = [f for f in os.listdir(subfolder_file_path) if f.endswith('.bin')]
    for file in bin_files:
        print(file)
        new_file = os.path.join(dstdir_path, file.replace('.bin', '.txt'))
        file = os.path.join(srcdir_path, file)
        bin_data_to_txt_file(file, new_file)

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

def input_translate():
    srcdir_path_2048 = ".\original_data_txt_2048"
    srcdir_path_4096 = ".\original_data_txt_4096"
    dstdir_path = ".\original_data_bin"
    if not os.path.exists(dstdir_path):
        os.makedirs(dstdir_path)
    translate_txt_to_bin(srcdir_path_2048, dstdir_path, 2048)
    translate_txt_to_bin(srcdir_path_4096, dstdir_path, 4096)

def output_translate():
    srcdir_path = ".\output_data_bin"
    dstdir_path = ".\output_data_txt"
    if not os.path.exists(dstdir_path):
        os.makedirs(dstdir_path)
    translate_bin_to_txt(srcdir_path, dstdir_path)

def resylt_compare():
    file1 = "enc_result.txt"
    file2 = "./output_data_txt/result_enc.txt"
    if compare_lines(file1, file2, COMPARE_COUNTS):
        print("两个文件相同。")
    else:
        print("两个文件不相同。")

    file1 = "enc_m.txt"
    file2 = "./output_data_txt/result_dec.txt"
    if compare_lines(file1, file2, COMPARE_COUNTS):
        print("两个文件相同。")
    else:
        print("两个文件不相同。")

    file1 = "hom_add_result.txt"
    file2 = "./output_data_txt/result_hom_add.txt"
    if compare_lines(file1, file2, COMPARE_COUNTS):
        print("两个文件相同。")
    else:
        print("两个文件不相同。")

    file1 = "scalar_mul_result.txt"
    file2 = "./output_data_txt/result_scalar_mul.txt"
    if compare_lines(file1, file2, COMPARE_COUNTS):
        print("两个文件相同。")
    else:
        print("两个文件不相同。")

if __name__=='__main__':
    os.chdir('./data')
    input_translate()