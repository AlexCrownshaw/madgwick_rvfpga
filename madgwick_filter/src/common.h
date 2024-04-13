#define READ_ADDR(dir) (*(volatile unsigned int*)dir)
#define WRITE_ADDR(dir, value) { (*(volatile unsigned int*)dir) = (value); }