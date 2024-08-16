/* 
* I2C Hardware Abstraction Layer for Lattice Semi-conductors RD-1046 I2C WB Core
* (https://www.latticesemi.com/products/designsoftwareandip/intellectualproperty/referencedesigns/referencedesigns02/i2cmasterwishbonecompatible)
* Built for use in RISC-V FPGA applications using the SweRVolfSoC architecture.
*
* Pre-scale reg = master clock frequency / (5 x (sclk frequency)) - 1
*
* Author: Alex Crownshaw
* Date: 13/04/2024
*/

#include <stdint.h>

/* Register adresses */ 
#define I2C_CLK_PRESCALE_LO_REG_ADDR 0x80003200
#define I2C_CLK_PRESCALE_HI_REG_ADDR 0x80003204
#define I2C_CTRL_REG_ADDR 0x80003208
#define I2C_TX_REG_ADDR 0x8000320C
#define I2C_RX_REG_ADDR 0x8000320C
#define I2C_COM_REG_ADDR 0x80003210
#define I2C_STAT_REG_ADDR 0x80003210

/* Bit masks */ 
#define I2C_EN_MASK 0x80    // Control Reg
#define I2C_INT_EN_MAKS 0x40
#define I2C_RX_ACK_MASK 0x80    // Status Reg
#define I2C_BUSY_MASK 0x40
#define I2C_AL_MASK 0x20
#define I2C_TIP_MASK 0x02
#define I2C_IF_MASK 0x01
#define I2C_START_MASK 0x80
#define I2C_STOP_MASK 0x40
#define I2C_READ_MASK 0x20
#define I2C_WRITE_MASK 0x10
#define I2C_NACK_MASK 0x08
#define I2C_INT_ACK_MASK 0x00

/* Error codes */ 
#define I2C_ERROR_NONE 0
#define I2C_ERROR_ARBITRATION_LOST -1
#define I2C_ERROR_NO_ACK -2

#define STD_DELAY 100

#define WRITE_ADDR(dir, value) { (*(volatile unsigned *)dir) = (value); }
#define READ_ADDR(dir) (*(volatile unsigned *)dir)

int I2C_HAL_error = 0;
volatile uint8_t status;

void I2C_HAL_clear_error()
{
    I2C_HAL_error = I2C_ERROR_NONE;
}

int I2C_HAL_get_error()
{
    return I2C_HAL_error;
}

void delay(unsigned long iter)
{
   for (volatile int i = 0; i < iter; ++i); // Delay      
}

int I2C_HAL_init(uint8_t prescale_lo, uint8_t prescale_hi)
{
    I2C_HAL_clear_error(); // Clear previous errors

    // Ensure the I2C core is not busy or in an error state before initialization
    status = READ_ADDR(I2C_STAT_REG_ADDR);
    if (status & (I2C_BUSY_MASK | I2C_AL_MASK))
    {
        I2C_HAL_error = I2C_ERROR_ARBITRATION_LOST; // I2C core is busy or arbitration lost
        return -1;
    }

    // Set the clock prescale registers
    WRITE_ADDR(I2C_CLK_PRESCALE_LO_REG_ADDR, prescale_lo);
    WRITE_ADDR(I2C_CLK_PRESCALE_HI_REG_ADDR, prescale_hi);

    // Enable the I2C core
    WRITE_ADDR(I2C_CTRL_REG_ADDR, I2C_EN_MASK);

    return 0;  // Success
}

int I2C_HAL_write(uint8_t slaveAddr, uint8_t regAddr, uint8_t data)
{
    I2C_HAL_clear_error(); // Clear previous errors

    // Step 1: Write the slave address with the write bit (0)
    WRITE_ADDR(I2C_TX_REG_ADDR, (slaveAddr << 1));  // Write slave addr with r/w bit = 0 (write mode)
    WRITE_ADDR(I2C_COM_REG_ADDR, (I2C_START_MASK | I2C_WRITE_MASK)); // Set start and write bits in command reg

    delay(STD_DELAY);

    // Step 2: Wait for transfer to complete
    do
    {
        status = READ_ADDR(I2C_STAT_REG_ADDR);
    } while (status & I2C_TIP_MASK);

    // Check for errors after sending the slave address
    if (status & I2C_AL_MASK)
    {
        I2C_HAL_error = I2C_ERROR_ARBITRATION_LOST; // Arbitration lost
        return -1;
    }
    if (status & I2C_RX_ACK_MASK)
    {
        I2C_HAL_error = I2C_ERROR_NO_ACK; // No acknowledgment from slave
        return -1;
    }

    // Step 3: Write the register address to which data should be written
    WRITE_ADDR(I2C_TX_REG_ADDR, regAddr);   // Write register address
    WRITE_ADDR(I2C_COM_REG_ADDR, I2C_WRITE_MASK); // Set write bit

    delay(STD_DELAY);

    // Step 4: Wait for transfer to complete
    do
    {
        status = READ_ADDR(I2C_STAT_REG_ADDR);
    } while (status & I2C_TIP_MASK);

    // Check for errors after sending the register address
    if (status & I2C_AL_MASK)
    {
        I2C_HAL_error = I2C_ERROR_ARBITRATION_LOST; // Arbitration lost
        return -1;
    }
    if (status & I2C_RX_ACK_MASK)
    {
        I2C_HAL_error = I2C_ERROR_NO_ACK; // No acknowledgment from slave
        return -1;
    }

    // Step 5: Write the data to the register
    WRITE_ADDR(I2C_TX_REG_ADDR, data);   // Write data
    WRITE_ADDR(I2C_COM_REG_ADDR, (I2C_WRITE_MASK | I2C_STOP_MASK)); // Set write and stop bits

    delay(STD_DELAY);

    // Step 6: Wait for transfer to complete
    do
    {
        status = READ_ADDR(I2C_STAT_REG_ADDR);
    } while (status & I2C_TIP_MASK);

    // Check for errors after sending the data
    if (status & I2C_AL_MASK)
    {
        I2C_HAL_error = I2C_ERROR_ARBITRATION_LOST; // Arbitration lost
        return -1;
    }
    if (status & I2C_RX_ACK_MASK)
    {
        I2C_HAL_error = I2C_ERROR_NO_ACK; // No acknowledgment from slave
        return -1;
    }

    return 0;
}

