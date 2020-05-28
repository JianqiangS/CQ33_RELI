import os
import time
for i in range(0,2):
   ret_str = os.popen("sudo busybox devmem 0x51f00000").read()
   ret_int = int(ret_str, 16)
   temp = (ret_int / 65536.0) / 0.00199451786 - 273.15
   fpga_temp = str(int(temp))
   output = open("fpga_temp.log","w")
   output.writelines(fpga_temp)
#   print("FPGA Temperature : {}".format(temp))
   time.sleep(1)
