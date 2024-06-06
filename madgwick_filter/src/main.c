#if defined(D_NEXYS_A7)
    #include <bsp_printf.h>
    #include <bsp_mem_map.h>
    #include <bsp_version.h>
#else
    PRE_COMPILED_MSG("no platform was defined")
#endif

#include <psp_api.h>
#include "SPI_HAL/SPI_HAL.h"


int main(void)
{
    uartInit();

    printfNexys("Hello_madgwick_rvfpga");

    SPI_HAL_Init();

    printfNexys("SPI_HAL_Init did not crash!!!");
}