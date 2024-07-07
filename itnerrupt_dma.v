/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
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
#include <xaxidma_hw.h>
#include <xil_exception.h>
#include <xparameters_ps.h>
#include <xstatus.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "xaxidma.h"
#include "xil_types.h"
#include "sleep.h"
#include "xscugic.h"


#define DMA_DEVICE_ID XPAR_AXI_DMA_0_BASEADDR


static XAxiDma dma_ctl;
static XAxiDma_Config *dma_cfg;

u32 i =1;
u32 count =0;
int done =1;
XScuGic IntcInstance;

void Intr_handler(void* CallBackRef){
  //  u32 data_dma_to_device = 2;
 //   u32 status;

    xil_printf("\t\tInterrupt Occurred\t\t\n");
  //  Xil_DCacheFlushRange((u32)&data_dma_to_device,1*sizeof(u32));

    XScuGic_Disable(&IntcInstance, 61);
    usleep(10000000);
    u32 p[8];
    XAxiDma_SimpleTransfer(&dma_ctl, (u32)p, 4*8, XAXIDMA_DEVICE_TO_DMA);

    for(int j =0; j<8; j++){
        xil_printf("received data: %d \n", p[j]);
    }

/*
    status = XAxiDma_SimpleTransfer((XAxiDma*) CallBackRef, (u32)&data_dma_to_device, 4, 
    XAXIDMA_DMA_TO_DEVICE);
    if(status!=XST_SUCCESS){
        xil_printf("DMA TRANSFER TO DEVCIE FAILED \r\n");
    }

    usleep(100);



    i = i + 1;

    if(i>8){
        done =0;
        XScuGic_Disable(&IntcInstance, 61);
        Xil_ExceptionDisable();
        xil_printf("finished TRY\n\r");
    }
    */

    if(count<3){
        XScuGic_Enable(&IntcInstance, 61);  
    }
    count = count+1;

    i= i+8;
    usleep(10);
    u32 k[8] = {i,i+1,i+2,i+3,i+4,i+5,i+6,i+7};
    Xil_DCacheFlushRange((u32)k, 8*sizeof(u32));
    XAxiDma_SimpleTransfer(&dma_ctl, (u32)k, 32, XAXIDMA_DMA_TO_DEVICE);
    
}

int main()
{
    init_platform();
    u32 status;

    xil_printf("DMA_INTERRUPT EXAMPLE 2\n");

    // DMA CONTROLLER INITIALIZATION
    dma_cfg = XAxiDma_LookupConfig(DMA_DEVICE_ID);
    if(dma_cfg == NULL){
        xil_printf("Can't find DMA CONFIGURATION \r\n");
        return XST_FAILURE;
    }
    // DMA CONFIGURATION INITIALIZATION
    status = XAxiDma_CfgInitialize(&dma_ctl, dma_cfg);
    if(status != XST_SUCCESS){
        xil_printf("DMA INITIALIZATION FAILED");
        return XST_FAILURE;
    }
    XAxiDma_IntrEnable(&dma_ctl, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);


    //Interrupt COntroller setting
    XScuGic_Config* IntcConfig;
    IntcConfig = XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
    status = XScuGic_CfgInitialize(&IntcInstance, IntcConfig, 
    IntcConfig->CpuBaseAddress);
    if(status !=XST_SUCCESS){
        printf("INTERRUPT CONTROLLER SETTING FAILED \r\n");
        return XST_FAILURE;
    }
    XScuGic_SetPriorityTriggerType(&IntcInstance, 61, 0xA0, 3);
    // connect interrupt handler
    status =XScuGic_Connect(&IntcInstance, 61, (Xil_InterruptHandler) 
    Intr_handler, (void*) &dma_ctl);
    if(status !=XST_SUCCESS){
        xil_printf("connect interrupt handler failed \n\r");
        return XST_FAILURE;
    }
    XScuGic_Enable(&IntcInstance, 61);

    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler) XScuGic_InterruptHandler, (void*)&IntcInstance);
    Xil_ExceptionEnable();

    // set up interrupt first time
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

    u32 k[8] = {i,i+1,i+2,i+3,i+4,i+5,i+6,i+7};
    Xil_DCacheFlushRange((u32)k, 8*sizeof(u32));

    xil_printf("send data to device for first interrupt\n");
    XAxiDma_SimpleTransfer(&dma_ctl, (u32)k, 4*8 , XAXIDMA_DMA_TO_DEVICE);

    usleep(100);
        for(int j =0; j <8; j++){
        xil_printf("sended data : %d \n", k[j]);
    }
    
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

/*
    xil_printf("senf data 2 to device for second interrupt \n");
    XAxiDma_SimpleTransfer(&dma_ctl, (u32)&k, 4 , XAXIDMA_DMA_TO_DEVICE);
    usleep(100);
    xil_printf("sneded data :%d \n",k);
    XAxiDma_SimpleTransfer(&dma_ctl, (u32)&p, 4, XAXIDMA_DEVICE_TO_DMA);
    xil_printf("received data: %d \n",p);
*/

    while(done){
        usleep(100);
    }

    u32 data_device_to_dma[10];

    status = XAxiDma_SimpleTransfer(&dma_ctl, (u32)data_device_to_dma,
     4*10, XAXIDMA_DEVICE_TO_DMA);
    

    xil_printf("get data form devcie \n\r" );
    

    print("Good Job\n\r");
    print("Successfully ran AXI_DMA_INTERRUPT_EXAMPLE");
    cleanup_platform();
    return 0;
}