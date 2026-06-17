#author Aaron Tran
#date 16 June 2026
#use Take a bcf, split up each chromosome into chunks, phase common variants in it, and then ligate it all back together
#input $1 is the bcf of one person genotyped by PanGenie, $2 is the map file
#output $3 is the scaffold bcf output, 
#args
#compute

#!/bin/bash

#load modules
ml bedtools
#get SHAPEIT somehow

#WARNING: not sure if filter-maf is possible!

phase_common \
   --input a bcf \
   --filter-maf something \
   --region something \
   --map the map \
