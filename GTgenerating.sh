#!/bin/bash

bowtie2-build allcontigs.fa bt2ref
ref=allcontigs.fa
samtools faidx $ref

for file1 in *R1_001.fastq
do
   file2=$(echo ${file1} | sed 's/R1/R2/') 
   
   bowtie2 -x bt2ref -1 $file1 -2 $file2 -S $file1.sam --no-unal 
   samtools view -Sbt ${ref}.fai ${file1}.sam > ${file1}.bam
   samtools sort ${file1}.bam ${file1}.sorted
   samtools index ${file1}.sorted.bam
   samtools mpileup -uf $ref ${file1}.sorted.bam | bcftools view -cg -> ${file1}.vcf
   rm *.bai *.bam *.sam

   echo -e "${file1}.vcf" > dirfile
   perl screen_sampleGT_from_VCF.pl
   rm *step1*.vcf *step2*.vcf
    
done

perl find_GT_in_all_samples.pl
perl sort_GT.pl

