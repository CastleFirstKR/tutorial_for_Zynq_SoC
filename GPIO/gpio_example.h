/******************************************************************************

Tutorial Materials for Embedded Software using Vitis IDE

Using GPIO  Ip, WRITE DATA AND READ  EXAMPLE

made by Seongwon Jo,


*******************************************************************************/

#include <stdio.h>
#include "platform.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "xparameters.h"
#include "sleep.h"

#define LED_DEVICE_ID XPAR_AXI_GPIO_1_BASEADDR
#define KEY_DEVICE_ID XPAR_AXI_GPIO_0_BASEADDR

#define LED_CHANNEL 1
#define KEY_CHANNEL 1

#define print xil_printf    // Smaller foot-print printf //

int main()
{
    int Status;
    XGpio GpioLed;
    XGpio GpioKey;
    u32 InputData1, InputData2;

    init_platform();

    xil_printf("AXI GPIO Polled Mode Example Test \n\r");

    // Initialize the GPIO driver 
    Status = XGpio_Initialize(&GpioLed, LED_DEVICE_ID);
    if(Status != XST_SUCCESS){
        return XST_FAILURE;
    }
    Status = XGpio_Initialize(&GpioKey, KEY_DEVICE_ID);
    if(Status != XST_SUCCESS){
        return XST_FAILURE;
    }

    xil_printf("start \r\n");
    XGpio_SetDataDirection(&GpioLed, LED_CHANNEL, 1);

    XGpio_SetDataDirection(&GpioKey, KEY_CHANNEL, 0);
    xil_printf("start2 \r\n");

    InputData1 = InputData2 = 1;

    while(1){
        InputData1 = XGpio_DiscreteRead(&GpioKey,KEY_CHANNEL);
        if(InputData1 != InputData2){
            if(InputData1==0){
                XGpio_DiscreteWrite(&GpioLed, LED_CHANNEL, 0xF);
            }
            else {
                XGpio_DiscreteWrite(&GpioLed,  LED_CHANNEL, 0x0);
            }
            xil_printf("Input Data : %d \r\n", InputData1);
            InputData2 = InputData1;
        }
    }

    cleanup_platform();
    return 0;
}
