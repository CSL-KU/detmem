#!/bin/bash

mkdir ../results/rt-effect/csv
./parse-rt.pl -i ../results/rt-effect -o ../results/rt-effect/csv
mkdir ../results/figs
./rplot-fig8.R
