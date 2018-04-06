#!/bin/bash

mkdir ../results/be-effect/csv
./parse-cr.pl -i ../results/be-effect -o ../results/be-effect/csv
mkdir ../results/figs
./rplot-fig9.R