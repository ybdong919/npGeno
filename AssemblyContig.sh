#!/bin/bash

############# This shell script is used to output a CONTIGS file based upon all FASTQ data files.###############

############# seperates data files into multiple sets according to the "set" column in Sample_sheet.csv; And creates list-files of these groups  ##########

perl sample_process.pl

x=0
for setx in *set.txt
do
   cat $setx | egrep R1 >> "R1_"$setx
   let "x = $x +1"
done

########### caculate the number of batches to run ; 4 groups per batch #########################

h=0
u=$(echo "$x/4"|bc)
let "yu = $x%4"
if [ $yu -eq 0 ] 
then
    let "h = $h +$u"
else
     g=$(echo "$u +1"|bc)
     let "h = $h +$g"
fi

########## caculates contigs for each set  ##########################
a=-3
b=0
zu=0
for ((l=1;l<=$h;l++))
do
   let "a = $a +4"
   let "b = $b +4"
   for ((i=$a;i<=$b;i++))
   do
       let "zu = $zu+1"       
       if (($zu > $x))
       then
           break
       fi
       
       IFS=$'\n' read -d '' -r -a lines < ./"R1_"$i"_set.txt"
       y=${#lines[@]}
       y=$(printf "%.0f" $(echo "scale=2;$y*3/4" |bc))
       
       for file1 in "${lines[@]}"
       do
       	   output=$file1"_"$i".fx"
       	   fastx_collapser -Q33 -i $file1 -o $output 	       
       done
       
       curlist=fx-list_$i.txt
       ls -L *$i.fx > $curlist
       curpre=$i"fx"
       minia ${curlist} 100 $y 300000000 ${curpre} & 
   done
   wait
   
done   

########## combinate the contigs from each groups into a single contig file: allcontigs.fa ################################

if [ $x -eq 1 ]
then
    cp 1fx.contigs.fa ./Output_results/allcontigs.fa
    cp 1fx.contigs.fa allcontigs.fa
    rm *fx* *set.txt
else
    q=$(printf "%.0f" $(echo "scale=2;$x*3/4" |bc))
    ls -L *fx.contigs.fa > step2list.txt
    minia step2list.txt 100 $q 300000000 step2 
    
    mv step2.contigs.fa allcontigs.fa
    cp allcontigs.fa ./Output_results/allcontigs.fa
    rm *fx* *set.txt step2*
fi

######## cacualtes the average size (Gigabyte) of all sets  #########

ave=$(cat *.fastq|wc -c)
avex=$(echo "($ave/$x)/1000000000"|bc)
echo "The average size of every sets/groups is $avex G"




