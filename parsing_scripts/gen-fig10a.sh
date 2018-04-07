#!/bin/bash

mkdir ../results/fig10a-dram-ctrl/csv
./parse-rt-dram.pl -i ../results/fig10a-dram-ctrl -o ../results/fig10a-dram-ctrl/csv
mkdir ../results/figs
./rplot-fig10a.R