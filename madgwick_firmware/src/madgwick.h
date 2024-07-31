#include "interrupts.h" 

// Register read/write macros
#define WRITE_ADDR(dir, value) { (*(volatile unsigned *)dir) = (value); }
#define READ_ADDR(dir) (*(volatile unsigned *)dir)

// Register addresses
#define CTRL_REG_ADDR 0x80003100

#define A_X_REG_ADDR 0x80003104
#define A_Y_REG_ADDR 0x80003108
#define A_Z_REG_ADDR 0x8000310C

#define W_X_REG_ADDR 0x80003110
#define W_Y_REG_ADDR 0x80003114
#define W_Z_REG_ADDR 0x80003118

#define Q_W_REG_ADDR 0x8000311C
#define Q_X_REG_ADDR 0x80003120
#define Q_Y_REG_ADDR 0x80003124
#define Q_Z_REG_ADDR 0x80003128

// Control register masks
#define CTRL_REG_ENABLE_MASK 0x1
#define CTRL_REG_START_MASK 0x2
#define CTRL_REG_DONE_MASK 0x4
#define CTRL_REG_INT_EN_MASK 0x8

// Global
volatile unsigned int ctrl_reg;
volatile unsigned int ax, ay, az, wx, wy, wz;
volatile unsigned long q_w, q_x, q_y, q_z;
volatile unsigned int done;

void madgwickInit(int);
void madgwickWriteInputVectors();
void madgwickReadOutputQuaternion();
void MADGWICK_ISR();


void madgwickInit(int int_en)
{
    // Reset madgwick accelerator
    WRITE_ADDR(CTRL_REG_ADDR, 0x0);

    if (int_en)
    {
        // Configure interrupt
        DefaultInitialization();    // Initialise external interrupt with default config
        pspExtInterruptsSetThreshold(5);   // Set interrupt threshold
        ExternalIntLine_Initialization(4, 6, MADGWICK_ISR); // Initialize line IRQ4 with priority 6 and set ISR
        M_PSP_WRITE_REGISTER_32(INT_SEL_REG_ADDR, 0x4);  // Set 3rd bit to connect IRQ4 to madgwick interrupt
        pspInterruptsEnable();  // Enable all interrupts in mstatus CSR
        M_PSP_SET_CSR(D_PSP_MIE_NUM, D_PSP_MIE_MEIE_MASK);  // Enable external interrupts in mie CSR

        // Enable madgwick accelerator and enable interrupts
        ctrl_reg = READ_ADDR(CTRL_REG_ADDR);    // Read control reg
        WRITE_ADDR(CTRL_REG_ADDR, (ctrl_reg | (CTRL_REG_ENABLE_MASK | CTRL_REG_INT_EN_MASK))); // Assert enable & int_en flag
    }
    else
    {
        // Enable madgwick accelerator
        ctrl_reg = READ_ADDR(CTRL_REG_ADDR);    // Read control reg
        WRITE_ADDR(CTRL_REG_ADDR, (ctrl_reg | CTRL_REG_ENABLE_MASK));
    }
}

void madgwickWriteInputVectors()
{
    WRITE_ADDR(A_X_REG_ADDR, ax);    // Write accel data
    WRITE_ADDR(A_Y_REG_ADDR, ay);
    WRITE_ADDR(A_Z_REG_ADDR, az);

    WRITE_ADDR(W_X_REG_ADDR, wx);    // Write gyro rate data
    WRITE_ADDR(W_Y_REG_ADDR, wy);
    WRITE_ADDR(W_Z_REG_ADDR, wz);

    // Start madgwick computation
    ctrl_reg = READ_ADDR(CTRL_REG_ADDR);    // Read control reg
    WRITE_ADDR(CTRL_REG_ADDR, (ctrl_reg | CTRL_REG_START_MASK)); // Assert start flag
}

void madgwickReadOutputQuaternion()
{
    q_w = READ_ADDR(Q_W_REG_ADDR);  // Read outputs 
    q_x = READ_ADDR(Q_X_REG_ADDR);
    q_y = READ_ADDR(Q_Y_REG_ADDR);
    q_z = READ_ADDR(Q_Z_REG_ADDR);

    ctrl_reg = READ_ADDR(CTRL_REG_ADDR);    // Read control reg
    WRITE_ADDR(CTRL_REG_ADDR, (ctrl_reg & ~CTRL_REG_START_MASK));    // De-assert start flag
}

void MADGWICK_ISR()
{
    madgwickReadOutputQuaternion();
    bspClearExtInterrupt(4);
    done = 1;
}
