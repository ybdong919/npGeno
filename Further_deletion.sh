#!/bin/bash

perl GT1_del_dupl_missing.pl
perl GT2_del_at_contig_pos.pl
rm GT_data_without_duplication_and_overthreshold_missing.txt 
echo "Further_deletion OVER"
