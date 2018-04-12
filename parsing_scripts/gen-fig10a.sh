#!/bin/bash

mkdir -p ../results/fig10a-dram-ctrl/csv
./parse-rt-dram.pl -i ../results/fig10a-dram-ctrl -o ../results/fig10a-dram-ctrl/csv
mkdir -p ../results/figs
./rplot-fig10a.R