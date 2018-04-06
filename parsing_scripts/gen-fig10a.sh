#!/bin/bash

mkdir ../results/dram-ctrl/csv
./parse-rt-dram.pl -i ../results/dram-ctrl -o ../results/dram-ctrl/csv
mkdir ../results/figs
./rplot-fig10a.R