#include "I2C_HAL.h"

#define SLAVE_ADDR 0x68
#define WHO_AM_I_REG_ADDR 0x75

// f_clk prescaler macros
#define F_CLK_100KHZ 0x63
#define F_CLK_400KHZ 0x18

// Accelerometer full scale macros
#define AFS_SEL_2G 0x00
#define AFS_SEL_4G 0x08
#define AFS_SEL_8G 0x10
#define AFS_SEL_16G 0x18

// Gyro full scale macros
#define FS_SEL_250 0x00
#define FS_SEL_500 0x08
#define FS_SEL_1000 0x10
#define FS_SEL_2000 0x18

// DLPF config macros
#define DLPF_CONFIG_0 0
#define DLPF_CONFIG_1 1
#define DLPF_CONFIG_2 2
#define DLPF_CONFIG_3 3
#define DLPF_CONFIG_4 4
#define DLPF_CONFIG_5 5
#define DLPF_CONFIG_6 6
#define DLPF_CONFIG_7 7

// Sensor config registers
#define CONFIG_REG_ADDR 0x1A
#define PWR_MGMT_1_REG_ADDR 0x6B
#define INT_ENABLE_REG_ADDR 0x38
#define INT_STATUS_REG_ADDR 0x3A
#define ACCEL_CONFIG_REG_ADDR 0x1C
#define GYRO_CONFIG_REG_ADDR 0x1B

// Accelerometer registers
#define ACCEL_XOUT_H_REG_ADDR 0x3B
#define ACCEL_XOUT_L_REG_ADDR 0x3C
#define ACCEL_YOUT_H_REG_ADDR 0x3D
#define ACCEL_YOUT_L_REG_ADDR 0x3E
#define ACCEL_ZOUT_H_REG_ADDR 0x3F
#define ACCEL_ZOUT_L_REG_ADDR 0x40

// Gyroscope registers
#define GYRO_XOUT_H_REG_ADDR 0x43
#define GYRO_XOUT_L_REG_ADDR 0x44
#define GYRO_YOUT_H_REG_ADDR 0x45
#define GYRO_YOUT_L_REG_ADDR 0x46
#define GYRO_ZOUT_H_REG_ADDR 0x47
#define GYRO_ZOUT_L_REG_ADDR 0x48

// Bit masks
#define PWR_MGMT_1_RST_BIT_MASK 0x80
#define PWR_MGMT_1_SLEEP_BIT_MASK 0x80
#define INT_STATUS_DATA_RDY_INT_BIT_MASK 0x01

#define DATA_READY_INT_TIMEOUT 10000000
#define DEBUG

#define TIMEOUT_ERR -3

int MPU6050_ERROR = 0;

volatile uint8_t int_status;
volatile int16_t axRaw, ayRaw, azRaw, wxRaw, wyRaw, wzRaw;
uint8_t axRawLo, ayRawLo, azRawLo, wxRawLo, wyRawLo, wzRawLo;
uint8_t axRawHi, ayRawHi, azRawHi, wxRawHi, wyRawHi, wzRawHi;

void MPU6050_clear_error()
{
    MPU6050_ERROR = 0;
}

int MPU6050_init(uint8_t prescaler, uint8_t afs_sel, uint8_t fs_sel, uint8_t dlpfConfig)
{
    MPU6050_clear_error();
    
    I2C_HAL_init(prescaler, 0x00);  // Init i2c hardware abstraction layer

    if (!((I2C_HAL_get_error() == 0) && (I2C_HAL_read(SLAVE_ADDR, WHO_AM_I_REG_ADDR) == SLAVE_ADDR)))   // Test comms
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    I2C_HAL_write(SLAVE_ADDR, PWR_MGMT_1_REG_ADDR, PWR_MGMT_1_RST_BIT_MASK); // Set device reset bit
    if (!(I2C_HAL_get_error() == 0))
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    delay(1000000);

    I2C_HAL_write(SLAVE_ADDR, PWR_MGMT_1_REG_ADDR, 0x01); // Set clk source to gyro x PLL + Disable sleep   
    if (!(I2C_HAL_get_error() == 0))
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }    

    I2C_HAL_write(SLAVE_ADDR, ACCEL_CONFIG_REG_ADDR, afs_sel);  // Set accel range
    if (!(I2C_HAL_get_error() == 0))
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    I2C_HAL_write(SLAVE_ADDR, GYRO_CONFIG_REG_ADDR, fs_sel);    // Set gyro range
    if (!(I2C_HAL_get_error() == 0))
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    I2C_HAL_write(SLAVE_ADDR, CONFIG_REG_ADDR, dlpfConfig); // set DLPF config
    if (!(I2C_HAL_get_error() == 0))
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    I2C_HAL_write(SLAVE_ADDR, INT_ENABLE_REG_ADDR, 0x01);   // Enable data_ready interrupt
    if (!(I2C_HAL_get_error() == 0))
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    return 0;
}

