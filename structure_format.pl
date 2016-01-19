#!/usr/bin/perl -w
use strict;

########### This Perl scritp 1) adds "Loci number" column, deletes "CONTIG", "POS" and "REF" columns ################
###########                  2) changes NA into @@                                                   ################
###########                  3) separates the contents of one column into two columns                ################
###########                  4) changes bases into number (A=1, C=2, G=3, T=4,@=-9)                  ################
###########                  5) sorts the output                                                     ################
###########                  6) transposes the data rows and columns                                 ################
###########                  7) adds the "group" column                                              ################

########### Step1_1: adds "Loci number" column, deletes "CONTIG", "POS" and "REF" columns.###########
my $in = "Output_results/Clean_SNP_Genotypes.txt";

open(NUM,'<', $in) or die;
open(NUMOUT,'>', "step1_1.txt") or die;

my @num =<NUM>;

########### addition: grep CONTIG and POS values for the line206 output##############
my @con_pos = @num;
shift @con_pos;
my @con_pos_2;
my $copo =0;
foreach (@con_pos){
    if (/^(.+)len.+\t(\d+)\t/) {
        $con_pos_2[$copo]="CON".$1."POS".$2;
        $copo += 1;
    }   
}
my $copo_title = join "\t",@con_pos_2;
my $copo_title2 = "\t"."\t".$copo_title;

$num[0] = "LOCI_NO\t".$num[0];
my $j = @num;
for (my $i=1; $i < $j; $i++){
    $num[$i]= $i."\t".$num[$i];
    
}

my @out1;
my $m=0;
foreach (@num){
    my @row = split /\t/, $_;
    splice @row, 1, 3;
    $out1[$m] = join "\t", @row;
    $m += 1;   
}

foreach (@out1){                      ### changes NA into @@ ###
    $_ =~s/NA/@@/g;
}

foreach (@out1){
    chomp $_;
    print NUMOUT "$_\n";    
}

close NUM;
close NUMOUT;

############## Step1_2: seperates the contents of one column into two columns.#######

my $all_GT = "step1_1.txt";
open(SP,'<', $all_GT) or die;

my @sp =<SP>;
my $title = $sp[0];

splice @sp, 0, 1;

my %hash;
foreach (@sp){
    chomp $_;
    if (/(\d+)\t(.+)/) {
        $hash{$1}=$2;
    }   
}

my @keys = keys %hash;
foreach (@keys){
    chomp $_;
    my @line = split //,$hash{$_};
    $hash{$_} = join "\t",@line;
    $hash{$_} =~ s/\t\t\t/\t/g;
}

######### changes bases into numbers A=1, C=2, G=3, T=4, @=-9 #######

foreach (@keys){
    chomp $_;
    $hash{$_} =~s/A/1/g;
    $hash{$_} =~s/C/2/g;
    $hash{$_} =~s/G/3/g;
    $hash{$_} =~s/T/4/g;
    $hash{$_} =~s/@/-9/g;        
}

########## changes the distance between two samples titiles (each titile occupies two columns).#####

my @title = split /\t/,$title;
my $newtitle;
foreach (@title){
    chomp $_;
    $newtitle .= $_."\t".$_."\t";  
}
chomp $newtitle;
$newtitle =~s/$title[0]\t//;



############# sorting output ########################

my @sorted_keys = sort { $a <=> $b } @keys;

open(OUTPUT,'>', 'step1_2.txt') or die;

print OUTPUT $newtitle;
print OUTPUT "\n";

foreach (@sorted_keys){
    print OUTPUT "$_\t$hash{$_}\n";
}

close OUTPUT;
close SP;


################# Step2: transposing the data rows and columns ##################

open(TRANSPOSE,'>', "step2_transposedata.txt") or die;
open(DATA,'<', "step1_2.txt") or die;
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
my $ax=@all_cells;
my @sheet;

for (my $il=0; $il<$old_columns; $il++){
    for (my $nl=$il; $nl<$ax; $nl += $old_columns){
        $sheet[$il].= $all_cells[$nl]."\t";     
    }   
}

foreach (@sheet){
    print TRANSPOSE "$_\n";    
}

close TRANSPOSE;
close DATA;

####################### Step3: adds the "group" column.########################

open(GR,'<', "Threshold_set/Sample_sheet.csv") or die;

my @gr=<GR>;
shift @gr;
my %gr_hash;
foreach (@gr){
    my @gr_row = split /,/,$_;
    my $gr_key = $gr_row[0]."_S".$gr_row[1];
    my $gr_val = $gr_row[2];
    $gr_hash{$gr_key}= $gr_val;   
}

open(INDA,'<', "step2_transposedata.txt") or die;
my @inda=<INDA>;
shift @inda;

my $x=0;
my @add_gr;
my @gr_keys = keys %gr_hash;

foreach (@inda){
    chomp $_;
    my @line = split /\t/, $_;
    
    foreach my $grk (@gr_keys){
        chomp $grk;
      if ($grk eq $line[0]) {
        $line[0] .= "\t".$gr_hash{$grk}; 
      }      
    }
    
    $add_gr[$x]=join "\t", @line;
    $x += 1;  
}


############## Output ################

open(STROUT,'>', "Output_results/Clean_genotype_STRUCTURE.txt") or die ;
print STROUT $copo_title2."\n";

foreach (@add_gr) {
    chomp $_;
    print STROUT "$_\n";
}
close GR;
close INDA;
close STROUT;
unlink qw (step1_1.txt step1_2.txt step2_transposedata.txt);




