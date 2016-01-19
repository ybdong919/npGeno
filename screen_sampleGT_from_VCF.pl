#!/usr/bin/perl -w
use strict;

####################### This Perl script is used to create genotype data of every sample according to associated VCF files  ###########################


####################### Step1. Quality Control: delete Q<20 and GQ <20 ############
####################### Step2. Compute ploid                           ############

my $filename;
open(FILENAME,'<','dirfile') or die;
my @filename =<FILENAME>;
$filename = $filename[0];
chomp $filename;

my $output = "step1_".$filename;

open(INPUT,'<', $filename) or die "snowing?";
open(OUTPUT,'>', $output) or die "raining?";

my @input =<INPUT>;

my $ploid;
foreach (@input){
    chomp $_;
    if (/\d+\/\d+/) {
        my @ploid1 = split /\t/, $_;
        my $num = @ploid1;
        my $plo = $ploid1[$num-1];
        my @ploid2 = split /:/, $plo;
        my @ploid3 = split /\//, $ploid2[0];
        $ploid = @ploid3;
        last;
    }
    
}

my %QT1;
foreach (@input){
    chomp $_;
    if (/(\d+(\.)*\d*)\t\.\t\DP/) {              ### Remove the lines/sites with INDEL item or Q<20 ###
        $QT1{$_} = $1 unless $1 < 20;   
    }    
}

my @QT1_k = keys %QT1;
foreach (@QT1_k){                               ### Remove the lines/sites with GT<20 ###
    if (/GT:/) {
       my @spline = split /:/,$_;
       my $gq_v = $spline[4];
       
       if($gq_v < 20){
          delete $QT1{$_}; 
     
       }         
    }    
}

my @array = keys %QT1;

foreach (@array){
    print OUTPUT "$_\n";
}

close INPUT;
close OUTPUT;
close FILENAME;


#################### Step3. Change ALT colum into genotype #####################


my $input2 = "step1_".$filename;
my $output2 = "step2_".$filename;

open(INPUT,'<', $input2) or die "snowing?";
open(OUTPUT,'>', $output2) or die "raining?";

my @input2 = <INPUT>;

my $m =0;
foreach(@input2){
    chomp $_;
    
    if (/^(.+\.\t)([ATCG])\t(\.)(\t\d.+)/) {
        $_ = $1.$2."\t".($2 x $ploid).$4;
    }else {
        my @array1 = split /\t/,$_;
        my $num = @array1;
        
        my @array2 = split /:/,$array1[$num-1];
        my @array3 = split /\//,$array2[0];
        
        my @str_alt = split /,/,$array1[4];
        my @str =($array1[3],@str_alt);
        
        my $alt_gt;
        foreach (@array3){
            $alt_gt .= $str[$_]; 
        }
        
        $array1[4] = $alt_gt;
        my $join;
        
        foreach (@array1){
          $join .= $_."\t";  
            
        }
        chomp $join;
        $_ = $join;    
    
    }
       
}

foreach (@input2){
    print OUTPUT "$_\n";
}

close INPUT;
close OUTPUT;

################################Step4. Delete unrequired column #################
################################Step5. Change REF into genotype #################

my $input3 = "step2_".$filename;
my $output3 = "step3_".$filename;

open(INPUT,'<', $input3) or die;
open(OUTPUT, '>', $output3) or die;

my @input3 =<INPUT>;
foreach (@input3){
    my @ref1 = split /\t/,$_;
    $ref1[3] = $ref1[3] x $ploid;
    splice @ref1,6;
    splice @ref1,2,1;
    $_ = join "\t",@ref1;
    chomp $_;      
}

foreach (@input3){
    print OUTPUT "$_\n";
}

close INPUT;
close OUTPUT;

################################# Step6, Generate ID+REF #####################
################################# Step7, Generate ID+ALT+QTL #################
################################# Step8, Generate names file  ################

my $input4 = "step3_".$filename;
my $output4 = "step4_".$filename;

open(INPUT,'<', $input4) or die;
open(OUTPUT, '>', $output4) or die;
open(CONTIGS,'>>', 'align_contigs') or die;


my @input4 =<INPUT>;

my @alt_genotype;
my $i =0;
my @contigs;
foreach (@input4){
    my @line = split /\t/, $_;
    $alt_genotype[$i] = join "\t", $line[0],$line[1],$line[3],$line[4];
    $contigs[$i] = join "\t", $line[0],$line[1],$line[2];
    $i += 1;   
}

foreach (@alt_genotype){
    chomp $_;
    print OUTPUT "$_\n";
}

foreach (@contigs){
    print CONTIGS "$_\n";
}

open(FILENAME2,'>>', 'names_of_step4') or die;
print FILENAME2 $output4."\n";

close INPUT;
close OUTPUT;
close FILENAME2;
close CONTIGS;