int8_t I2C_HAL_read(uint8_t slaveAddr, uint8_t regAddr)
{
    I2C_HAL_clear_error(); // Clear previous errors

    // Step 1: Write the slave address with the write bit (0)
    WRITE_ADDR(I2C_TX_REG_ADDR, (slaveAddr << 1));  // Write slave addr with r/w bit = 0 (write mode)
    WRITE_ADDR(I2C_COM_REG_ADDR, (I2C_START_MASK | I2C_WRITE_MASK)); // Set start and write bits in command reg

    delay(STD_DELAY);

    // Step 2: Wait for transfer to complete
    do
    {
        status = READ_ADDR(I2C_STAT_REG_ADDR);
    } while (status & I2C_TIP_MASK);

    // Check for errors after sending the slave address
    if (status & I2C_AL_MASK)
    {
        I2C_HAL_error = I2C_ERROR_ARBITRATION_LOST;
        return -1;
    }
    if (status & I2C_RX_ACK_MASK)
    {
        I2C_HAL_error = I2C_ERROR_NO_ACK;
        return -1;
    }

    // Step 3: Write the register address we want to read from
    WRITE_ADDR(I2C_TX_REG_ADDR, regAddr);   // Write register address
    WRITE_ADDR(I2C_COM_REG_ADDR, I2C_WRITE_MASK); // Set write bit

    delay(STD_DELAY);

    // Step 4: Wait for transfer to complete
    do
    {
        status = READ_ADDR(I2C_STAT_REG_ADDR);
    } while (status & I2C_TIP_MASK);

    // Check for errors after sending the register address
    if (status & I2C_AL_MASK)
    {
        I2C_HAL_error = I2C_ERROR_ARBITRATION_LOST;
        return -1;
    }
    if (status & I2C_RX_ACK_MASK)
    {
        I2C_HAL_error = I2C_ERROR_NO_ACK;
        return -1;
    }

    // Step 5: Send the slave address with the read bit (1)
    WRITE_ADDR(I2C_TX_REG_ADDR, ((slaveAddr << 1) | 0x01));  // Write slave addr with r/w bit = 1 (read mode)
    WRITE_ADDR(I2C_COM_REG_ADDR, (I2C_START_MASK | I2C_WRITE_MASK)); // Set repeated start and write bits

    delay(STD_DELAY);

    // Step 6: Wait for transfer to complete
    do
    {
        status = READ_ADDR(I2C_STAT_REG_ADDR);
    } while (status & I2C_TIP_MASK);

    // Check for errors after sending the repeated start and slave address
    if (status & I2C_AL_MASK)
    {
        I2C_HAL_error = I2C_ERROR_ARBITRATION_LOST;
        return -1;
    }
    if (status & I2C_RX_ACK_MASK)
    {
        I2C_HAL_error = I2C_ERROR_NO_ACK;
        return -1;
    }

    // Step 7: Initiate read and handle ACK/NACK
    WRITE_ADDR(I2C_COM_REG_ADDR, (I2C_READ_MASK | I2C_NACK_MASK)); // Set read and nack bits for final byte

    delay(STD_DELAY);

    // Step 8: Wait for transfer to complete
    do
    {
        status = READ_ADDR(I2C_STAT_REG_ADDR);
    } while (status & I2C_TIP_MASK);

    // Check for errors after reading the data
    if (status & I2C_AL_MASK)
    {
        I2C_HAL_error = I2C_ERROR_ARBITRATION_LOST;
        return -1;
    }

    // Step 9: Read the received data
    int8_t data = READ_ADDR(I2C_RX_REG_ADDR);

    // Step 10: Send the STOP condition
    WRITE_ADDR(I2C_COM_REG_ADDR, I2C_STOP_MASK);

    delay(STD_DELAY);

    return data;
}