int MPU6050_get_accel_raw_vector()
{
    MPU6050_clear_error();

    axRawHi = I2C_HAL_read(SLAVE_ADDR, ACCEL_XOUT_H_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    axRawLo = I2C_HAL_read(SLAVE_ADDR, ACCEL_XOUT_L_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    axRaw = (axRawHi << 8) | axRawLo;

    ayRawHi = I2C_HAL_read(SLAVE_ADDR, ACCEL_YOUT_H_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    ayRawLo = I2C_HAL_read(SLAVE_ADDR, ACCEL_YOUT_L_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }
    
    ayRaw = (ayRawHi << 8) | ayRawLo;

    azRawHi = I2C_HAL_read(SLAVE_ADDR, ACCEL_ZOUT_H_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    azRawLo = I2C_HAL_read(SLAVE_ADDR, ACCEL_ZOUT_L_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }
    
    azRaw = (azRawHi << 8) | azRawLo;

    // axRaw = (I2C_HAL_read(SLAVE_ADDR, ACCEL_XOUT_H_REG_ADDR) << 8) | I2C_HAL_read(SLAVE_ADDR, ACCEL_XOUT_L_REG_ADDR);
    // if (I2C_HAL_get_error() != 0)
    // {
    //     MPU6050_ERROR = I2C_HAL_get_error();
    //     return -1;
    // }

    // ayRaw = (I2C_HAL_read(SLAVE_ADDR, ACCEL_YOUT_H_REG_ADDR) << 8) | I2C_HAL_read(SLAVE_ADDR, ACCEL_YOUT_L_REG_ADDR);
    // if (I2C_HAL_get_error() != 0)
    // {
    //     MPU6050_ERROR = I2C_HAL_get_error();
    //     return -1;
    // }


    // azRaw = (I2C_HAL_read(SLAVE_ADDR, ACCEL_ZOUT_H_REG_ADDR) << 8) | I2C_HAL_read(SLAVE_ADDR, ACCEL_ZOUT_L_REG_ADDR);
    // if (I2C_HAL_get_error() != 0)
    // {
    //     MPU6050_ERROR = I2C_HAL_get_error();
    //     return -1;
    // }

    return 0;
}

int MPU6050_get_gyro_raw_vector()
{
    wxRawHi = I2C_HAL_read(SLAVE_ADDR, GYRO_XOUT_H_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    wxRawLo = I2C_HAL_read(SLAVE_ADDR, GYRO_XOUT_L_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    wxRaw = (wxRawHi << 8) | wxRawLo;

    wyRawHi = I2C_HAL_read(SLAVE_ADDR, GYRO_YOUT_H_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    wyRawLo = I2C_HAL_read(SLAVE_ADDR, GYRO_YOUT_L_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    wyRaw = (wyRawHi << 8) | wyRawLo;

    wzRawHi = I2C_HAL_read(SLAVE_ADDR, GYRO_ZOUT_H_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    wzRawLo = I2C_HAL_read(SLAVE_ADDR, GYRO_ZOUT_L_REG_ADDR);
    if (I2C_HAL_get_error() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    wzRaw = (wzRawHi << 8) | wzRawLo;

    // wxRaw = (I2C_HAL_read(SLAVE_ADDR, GYRO_XOUT_H_REG_ADDR) << 8) | I2C_HAL_read(SLAVE_ADDR, GYRO_XOUT_L_REG_ADDR);
    // if (I2C_HAL_get_error() != 0)
    // {
    //     MPU6050_ERROR = I2C_HAL_get_error();
    //     return -1;
    // }

    // wyRaw = (I2C_HAL_read(SLAVE_ADDR, GYRO_YOUT_H_REG_ADDR) << 8) | I2C_HAL_read(SLAVE_ADDR, GYRO_YOUT_L_REG_ADDR);
    // if (I2C_HAL_get_error() != 0)
    // {
    //     MPU6050_ERROR = I2C_HAL_get_error();
    //     return -1;
    // }

    // wzRaw = (I2C_HAL_read(SLAVE_ADDR, GYRO_ZOUT_H_REG_ADDR) << 8) | I2C_HAL_read(SLAVE_ADDR, GYRO_ZOUT_L_REG_ADDR);
    // if (I2C_HAL_get_error() != 0)
    // {
    //     MPU6050_ERROR = I2C_HAL_get_error();
    //     return -1;
    // }

    return 0;
}

int MPU6050_get_raw_sample()
{
    // int_status = I2C_HAL_read(SLAVE_ADDR, INT_STATUS_REG_ADDR);

    unsigned int count = 0;
    while (!(I2C_HAL_read(SLAVE_ADDR, INT_STATUS_REG_ADDR) & INT_STATUS_DATA_RDY_INT_BIT_MASK))
    {
        if (count < DATA_READY_INT_TIMEOUT)
        {
            count++;
        }
        else
        {
            MPU6050_ERROR = TIMEOUT_ERR;
            return -1;
        }
    }

    if (MPU6050_get_accel_raw_vector() != 0)
    {
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    if (MPU6050_get_gyro_raw_vector() != 0)
    {
        
        MPU6050_ERROR = I2C_HAL_get_error();
        return -1;
    }

    if (!(I2C_HAL_read(SLAVE_ADDR, INT_STATUS_REG_ADDR) & INT_STATUS_DATA_RDY_INT_BIT_MASK))
    {
        MPU6050_ERROR = TIMEOUT_ERR;
        return -1;
    }

    return 0;
}