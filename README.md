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

### The Linux Kernel
Install the ARM GCC cross-compiler version 4.8:
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

## Simulations
### Boot the OS and Create a Checkpoint

Use the command below to run gem5 and boot Linux:
```
cd gem5
./gen-checkpoint.sh
```

Open another terminal window and run the command below. 'm5term' connects to gem5 and serves as a console for the simulated platform. 
```
./util/term/m5term [port number]
```
The port number is printed on the screen where gem5 is running. It is usually 3456.

When the boot procedure is complete, and the system asks for the password, type 'root' and press enter. Then, enter the command below to enable PALLOC:
```
./palloc-gen-bal.sh
```
The script assigns different bins to each Cgroups' partition, and the result is printed on the screen. After the script is finished and prompt is shown, go back to the first terminal, where gem5 is running, and press Ctrl-C. This will save a checkpoint in the 'm5out' directory.

### Running the Simulations

Use the following command to run the simulations in Figure 8:
```
cd gem5
./run-fig8-rt-effect.sh m5out/cpt.*
```
This script launches 48 simulations in parallel and saves the result in 'detmem/results/fig8-rt-effect'. It takes about 12 hours to finish this run on a machine with 48 hardware threads. Each gem5 instance needs about 250MB memory. As we launch 48 threads, this run needs about 12GB memory. 

To run the simulations in figures 9 and 10.a, use the the following commands:
```
./run-fig9-be-effect.sh m5out/cpt.*
```
```
./run-fig10a-dram-ctrl.sh m5out/cpt.*
```
These runs should take about 24 and 12 hours to finish, respectively. The results will be saved in 'detmem/results/fig9-be-effect' and 'detmem/results/fig10a-dram-ctrl'.
___

## Generating the Figures

Install R on your system:
```
sudo apt-get install r-base
```
 After all of the runs are finished, use this command to generate the figures:
 ```
 cd parsing_scripts
 ./gen-fig-all
 ```
The figures will be saved in 'detmem/results/figs'.
 
Alternatively, you can generate the figures for each run separately by executing the scripts 'gen-fig8.sh', 'gen-fig9.sh', or 'gen-fig10a.sh'.
 
