#!/bin/bash

mkdir ../results/fig8-rt-effect/csv
./parse-rt.pl -i ../results/fig8-rt-effect -o ../results/fig8-rt-effect/csv
mkdir ../results/figs
./rplot-fig8.R
