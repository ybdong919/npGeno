#!/usr/bin/perl -w
use strict;

####### This Perl program is used to remove the genotype sites located at both ends of each contig according to "Threshold-set" settings ###########

open(THRESHOLD,'<',"Threshold_set/SNP_position_threshold.txt") or die;
my @SNP_thres =<THRESHOLD>;
chomp $SNP_thres[1];
my $SNP_threshold = $SNP_thres[1];

my $input_gt = "GT_data_without_duplication_and_overthreshold_missing.txt";
open(INPUTGT,'<', $input_gt) or die;
my @inputgt = <INPUTGT>;
my $title_gt = $inputgt[0];
chomp $title_gt;
shift @inputgt;

my %mulhash;
my %outhash;
foreach (@inputgt){
    if (/(\d+)__len__(\d+)\t(\d+)\t.+/) {       
        $mulhash{$1}{$3}=$2;                                 ### Define a multi-dimension hash ###
        $outhash{$1}{$3}=$_;
    }       
}

my $i=0;
my @value;
foreach my $key1 (sort {$a<=>$b} keys %mulhash){               ### Using Multi-dimension hash for sorting and deleting SNPs located at both ends of each contig ###
    
    foreach my $key2 (sort {$a <=> $b} keys %{$mulhash{$key1}}){
        
            if (($key2 > $SNP_threshold)&&($key2 < ($mulhash{$key1}{$key2} - $SNP_threshold))) {
                 $value[$i]=$outhash{$key1}{$key2};
                 $i +=1;
            }            
    }
}

open(OUTPUTGT,'>',"Output_results/Clean_SNP_Genotypes.txt") or die;
print OUTPUTGT $title_gt;
print OUTPUTGT "\n";
foreach (@value){
   chomp $_;
   print OUTPUTGT "$_\n";
}

close INPUTGT;
close OUTPUTGT;
