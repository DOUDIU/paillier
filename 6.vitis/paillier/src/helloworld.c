/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xparameters_ps.h"
#include "xil_io.h"
#include "xgpiops.h"
#include "xgpio.h"
#include <unistd.h>
#include <stdbool.h>
#include "xscugic.h"
#include "xil_exception.h"
#include "xil_cache.h"
#include "ff.h"
#include "xstatus.h"
#include "xtime_l.h"

#define DDR_BASEARDDR           XPAR_DDR_MEM_BASEADDR
#define REGISTER_BASEARDDR      XPAR_PAILLIER_0_BASEADDR
#define KEY_DEVICE_ID           XPAR_AXI_GPIO_0_DEVICE_ID
#define LED_DEVICE_ID           XPAR_AXI_GPIO_1_DEVICE_ID

// #define XPAR_CPU_CORTEXA53_0_TIMESTAMP_CLK_FREQ 99990000
#define COUNTS_PER_USECOND ( (COUNTS_PER_SECOND + 1000000/2 - 1 ) / 1000000 )
#define COUNTS_PER_MSECOND ( (COUNTS_PER_SECOND + 1000/2 - 1 ) / 1000 )

XGpio LEDInst;
XGpio KEYInst;
static FATFS fatfs;

int sd_mount();
int platform_init_fs();
int sd_read_data(char *file_name,u32 src_addr,u32 byte_len);
int sd_write_data(char *file_name,u32 src_addr,u32 byte_len);

void wr_enc_to_ddr();
void start_single_acceleration();
int axi_gpio_init();
void paillier_test();
void read_sd_to_ddr();
void read_ddr_to_sd();

u32 enc_m [64] = {
    0x65be121b,
    0x6b6b7b6a,
    0xaf70def2,
    0xa6c570ff,
    0x4523ac2e,
    0xc516e4fa,
    0x5ca99c13,
    0x7ee28e47,
    0x48259ad3,
    0x21632b3a,
    0x982c5831,
    0xb044c3db,
    0x6acb0f53,
    0x1e88c4c8,
    0x4fc28eaf,
    0x85e5228c,
    0x5a175a2c,
    0xe69680f3,
    0x4838134a,
    0xe0acbdfd,
    0xeff69cb8,
    0x156655c,
    0xcc4dcc72,
    0x8ee227e8,
    0xc3d66017,
    0xf0e634e8,
    0x57b12302,
    0x84901b5a,
    0x94473f52,
    0x16c5262a,
    0xab697ced,
    0xe956a16c,
    0xc8a03fb9,
    0x9beb9af1,
    0x82a13e99,
    0xe555ddf4,
    0x86866e50,
    0x5abce841,
    0xe963cce3,
    0x96b059a6,
    0x6c2fcb0d,
    0xf4bdd077,
    0x8b2334ed,
    0xf99709e9,
    0xcc653912,
    0x847d13c1,
    0x5ca09f13,
    0x1ac3e4e4,
    0x3bec5cb8,
    0xafd6fcf1,
    0x7aa7b40e,
    0xe9070fb1,
    0x7077b0cc,
    0x2027ae7a,
    0x30ab2035,
    0xd4e7feb6,
    0xa6b0e595,
    0x2bd24cc4,
    0x2c3d8b7d,
    0xd0ceafc0,
    0x79b923b3,
    0xc766d1ed,
    0x376d6cd,
    0xa23f854,
};

u32 enc_r [64] = {
    0x8172c483,
    0xe67b4fb5,
    0xd7904d66,
    0xa57328e6,
    0x230b3ac3,
    0xb3a1f02,
    0xd8a8938d,
    0xc68abe11,
    0xc508d369,
    0xeda4a0cd,
    0x8971ff7b,
    0x6e1007ca,
    0x5aa0f0c7,
    0x23976e17,
    0xb8470940,
    0xd71cefcc,
    0xf1583abd,
    0xfda94e7c,
    0x382b547e,
    0xcb49e58d,
    0x9fc4c6fa,
    0xbfcf68b6,
    0xa54afb49,
    0x9dc81d0d,
    0x87505a28,
    0x176ba6f8,
    0x847683e2,
    0xd206e8f8,
    0x9d7a97dc,
    0xd6287d68,
    0x36c13de5,
    0xada02c1b,
    0x5f432cf6,
    0xc400e5ba,
    0x6809fc5b,
    0x1ffb32c0,
    0xa91ee35f,
    0xc3d6891f,
    0x784e43d1,
    0x5f880c0d,
    0xe64523ec,
    0xac51d3fe,
    0x26a94631,
    0x81bcf0ed,
    0x26871441,
    0x74f89c2,
    0xb258af3b,
    0xabd9e71b,
    0x74618145,
    0xd2f59f47,
    0xd41e9f6a,
    0x36e11a,
    0x1f5fbea2,
    0x37da44a1,
    0x92e6b761,
    0xb41de58,
    0x9787c0ca,
    0x1b1f0948,
    0x9c9822b4,
    0x74c22686,
    0xc2d4df42,
    0x6ebc0e56,
    0xe237a17b,
    0x227a17f9,
};

