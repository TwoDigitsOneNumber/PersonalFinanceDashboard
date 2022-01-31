#!/bin/bash

cd src
julia --project=.. index.jl --file_name=preprocessed_data.csv
