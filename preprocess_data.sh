#!/bin/bash

cd src
julia --project=.. moneyboard.jl --in=Moneyboard.csv --out=preprocessed_data.csv