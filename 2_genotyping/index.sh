#!/bin/bash
#SBATCH --job-name=pangenie_index
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --time=2:30:00
#SBATCH --output=/scratch/atran/final/3_pangenie/logs/3_index.log
#SBATCH --error=/scratch/atran/final/3_pangenie/logs/3_index.err


# Choose one of the following fashion
#SBATCH --mem=150GB

set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

# compute requirements estimated from the PanGenie documentation

# index using the reference genome and the multi-allelic/graph vcf
./binaries/PanGenie-index -v ./input_files/multiallelic.vcf -r ./input_files/CHM13v11Y.fa -t 24 -o ./index/pangenome
