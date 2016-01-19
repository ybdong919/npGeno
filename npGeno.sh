#!/bin/bash


echo "npGeno.sh has started..."
echo "AssemblyContig.sh has started..."
./AssemblyContig.sh
echo "GTgenerating.sh has started..."
./GTgenerating.sh
echo "Further_deletion.sh has started..."
./Further_deletion.sh
echo "SNP_hap_formats.sh has started..."
./SNP_hap_formats.sh
echo "npGeno.sh is finished"