//single read byte counts
#define COUNTS 256
#define loop_num 10
u32 dest_str[COUNTS / 4] __attribute__ ((__aligned__(1024)));//aligned to 1024 bytes
u32 src_str[COUNTS / 4] __attribute__ ((__aligned__(1024)));//aligned to 1024 bytes

XTime xtTimeBegin, xtTimeEnd;
u64 u64_sleep_cycles;
u64 u64_sleep_us_passed = 0;

int main(){
    init_platform();
    
    axi_gpio_init();

    // Xil_DCacheDisable();
    // Xil_ICacheDisable();

    paillier_test();

    while(1);

    cleanup_platform();
    return 0;
}

void paillier_test(){
#ifdef SELF_TEST_MODE
    wr_enc_to_ddr();
#else
    read_sd_to_ddr();
#endif

    start_single_acceleration();

    read_ddr_to_sd();
}

void read_ddr_to_sd(){
    FIL fil;
    UINT bw;
    UINTPTR target_addr;

    f_open(&fil,"result_enc.bin", FA_CREATE_ALWAYS | FA_WRITE);
    f_lseek(&fil, 0);
/*
    //The following is usable. The reason has not been discovered yet.
    // for(int j = 0; j < loop_num; j++){
    //     target_addr = DDR_BASEARDDR + j * COUNTS * 2;
    //     for(int i = COUNTS * 2 / 4 - 1; i >= 0; i--){
    //         src_str[i] = Xil_In32(target_addr);
    //         target_addr += 4;
    //     }
    //     f_write(&fil, (void*)src_str, 2 * COUNTS, &bw);
    // }
*/
    f_write(&fil, DDR_BASEARDDR, COUNTS * 2 * loop_num, &bw);
    f_close(&fil);

    printf("read ddr to sd finished\n");
}

void read_sd_to_ddr(){
    int status;
    status = sd_mount();
    if(status != XST_SUCCESS){
		xil_printf("Failed to open SD card!\n");
		return 0;
    }

	FIL fil;
    UINT br;
    UINTPTR target_addr;

    f_open(&fil, "result_enc_m.bin", FA_READ);
    f_lseek(&fil, 0);
    for(int j = 0; j < loop_num; j++){
        target_addr = DDR_BASEARDDR + j * COUNTS * 2;
        f_read(&fil, (void*)(dest_str), COUNTS, &br);
        for(int i = COUNTS / 4 - 1; i >= 0; i--){
            Xil_Out32(target_addr, Xil_EndianSwap32(dest_str[i]));
            target_addr += 4;
        }
    }
    f_close(&fil);

    target_addr = DDR_BASEARDDR + COUNTS;
    f_open(&fil, "result_enc_r.bin", FA_READ);
    f_lseek(&fil, 0);
    for(int j = 0; j < loop_num; j++){
        target_addr = DDR_BASEARDDR + COUNTS + j * COUNTS * 2;
        f_read(&fil, (u32)(dest_str), COUNTS, &br);
        for(int i = COUNTS / 4 - 1; i >= 0; i--){
            Xil_Out32(target_addr, Xil_EndianSwap32(dest_str[i]));
            target_addr += 4;
        }
    }
    f_close(&fil);
    
    Xil_DCacheFlushRange(DDR_BASEARDDR, COUNTS * 2 * loop_num);

/*
  #ifdef SEQ_STORE
    sd_read_data("result_enc_m.bin",(u32)(DDR_BASEARDDR), COUNTS);
    sd_read_data("result_enc_r.bin",(u32)(DDR_BASEARDDR + COUNTS), COUNTS);
    Xil_DCacheFlushRange(DDR_BASEARDDR, 512);
  #else
    UINTPTR target_addr = DDR_BASEARDDR;
    sd_read_data("result_enc_m.bin",(u32)(dest_str), COUNTS);
    for(int i = COUNTS / 4 - 1; i >= 0; i--){
        Xil_Out32(target_addr, dest_str[i]);
        target_addr += 4; 
    }
    sd_read_data("result_enc_r.bin",(u32)(dest_str), COUNTS);
    for(int i = COUNTS / 4 - 1; i >= 0; i--){
        Xil_Out32(target_addr, dest_str[i]);
        target_addr += 4; 
    }
    Xil_DCacheFlushRange(DDR_BASEARDDR, 512);
  #endif
*/
}

