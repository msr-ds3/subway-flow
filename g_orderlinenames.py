# CURRENT
# RIVA TROPP
# 7/27/2015
# Takes Eiman's google line names data and puts lines in correct order.

import re
import sys
import os

#Changed to Old
f1 = open("OldGoogleLineNames.csv") #Open file with station names
turnstilefiles = f1.readlines()

file2 = open("new_google_data.txt", "w") #Write here.
numbers = re.compile('([0-9])')
letters = re.compile('([A-WYZ])') #All letters but X (express).
    
for x in turnstilefiles:
    fields = x.split(',')
    station = fields[2]
    arr1 = set(numbers.findall(station))
    arr2 = set(letters.findall(station))
    allnums = ''.join(sorted(arr1)) #Just join back all numbers and letters sorted.
    alllets = ''.join(sorted(arr2))
        
    file2.write(fields[0] + "," + fields[1]+ "," + allnums + alllets + "," + fields[3] + "\n")
  
file2.close()
f1.close()
