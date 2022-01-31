#!/bin/bash

# generate demo data and preprocess it
echo "Generating and preprocessing demo data..."

cd src
julia --project=.. gen_demo_data.jl
julia --project=.. moneyboard.jl --in=demo_data.csv --out=preprocessed_demo_data.csv
