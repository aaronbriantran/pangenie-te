#!/bin/bash

awk '{
    # Get length from end of column 3 (split on "-")
    n = split($3, a, "-")
    len1 = a[n]
    vtype1 = a[3]

    # Column 15 is the number after AluY (0-indexed: fields 10-17 are the extra cols)
    # Count your fields to confirm — based on your example, it looks like field 15
    len2 = $15

    # Check within 10% and right type
    if (len1 > 0 && len2 > 0) {
        ratio = (len1 > len2) ? len1/len2 : len2/len1
        if (ratio <= 1.1) {
		if (vtype1 == $17) print $0
		}
    }
}' intersect.vcf > matches.vcf
