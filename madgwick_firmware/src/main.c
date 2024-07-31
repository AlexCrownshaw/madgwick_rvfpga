#if defined(D_NEXYS_A7)
   #include <bsp_printf.h>
   #include <bsp_mem_map.h>
   #include <bsp_version.h>
#else
   PRE_COMPILED_MSG("no platform was defined")
#endif
#include <psp_api.h>

#include "madgwick.h"
#include "test_vectors.h"

#define INTERRUPT_ENABLE 1

void delay(unsigned int);


int main(void)
{
   uartInit();

   madgwickInit(INTERRUPT_ENABLE);

   for (int i = 0; i < (sizeof(ax_test_vector) / sizeof(int)); i++)
   {
      
      ax = ax_test_vector[i];
      ay = ay_test_vector[i];
      az = az_test_vector[i];
      wx = wx_test_vector[i];
      wy = wy_test_vector[i];
      wz = wz_test_vector[i];
      madgwickWriteInputVectors();

      while (!done)
      {
         delay(1000);
      }
      done = 0;

      printfNexys("%d,%d,%d,%d", q_w, q_x, q_y, q_z);
   }

   return 0;
}

void delay(unsigned int count)
{
   for(int i = 0; i < count; i++);
}