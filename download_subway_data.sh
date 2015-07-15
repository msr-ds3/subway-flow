#!/bin/bash
#
# description:
#   fetches trip files from the citibike site http://web.mta.info/developers/data/nyct/turnstile
#
# usage: ./download_trips.sh
#
# requirements: curl or wget
#
# author: Steven Vazquez
# template taken from Jake Hofman
#

# set a relative path for the citibike data
# (use current directory by default)
DATA_DIR=.

# get a list of all turnstile data file urls
# alternatively you can use wget instead if you don't have curl
urls=`curl 'http://web.mta.info/developers/data/nyct/turnstile' | grep turnstile 

# change to the data directory
cd $DATA_DIR

# loop over each month
for url in $urls
do
    # download the txt files
    # alternatively you can use wget if you don't have curl
    # wget $url
    curl -O $url

    # define local file names
    file=`basename $url`
done
