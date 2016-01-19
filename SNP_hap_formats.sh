#!/bin/bash
perl SNP_haplotype.pl
perl mega_format.pl
perl structure_format.pl
rm *.vcf *.bt2 *.fai *name* dirfile *align_contigs All_GTs.txt
rm allcontigs.fa pre_Clean_SNP_hap.txt
echo "SNP_hap&Formats OVER"
