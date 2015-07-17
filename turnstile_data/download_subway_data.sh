#!/bin/bash
#
# description:
#   fetches subway data from http://web.mta.info/developers/turnstile.html
#
# usage: ./download_subway_data.sh
#
# requirements: curl or wget
#
# author: Subway Surfers
#################################################################################################
# Pre-processing
#################################################################################################
# The folloing steps were taken to extract data:
# * Copied and pasted source code to text file titled 'mta_html.txt'
# * deleted all text before and after line 202 of source code beginning with 
# '<a href="data/nyctturnstile/turnstile_150711.txt">...'
# ran 'awk -f readsample.awk' in terminal to format data nicely
# ran this script to extract data .txt files

# loop over each month
cat mta_data_files.txt | while read line
do
    # download turnstile data
    # links to files stored locally in 'mta_html.txt'
    $(wget http://web.mta.info/developers/data/nyct/turnstile/$line) 
done
