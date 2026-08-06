#!/bin/bash

bcftools view -i "GT='alt' && ID ~ 'INS'" ${1} | awk 'BEGIN{FS="\t"}
{
  print ">" $3
  print $5
}' > results/pangenie_total_ins.fa