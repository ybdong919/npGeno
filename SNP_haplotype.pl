#!/usr/bin/perl -w
use strict;

################# This Perl script is used to create a haplotype SNP data file according to the genotype data file and related VCF fils. #############

############### Step1: make a file of sample-names #############

open(SAMNAM,'<', "names_of_step4") or die;
my @samnam =<SAMNAM>;

for (@samnam){
    chomp $_;
    if (/^(step4_)(.+)/) {
        $_=$2;
    }
}
my $samnam_num = @samnam;
my $panum=0;
my @samnam_part;
for (@samnam){
    if (/^(.+S\d+).+/) {
        $samnam_part[$panum]=$1;
        $panum +=1;
    }    
}

close SAMNAM;

################ Step2: Calling a sub_program for transposing the data between rows and columns.##########
################ Step3: Make SNP halotype corresonding with genotype.####################################

my @inputfiles = ("Output_results/All_SNP_Genotypes.txt","Output_results/Clean_SNP_Genotypes.txt");
my @outputfiles = ("Output_results/All_SNP_hap.txt","Output_results/Clean_SNP_hap.txt");
my $xnew=0;
foreach (@inputfiles){
    chomp $_;
    my $dire= $_;
    &transpose ($dire);                                      ###  calling a sub_program for transposing ###
    
    open(HAINPUT,'<', "transposed_data.txt") or die;        ### make SNP halotype corresonding with Genotype ### 
    my @samples =<HAINPUT>;

    chomp $samples[0];
    chomp $samples[1];
    my @locus= split /\t/, $samples[0];
    my @pos= split /\t/, $samples[1];
    my $tit_loc = join "\t", @locus;
    my $tit_pos = join "\t", @pos;

    chomp $samples[2];
    my @refe= split /\t/, $samples[2];
    my $reftit_fir= $refe[0];
    shift @refe;
    foreach (@refe){
        my @ref_cel= split //,$_;
        $_ = $ref_cel[0];
    }
    my $reftit_sec= join "\t", @refe;
    my $tit_ref =$reftit_fir."\t".$reftit_sec;

    my %sam_hash;
    splice @samples,0,3;
    for (@samples){
        chomp $_;
        if (/^(.+S\d+)\t(.+)/) {
            $sam_hash{$1}=$2;
        }    
    }

    my @sam_keys = keys %sam_hash;

    foreach my $x_samp(@sam_keys){
        my %vcf_hash;
        chomp $x_samp;
    
        for (my $i=0; $i < $samnam_num; $i++){
            chomp $samnam_part[$i];
            if ($samnam_part[$i] eq $x_samp) {
                chomp $samnam[$i];
                open(SAMPLE,'<',$samnam[$i] ) or die;
                my @vcf =<SAMPLE>;
                foreach (@vcf){
                    if (/^(.+\d+)\t(\d+)\t(\.)\t(.+)\tDP/) {
                        my $first=$1."_".$2;
                        my @second= split /\t/, $4;
                        shift @second;
                        my $sec = shift @second;
                        if ($sec =~ /[A-Z]/) {
                            $vcf_hash{$first}=$sec;
                        }
                        if ($sec =~ /,/) {
                            my @dou = split /,/, $sec;
                            $vcf_hash{$first}=$dou[0];
                        }
                    } 
                }
                close SAMPLE;
            }   
        }
    
        my @samp_line= split /\t/, $sam_hash{$x_samp};
        my $column=0;
        for (@samp_line){
            $column += 1;
            chomp $_;
            if (/NA/) {
                $_="00";
            }
            
            my @cell = split //, $_;
            chomp $cell[0];
            my $alp_num=@cell;
        
            my $shouldbe;
            for (my $i=0; $i < $alp_num; $i++){
                $shouldbe .= $cell[0];
            }
        
            if ($_ eq $shouldbe) {
                $_=$cell[0];
            }else {
                chomp $locus[$column];
                chomp $pos[$column];
                my $site =$locus[$column]."_".$pos[$column];
                $_=$vcf_hash{$site};   
            }
        }
        my $new_line = join "\t",@samp_line;
        $sam_hash{$x_samp}=$new_line;
    }

    open(HAP,'>', "pre_Clean_SNP_hap.txt") or die;
    print HAP "$tit_loc\n";
    print HAP "$tit_pos\n";
    print HAP "$tit_ref\n";

    my $hk;
    my $hv;
    while (($hk,$hv)= each %sam_hash) {     
        print HAP "$hk\t$hv\n";
    }
    close HAP;
    close HAINPUT;

    my $direx= "pre_Clean_SNP_hap.txt";                     ### calling the sub_program for transposing again ###
    &transpose ($direx);
    my $oldnam="transposed_data.txt";

    rename $oldnam => $outputfiles[$xnew];
    $xnew +=1;
}


#######################################################################################################
###############           A sub_program to transpose rows and columns          ######################## 
#######################################################################################################
sub transpose {
    
    open(TRANSPOSE,'>', "transposed_data.txt") or die;
    open(DATA,'<', $_[0] ) or die;
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
}






