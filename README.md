# Deterministic Memory
Linux Kernel and gem5 modified source for Deterministic Memory

## Clone the Repository
```
git clone https://github.com/CSL-KU/detmem
cd detmem
git submodule update --init
```

## Prepare the Environment
### Gem5
Install the required tools on Ubuntu:
```
sudo apt-get update
sudo apt-get install mercurial scons swig gcc m4 python python-dev libgoogle-perftools-dev g++
```

Build command:
```
cd gem5
scons build/ARM/gem5.opt -jN
```
N is the number of hardware threads available on your computer.

Build the terminal:
```
cd util/term
make
```
___

### The Linux Kernel
Install the ARM GCC cross compiler version 4.8:
```
sudo apt-get install gcc-4.8-arm-linux-gnueabihf
```
If the installation did not create the link to 'arm-linux-gnueabihf-gcc-4.8', you should do it by yourself:
```
cd /usr/bin
sudo ln arm-linux-gnueabihf-gcc-4.8 arm-linux-gnueabihf-gcc
```

Build the kernel:
```
cd gem5-linux
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -jN
```
___

## Running the Simulations
### Boot the OS and Create a Checkpoint

Use the command below to run gem5 and boot Linux:

```
./build/ARM/gem5.opt -d m5out configs/example/fs.py --disk-image=[absolute/path/to/full_system_images/disks/linux-arm-ael.img] --num-cpus=4 --caches --l2cache --mem-size=512MB --kernel=[absolute/path/to/gem5-linux/vmlinux] --machine-type=VExpress_EMM --dtb-file=[absolute/path/to/gem5-linux/arch/arm/boot/dts/vexpress-v2p-ca15-tc1-gem5_4cpus.dtb] --mem-type=lpddr2_s4_1066_x32 --checkpoint-at-end
```

Open another terminal window and run the command below. 'm5term' connects to the gem5 and serves as a console for the simulated system. 
```
./util/term/m5term [port number]
```
The port number is printed on the screen by gem5 when it starts running. It is usually 3456.

After the boot procedure finishes and the system asks for the password, type 'root' and press enter. Then, enter the command below to enable DM-aware PALLOC:
```
./palloc-gen-bal.sh
```
The script assigns different bins to each Cgroups' partition and the result is printed on the screen. After the script finishes and the prompt is shown, go back to the terminal where gem5 is running and press Ctrl-C. This will save a checkpoint in the 'm5out' directory.

### Batch Run

We use the shell script "sv-rtas.sh" to launch multiple simulation jobs. The simulation jobs to be launched are listed in the variable "arr". The names of the jobs and their associated shell command (which will be executed in the guest system shell) can be found in the Python script:
```
./configs/spec2006/spec_fs.py
```
To launch the jobs we simply run this command:
```
./sv-rtas.sh
```