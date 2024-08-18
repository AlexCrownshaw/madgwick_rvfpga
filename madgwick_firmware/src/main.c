#if defined(D_NEXYS_A7)
   #include <bsp_printf.h>
   #include <bsp_mem_map.h>
   #include <bsp_version.h>
#else
   PRE_COMPILED_MSG("no platform was defined")
#endif
#include <psp_api.h>

#include "madgwick/madgwick.h"
#include "madgwick/test_vectors.h"
#include "mpu6050/MPU6050.h"

#define INTERRUPT_ENABLE 1

// int main(void)
// {
//    uartInit();

//    madgwickInit(INTERRUPT_ENABLE);

//    for (int i = 0; i < (sizeof(ax_test_vector) / sizeof(int)); i++)
//    {
      
//       ax = ax_test_vector[i];
//       ay = ay_test_vector[i];
//       az = az_test_vector[i];
//       wx = wx_test_vector[i];
//       wy = wy_test_vector[i];
//       wz = wz_test_vector[i];
//       madgwickWriteInputVectors();

//       while (!done)
//       {
//          delay(1000);
//       }
//       done = 0;

//       printfNexys("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", ax, ay, az, wx, wy, wz, q_w, q_x, q_y, q_z);
//    }

//    return 0;
// }

int main(void)
{
   uartInit();
   madgwickInit(INTERRUPT_ENABLE);
   MPU6050_init(F_CLK_100KHZ, AFS_SEL_8G, FS_SEL_500, DLPF_CONFIG_4);

   while (1)
   {
      MPU6050_get_raw_sample();

      ax = axRaw;
      ay = ayRaw;
      az = azRaw;
      wx = wxRaw;
      wy = wxRaw;
      wz = wzRaw;

      madgwickWriteInputVectors();

      while (!done)  // Simulate other useful threads of execution
      {
         delay(1000);
      }
      done = 0;

      printfNexys("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", ax, ay, az, wx, wy, wz, q_w, q_x, q_y, q_z);
   }
}