void start_single_acceleration(){
    printf("the value of stop register: %d\n", Xil_In32(REGISTER_BASEARDDR + 4));

    printf("write acceleration accounts\n");
    Xil_Out32(REGISTER_BASEARDDR + 12, 0x0);
    Xil_Out32(REGISTER_BASEARDDR + 8 , 0xa);

    printf("write acceleration types and start signal\n");

    XTime_GetTime(&xtTimeBegin);

    Xil_Out32(REGISTER_BASEARDDR, 0x1);
    Xil_Out32(REGISTER_BASEARDDR, 0x0);

    // printf("wait the stop signal is asserted\n");
    while(Xil_In32(REGISTER_BASEARDDR + 4) == 0);

    XTime_GetTime(&xtTimeEnd);
    u64_sleep_cycles = xtTimeEnd - xtTimeBegin;
    u64_sleep_us_passed = u64_sleep_cycles/(COUNTS_PER_USECOND);
    xil_printf("soft_operation_to_be_measured takes %d cycles\n", u64_sleep_cycles);
    xil_printf("equal to %d us\n", u64_sleep_us_passed);

    Xil_DCacheFlushRange(DDR_BASEARDDR, COUNTS * 2 * loop_num);

    printf("acceleration finish\n");

    sleep(1);
}

int axi_gpio_init(){
	int status;
    status = XGpio_Initialize(&KEYInst, KEY_DEVICE_ID); // initial KEY
    if(status != XST_SUCCESS)
        printf("key_init failed\n");
    status = XGpio_Initialize(&LEDInst, LED_DEVICE_ID);  // initial LED
    if(status != XST_SUCCESS)
        printf("led_init failed\n");
        
    // if(status != XST_SUCCESS) return XST_FAILURE;
    XGpio_SetDataDirection(&KEYInst, 1, 3); // set KEY IO direction as in
    XGpio_SetDataDirection(&LEDInst, 1, 0); // set LED IO direction as out
    XGpio_DiscreteWrite(&LEDInst, 1, 0x03);// at initial, all LED turn off
}

void wr_enc_to_ddr(){
    printf("wr m\n");
    UINTPTR AIM_ADDR = DDR_BASEARDDR;
    for(int i = 0; i < 64; i++){
        Xil_Out32(AIM_ADDR, enc_m[i]);
        AIM_ADDR += 4;
        printf("enc_m[%d]: %x\n", i, enc_m[i]);
    }
    printf("wr r\n");
    for(int i = 0; i < 64; i++){
        Xil_Out32(AIM_ADDR, enc_r[i]);
        AIM_ADDR += 4;
        printf("enc_r[%d]: %x\n", i, enc_r[i]);
    }
    printf("wr finished\n");
    Xil_DCacheFlushRange(DDR_BASEARDDR, 512);
}

//mount SD card
int sd_mount(){
    FRESULT status;
    status = platform_init_fs();
    if(status){
        xil_printf("ERROR: f_mount returned %d!\n",status);
        return XST_FAILURE;
    }
    return XST_SUCCESS;
}

int platform_init_fs(){
	FRESULT status;
	TCHAR *Path = "0:/";
	BYTE work[FF_MAX_SS];

	status = f_mount(&fatfs, Path, 1);
	if (status != FR_OK) {
		xil_printf("Volume is not FAT formated; formating FAT\r\n");
		//initial SD card
		status = f_mkfs(Path, FM_FAT32, work, sizeof work);
		if (status != FR_OK) {
			xil_printf("Unable to format FATfs\r\n");
			return -1;
		}

		status = f_mount(&fatfs, Path, 1);
		if (status != FR_OK) {
			xil_printf("Unable to mount FATfs\r\n");
			return -1;
		}
	}
	return 0;
}

int sd_read_data(char *file_name,u32 src_addr,u32 byte_len){
	FIL fil;
    UINT br;

    f_open(&fil,file_name,FA_READ);
    f_lseek(&fil,0);
    f_read(&fil,(void*)src_addr,byte_len,&br);
    f_close(&fil);
    return 0;
}

int sd_write_data(char *file_name,u32 src_addr,u32 byte_len){
    FIL fil;
    UINT bw;

    f_open(&fil,file_name,FA_CREATE_ALWAYS | FA_WRITE);
    f_lseek(&fil, 0);
    f_write(&fil,(void*) src_addr,byte_len,&bw);
    f_close(&fil);
    return 0;
}
