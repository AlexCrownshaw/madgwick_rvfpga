#include "madgwick_mem_map.h"
#include "test_vectors.h"

#define WRITE_ADDR(dir, value) { (*(volatile unsigned *)dir) = (value); }
#define READ_ADDR(dir) (*(volatile unsigned *)dir)


volatile unsigned int ctrl_reg;
volatile unsigned long q_w, q_x, q_y, q_z;

int main(void)
{

    ctrl_reg = READ_ADDR(CTRL_REG_ADDR);    // Read control reg

    WRITE_ADDR(CTRL_REG_ADDR, 0x0); // Reset madgwick accelerator

    WRITE_ADDR(CTRL_REG_ADDR, 0x1); // Enable madgwick accelerator

    WRITE_ADDR(A_X_REG_ADDR, ax[0]);    // Write accel data
    WRITE_ADDR(A_Y_REG_ADDR, ay[0]);
    WRITE_ADDR(A_Z_REG_ADDR, az[0]);

    WRITE_ADDR(W_X_REG_ADDR, wx[0]);    // Write gyro rate data
    WRITE_ADDR(W_Y_REG_ADDR, wy[0]);
    WRITE_ADDR(W_Z_REG_ADDR, wz[0]);

    WRITE_ADDR(CTRL_REG_ADDR, 0x3); // Assert start flag

    while (!(ctrl_reg & 0x4))    // Read control reg until done flag is asserted
    {
        ctrl_reg = READ_ADDR(CTRL_REG_ADDR);    
    }

    q_w = READ_ADDR(Q_W_REG_ADDR);  // Read outputs 
    q_x = READ_ADDR(Q_X_REG_ADDR);
    q_y = READ_ADDR(Q_Y_REG_ADDR);
    q_z = READ_ADDR(Q_Z_REG_ADDR);

    WRITE_ADDR(CTRL_REG_ADDR, (ctrl_reg & 0xFD))    // De-assert start flag

}
