# CURRENT
# Riva Tropp
# 7/27/2015
# Put linenames in TS data in a specific order.
# Requires mkdir new_ts.

import re
import sys
import os

#Find all the files in the raw data, take relevant ones (turnstile_000000.txt)
turnstilefiles = os.listdir("turnstile_data")
tspattern = re.compile('turnstile_[0-9]{6}.txt')
arr0 = []
for t in turnstilefiles: #Fill an array with files from the ts directory.
    for x in tspattern.findall(t):
        arr0.append(x)

for week in arr0: 	#Open each file.
    file1 = open("turnstile_data/" + week)  
    turnstile = file1.readlines() 
    
    numbers = re.compile('([0-9])') #Each numbered line
    letters = re.compile('([A-WYZ])') #All letters except X (express).

    file2 = open("./new_ts/" + week, "w") #Open a similarly named file in a different folder to write to.
    for x in turnstile:			  
        fields = x.split(',')
        if len(fields) is 11: #There's one incomplete line in all this data. One!
            station = fields[4]
            arr1 = set(numbers.findall(station))
            arr2 = set(letters.findall(station))
            allnums = ''.join(sorted(arr1))
            alllets = ''.join(sorted(arr2))
        
            file2.write(fields[0] + "," + fields[1]+ "," + fields[2] + "," + fields[3] + "," + allnums + alllets + "," + fields[5] + "," + fields[6] + "," + fields[7] + "," + fields[8] + "," + fields[9] + "," + fields[10])  

    file2.close()
file1.close()

#Write all the things back in order separated by commas, close the files.
