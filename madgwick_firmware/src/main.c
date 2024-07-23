// #if defined(D_NEXYS_A7)
//    #include <bsp_printf.h>
//    #include <bsp_mem_map.h>
//    #include <bsp_version.h>
// #else
//    PRE_COMPILED_MSG("no platform was defined")
// #endif
// #include <psp_api.h>

#include "madgwick_mem_map.h"
#include "test_vectors.h"

#define WRITE_ADDR(dir, value) { (*(volatile unsigned *)dir) = (value); }
#define READ_ADDR(dir) (*(volatile unsigned *)dir)

volatile unsigned int ctrl_reg;
volatile unsigned long q_w, q_x, q_y, q_z;

void get_attitude(unsigned int);


int main(void)
{
    // uartInit();

    // Reset madgwick accelerator
    ctrl_reg = READ_ADDR(CTRL_REG_ADDR);    // Read control reg
    WRITE_ADDR(CTRL_REG_ADDR, (ctrl_reg & ~CTRL_REG_ENABLE_MASK));   // De-assert enable flag

    // Enable madgwick accelerator
    ctrl_reg = READ_ADDR(CTRL_REG_ADDR);    // Read control reg
    WRITE_ADDR(CTRL_REG_ADDR, (ctrl_reg | CTRL_REG_ENABLE_MASK)); // Assert enable flag

    // int size = sizeof(ax) / sizeof(int);
    int size = 2;
    for (int i = 0; i < size; i++)
    {
        get_attitude(i);
        // printfNexys("%d,%d,%d,%d", q_w, q_x, q_y, q_z);
    }

    return 0;
}


void get_attitude(unsigned int index)
{
    WRITE_ADDR(A_X_REG_ADDR, ax[index]);    // Write accel data
    WRITE_ADDR(A_Y_REG_ADDR, ay[index]);
    WRITE_ADDR(A_Z_REG_ADDR, az[index]);

    WRITE_ADDR(W_X_REG_ADDR, wx[index]);    // Write gyro rate data
    WRITE_ADDR(W_Y_REG_ADDR, wy[index]);
    WRITE_ADDR(W_Z_REG_ADDR, wz[index]);

    // Start madgwick computation
    ctrl_reg = READ_ADDR(CTRL_REG_ADDR);    // Read control reg
    WRITE_ADDR(CTRL_REG_ADDR, (ctrl_reg | CTRL_REG_START_MASK)); // Assert start flag

    // Read control reg until done flag is asserted
    do {
        ctrl_reg = READ_ADDR(CTRL_REG_ADDR);
    } while (!(ctrl_reg & CTRL_REG_DONE_MASK)); 

    q_w = READ_ADDR(Q_W_REG_ADDR);  // Read outputs 
    q_x = READ_ADDR(Q_X_REG_ADDR);
    q_y = READ_ADDR(Q_Y_REG_ADDR);
    q_z = READ_ADDR(Q_Z_REG_ADDR);

    ctrl_reg = READ_ADDR(CTRL_REG_ADDR);    // Read control reg
    WRITE_ADDR(CTRL_REG_ADDR, (ctrl_reg & ~CTRL_REG_START_MASK));    // De-assert start flag
}
