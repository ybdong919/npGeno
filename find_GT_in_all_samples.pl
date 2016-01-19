#!/usr/bin/perl -w
use strict;

############## This Perl script is uesed to combine the genotype data of all tested samples into a single genotype data file.#####################


open(CONTIGS,'<','align_contigs') or die;
my @contigs = <CONTIGS>;
close CONTIGS;

my %list;
foreach (@contigs){
    chomp $_;
    if (/(.+\d+)\t(\w+)/) {
        $list{$1} = $2;
    }    
}

open(STEP1,'<', 'names_of_step4') or die;
my @namefile_step1 = <STEP1>;
close STEP1;

my @list =keys %list;

foreach (@namefile_step1){
    chomp $_;
    open(FILE,'<', $_) or die;
    my @input =<FILE>;
    close FILE;
    
    my %data;
    foreach (@input){
      chomp $_;
      if (/^(.+\t\d+)\t(.+)/) {
         my $keys = $1;
        $data{$keys}=$2; 
      }  
    }
    
    foreach (@list){
        chomp $_;
        my $var = $data{$_};
        if (defined($var)) {
            $list{$_} .= "\t".$data{$_};
        }else {
            $list{$_} .="\tNA\t0";
        }
    } 
}


################### Deletes QUAL columns ####################

my @k2 = keys %list;
foreach (@k2){
    my @line = split /\t/, $list{$_};
    my $stri;
    foreach (@line){
        if (/^[^0-9]/){
          $stri .= "$_\t"; 
        }    
    }
    $list{$_} = $stri;   
}


################ Deletes consensus sites ###################

my $j = @namefile_step1;
my @k = keys %list;
   
foreach (@k){
     my @line = split /\t/, $list{$_};
     my $con;
     
     shift @line;
     foreach (@line){
        if ($_ ne 'NA') {
            $con = $_;
            last;
        }
        
     }
     
     my $num =0;
     foreach (@line){
        if ($_ eq $con || $_ eq "NA") {
            $num += 1;
        }   
     }
     if ($num == $j) {
        delete $list{$_};
     }    
}

################ Outputs the result ###################
my @titles;
my $x = 0;
foreach (@namefile_step1){
    if (/step4_(.+S\d+)_L/) {
        $titles[$x] = $1;
        $x += 1;
    }
}

open(OUTPUT,'>', 'All_GTs.txt') or die;

print OUTPUT "CHROM\tPOS\tREF\t";
foreach (@titles){
    print OUTPUT "$_\t";
    
}
print OUTPUT "\n";
my $k;
my $v;
while (($k,$v)= each %list) {
       
    print OUTPUT "$k\t$v\n";
}
close OUTPUT;











