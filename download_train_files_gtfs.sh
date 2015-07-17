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

# set current directory as place to install zip file 
DATA_DIR=.

#downloads a zip file full of files we need
wget "http://web.mta.info/developers/data/nyct/subway/google_transit.zip"

#change to directory of data
cd $DATA_DIR

#makes directory to download files into
mkdir GTFSData

# unzip and get all files need to run the GTFS R Scripts
unzip google_transit.zip -d GTFSData







