#define SPCR 0x80001100
#define SPSR 0x80001108
#define SPDR 0x80001110
#define SPER 0x80001118
#define SPCS 0x80001120

int SPI_HAL_Init();
unsigned int* SPI_HAL_sendGetData(unsigned int, unsigned int*);
void SPI_HAL_CS_High();
void SPI_HAL_CS_Low();
