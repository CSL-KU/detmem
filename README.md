# Deterministic Memory
Linux Kernel and gem5 modified source for Deterministic Memory

## Preparing the Environment
### Gem5
**Install the required tools:**
```
sudo apt-get update; sudo apt-get upgrade
sudo apt-get install mercurial scons swig gcc m4 python python-dev libgoogle-perftools-dev g++
```
**Build command**
```
cd gem5
scons build/ARM/gem5.opt -j48
```
___

### The Linux Kernel
**Install the GCC cross compiler**
```
sudo apt-get install  gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu
```
**Build the kernel**
```
cd linux-kernel
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- vexpress_gem5_server_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
```
___

### Get the File System
```
mkdir full_system_images
cd full_system_images
wget http://www.m5sim.org/dist/current/arm/arm-system-2013-07.tar.bz2
tar -xjf  arm-system-2013-07.tar.bz2
```
The EEMBC and SD-VBS benchmarks must be compiled and the binaries must be copied to the file system.
___

### Benchmarks
Links to get EEMBC AutoBench and SD-VBS:
[EEMBC AutoBench](http://www.eembc.org/benchmark/automotive_sl.php)
 and 
[SD-VBS](http://parallel.ucsd.edu/vision)


## Running the Simulations
### Boot the OS and Make a Checkpoint

In order to run the benchmarks, first, the OS must be booted on the gem5. We use the "atomic" CPU model for this purpose since it runs much faster. This model is not indented to measure timing but since we do not care about timing while booting Linux, it is acceptable to use this model. 

```
./build/ARM/gem5.opt -d m5out configs/example/fs.py --disk-image=[path to file sysytem image/linux-arm-ael.img] --num-cpus=4 --caches --l2cache --mem-size=512MB --kernel=[path to the kernel/vmlinux] --machine-type=VExpress_EMM --dtb-file=[path to the gem5 directory/gem5/gem5-linux/arch/arm/boot/dts/vexpress-v2p-ca15-tc1-gem5_4cpus.dtb] --mem-type=lpddr2_s4_1066_x32 --checkpoint-at-end
```

To attach the terminal and see the kernel output, this command must be run under the gem5 directory.
```
./util/term/m5term [port number]
```
The port number is printed on the screen by gem5 when it starts running. It is usually 3456.

At the end of the boot, it asks for the password. The password is "root". After acknowledging it, the command prompt is shown. Then, we go back to gem5 and press Ctrl-C. This ends the simulation and creates a checkpoint in "m5out" directory.

### Batch Run

We use the shell script "sv-rtas.sh" to launch multiple simulation jobs. The simulation jobs to be launched are listed in the variable "arr". The names of the jobs and their associated shell command (which will be executed in the guest system shell) can be found in the Python script:
```
./configs/spec2006/spec_fs.py
```
To launch the jobs we simply run this command:
```
./sv-rtas.sh
```