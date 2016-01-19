#!/usr/bin/perl -w
use strict;

############### This Perl script sorts the whole genotype data file.###########################

my $input_gt = "All_GTs.txt";
open(INPUTGT,'<', $input_gt) or die;
my @inputgt = <INPUTGT>;
my $title_gt = $inputgt[0];
chomp $title_gt;
shift @inputgt;

my %sorthash;
foreach (@inputgt){
    if (/(\d+)__len__\d+\t(\d+)\t.+/) {       
        $sorthash{$1}{$2}=$_;                                             ### define a multi-dimension hash ###
    }       
}

my $i=0;
my @value;
foreach my $key1 (sort {$a<=>$b} keys %sorthash){                         ### using Multi-dimension hash for sorting ###
    foreach my $key2 (sort {$a <=> $b} keys %{$sorthash{$key1}}){
        $value[$i]=$sorthash{$key1}{$key2};
        $i +=1;
    }
}

open(OUTPUTGT,'>',"Output_results/All_SNP_Genotypes.txt") or die;
print OUTPUTGT $title_gt;
print OUTPUTGT "\n";
foreach (@value){
   chomp $_;
   print OUTPUTGT "$_\n";
}

close INPUTGT;
close OUTPUTGT;




