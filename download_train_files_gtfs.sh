#!/bin/bash
#
# description:
#   fetches the subway data - updated june 16th 2015
#
# usage: ./download_trains_files_gtfs.sh
#
# requirements: curl or wget
#
#author:eiman ahmed
#template developed by jake hofman


# set a relative path for the citibike data
# (use current directory by default)
DATA_DIR=.

#url to get info from 
#downloads a zip file full of files we need
wget "http://web.mta.info/developers/data/nyct/subway/google_transit.zip"

#change to directory of data
cd $DATA_DIR

# unzip and get all files need to run the GTFS R Scripts
unzip google_transit.zip 




