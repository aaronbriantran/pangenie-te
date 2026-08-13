#!/bin/bash

bcftools view -H -i "GT='alt' && ID ~ 'INS'" ${1} | awk 'BEGIN{FS="\t"}
{
  print ">" NR
  print $5
}' > results/pangenie_total_ins.fa
