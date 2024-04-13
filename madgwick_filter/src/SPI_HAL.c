/* 
* Serial Peripheral Interface (SPI), Hardware Abstraction Layer (HAL) for OpenCores simple_spi SPI module.
* (https://opencores.org/projects/simple_spi)
* Built for use in RISC-V FPGA applications using the SweRVolfSoC architecture.
* Supports Controller mode only (no peripheral mode).
*
* Author: Alex Crownshaw
* Date: 13/04/2024
*/

#define SPCR 0x80001100
#define SPSR 0x80001108
#define SPDR 0x80001110
#define SPER 0x80001118
#define SPCS 0x80001120

#define READ_ADDR(dir) (*(volatile unsigned int*)dir)
#define WRITE_ADDR(dir, value) { (*(volatile unsigned int*)dir) = (value); }

int SPI_HAL_Init()
{
    /* Initialise the SPI module */

    // Control register setup
    WRITE_ADDR(SPCR, 0x53); // Configure control register: 01010011

    // Extension register setup
    WRITE_ADDR(SPER, 0x02); // Configure extension register: 00000010
}

unsigned int* SPI_HAL_sendGetData(unsigned char dataToSend, unsigned char *receivedData) 
{
    /* Send byte through SPI and get the peripheral data back */

    // Internal clear interrupt flag
    unsigned int statusVal = READ_ADDR(SPSR);   // Read current status
    statusVal |= 0x80;  // Perform bitwise OR (0x80 = 100000000)
    WRITE_ADDR(SPSR, statusVal);    // Write statusVal to set bit 7 to clear SPIF
    
    // Internal actual send
    WRITE_ADDR(SPDR, dataToSend);   // Send data byte

    // Internal test interrupt flag
    unsigned int *statusReg = READ_ADDR(SPSR);
    while ((*statusReg & 0x80) != 0x80); // check if bit 7 of the status register is not set
    {
        unsigned int *statusReg = READ_ADDR(SPSR);
    }
    
    // Internal read data
    *receivedData = READ_ADDR(SPDR); // Read received data

    return receivedData;
}

void SPI_HAL_CS_High()
{
    /* Pull CS Line high */

    WRITE_ADDR(SPCS, 0x00);
}

void SPI_HAL_CS_Low()
{
    /* Pull CS Line low */

    WRITE_ADDR(SPCS, 0xFF);
}
