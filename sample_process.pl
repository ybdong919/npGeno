#! /usr/bin/perl

###### This perl program is uesed to separate all of tested FASTQ data files into multiple sets according to the "Set" ######
######    column of the "Sample_sheet.csv" file in "Threshold_set" folder.                                                ######

my $sheetfile= "./Threshold_set/Sample_sheet.csv";
open (SHEET,'<',$sheetfile) or die "line4 die";
my @sheetfile =<SHEET>;
shift @sheetfile;

my %set_hash;
foreach (@sheetfile){
	chomp $_;
	my @line = split /,/, $_;
	$set_hash{$line[0]}=$line[4];
}

my @set_value = values %set_hash;
my $max_value = 1;

foreach (@set_value){
	chomp $_;
	if ($max_value < $_){
		$max_value = $_;
	}
}

for (my $i=1; $i< $max_value + 1; $i++){
	my $text=$i."_set.txt";
	open (DIREC,'>',$text);
	close DIREC;
}

my @set_key= keys %set_hash;
foreach (@set_key){
	chomp $_;
	my @filename= glob "$_*.fastq";
	my $nametxt=$set_hash{$_}."_set.txt";
	open (FILENAME,'>>',$nametxt) or die;
	print FILENAME "$filename[0]\n";
	print FILENAME "$filename[1]\n";
	close FILENAME;	
}

close SHEET;






