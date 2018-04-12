#!/bin/bash

mkdir -p ../results/fig9-be-effect/csv
./parse-cr.pl -i ../results/fig9-be-effect -o ../results/fig9-be-effect/csv
mkdir -p ../results/figs
./rplot-fig9.R