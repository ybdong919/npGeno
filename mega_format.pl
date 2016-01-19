#!/usr/bin/perl -w
use strict;


########### This perl  is use for 1) adds "Loci number" column, deletes "CONTIG", "POS" and "REF" columns #############
###########                       2) 0 change into -                        ########################################
###########                       3) transposes between rows and columns        ########################################
###########                       4) transforms into MEGA format              ########################################


########### Step1: Adds "Loci number" column, deletes "CONTIG", "POS" and "REF" columns###################

my $in = "Output_results/Clean_SNP_hap.txt";

open(NUM,'<', $in) or die;
open(NUMOUT,'>', "MEGA_step1.txt") or die;

my @num =<NUM>;                          
$num[0] = "LOCI_NO\t".$num[0];         ### Adds "Loci number" column ###
my $j = @num;
for (my $i=1; $i < $j; $i++){
    $num[$i]= $i."\t".$num[$i];
    
}

my @out1;                            #### Deletes "CONTIG", "POS" and "REF" columns ###
my $m=0;
foreach (@num){
    my @row = split /\t/, $_;
    splice @row, 1, 3;
    $out1[$m] = join "\t", @row;
    $m += 1;   
}
foreach (@out1){                     #### 0 changed into - ###
    $_ =~s/0/-/g;
}

foreach (@out1){
    chomp $_;
    print NUMOUT "$_\n";
    
}
close NUM;
close NUMOUT;


############## Step2: Transposes the data between rows and columns.###############

open(TRANSPOSE,'>', "MEGA_step2_transpose.txt") or die;
open(DATA,'<', "MEGA_step1.txt") or die;
my @data =<DATA>;
foreach (@data){
    $_ =~s/\s+$//g;
}
my $old_rows = @data;
my @for_columns = split /\t/, $data[0];
my $old_columns = @for_columns;
my $wholestring;

foreach (@data){
   chomp $_; 
   $wholestring .= $_."\t"; 
}

my @all_cells = split /\t/, $wholestring;
my $a=@all_cells;
my @sheet;

for (my $il=0; $il<$old_columns; $il++){
    for (my $nl=$il; $nl<$a; $nl += $old_columns){
        $sheet[$il].= $all_cells[$nl]."\t";     
    }   
}

foreach (@sheet){
    print TRANSPOSE "$_\n";
    
}
close TRANSPOSE;
close DATA;

########################### Step3: Output to MEGA format########################

open(MEGAFORM,'>', "Output_results/Clean_haplotype_MEGA.txt") or die;
open(OUME,'<', "MEGA_step2_transpose.txt") or die;
my @oume =<OUME>;

shift @oume;

my @megaform;
my $u=0;

foreach (@oume){
    chomp $_;
    my @ouline = split /\t/,$_;
    
    $megaform[$u] = "#".$ouline[0];
    
    shift @ouline;
    my $seq = join "",@ouline;
    chomp $seq;
    my $leng = length $seq;
    my @part;
    my $p = 0;
    for (my $i=0; $i<$leng; $i += 60){
        $part[$p]=substr($seq, $i, 60);
        $p += 1;
    }
    
    foreach my $part (@part){
      $megaform[$u+1] .= $part."\n"; 
    }
    
    chomp $megaform[$u+1];
    $u += 2;
}

print MEGAFORM "#mega\n!Title SNP haplotype \n!Format DataType=DNA indel=-\n";
foreach (@megaform){
  chomp $_;
  print MEGAFORM "$_\n";
    
}

close MEGAFORM;
close OUME;
unlink qw (MEGA_step1.txt MEGA_step2_transpose.txt);