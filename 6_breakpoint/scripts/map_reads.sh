#!/bin/bash
#SBATCH --job-name=vg_giraffe
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=01:00:00
#SBATCH --output=logs/map_reads.log
#SBATCH --error=logs/map_reads.err
#SBATCH --mem=15G

#TODO: fix compute requests

read1=''
read2=''
index_prefix=results/create_diploid_graphs/${1}/${1}

#TODO fix pathing to inputs, wait for other scripts first
# basically just seeing if the xg is created with the right naming convention

mkdir -p results/map_reads

vg giraffe \
   --progress \
   -t "${SLURM_CPUS_PER_TASK}" \
   -d "${index_prefix}.dist" \
   -z "${index_prefix}.shortread.zipcodes" \
   -m "${index_prefix}.shortread.withzip.min" \
   -x "${index_prefix}.xg" \
    -i -f "${read1}" -f "${read2}" \
    -o BAM -b default > "results/map_reads/${1}.bam"