#!/usr/bin/perl -w
use strict;

################ This perl program is uesed to remove duplication and missing genotype sites.#####################


open(THRESHOLD,'<',"Threshold_set/Missing_threshold.txt") or die;
my @miss_thres =<THRESHOLD>;
chomp $miss_thres[1];
my $miss_threshold = $miss_thres[1];

my $input_gt = "Output_results/All_SNP_Genotypes.txt";
open(INPUTGT,'<', $input_gt) or die;
my @inputgt = <INPUTGT>;
my $title_gt = $inputgt[0];
chomp $title_gt;
shift @inputgt;

my %del_dup;
foreach (@inputgt){
    if (/(.+\d+\t\d+)\t(.+)/) {
        $del_dup{$2}=$1;                                     ### Remove duplicated genotype sites ###
    }   
}

my @keys = keys %del_dup;                                         
foreach (@keys){                                            ### Remove genotype sites with missing data according to "Threshold_set" settings  ###
    chomp $_;
    my @splits_keys = split /\t/,$_;
    my $mis_num =0;
    foreach my $unit(@splits_keys){      
        if ($unit eq "NA") {
            $mis_num +=1;
        }          
    }
    if ($mis_num > $miss_threshold) {
        delete $del_dup{$_};    
        }
}

open(OUTPUTGT,'>',"GT_data_without_duplication_and_overthreshold_missing.txt") or die;
print OUTPUTGT $title_gt;
print OUTPUTGT "\n";
my $k;
my $v;
while (($k,$v) = each %del_dup) {
    print OUTPUTGT "$v\t$k\n";
}
close INPUTGT;
close OUTPUTGT;
close THRESHOLD;