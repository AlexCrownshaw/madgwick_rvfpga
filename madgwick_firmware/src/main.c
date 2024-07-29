#if defined(D_NEXYS_A7)
   #include <bsp_printf.h>
   #include <bsp_mem_map.h>
   #include <bsp_version.h>
#else
   PRE_COMPILED_MSG("no platform was defined")
#endif
#include <psp_api.h>

#include "madgwick.c"
#include "test_vectors.h"

#define WRITE_ADDR(dir, value) { (*(volatile unsigned *)dir) = (value); }
#define READ_ADDR(dir) (*(volatile unsigned *)dir)

#define INTERRUPT_ENABLE 1

void busy();


int main(void)
{
    uartInit();

    madgwickInit(INTERRUPT_ENABLE);

    int size = sizeof(ax_test_vector) / sizeof(int);
    for (int i = 0; i < size; i++)
    {
        do
        {
            ctrl_reg = READ_ADDR(CTRL_REG_ADDR);    // Read control reg
        } while (ctrl_reg & CTRL_REG_START_MASK);
        
        ax = ax_test_vector[i];
        ay = ay_test_vector[i];
        az = az_test_vector[i];
        wx = wx_test_vector[i];
        wy = wy_test_vector[i];
        wz = wz_test_vector[i];
        madgwickWriteInputVectors();
    }

    return 0;
}
