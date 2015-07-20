#!/usr/bin/python

import csv

# get turnstyle stations
turnstyle_station = [] # list for turnstyle stations
with open('turnstyle_df.csv') as csvfile:
	turnstyle_station = csv.reader(csvfile)
	for row in turnstyle_station:
        	print ', '.join(row)

