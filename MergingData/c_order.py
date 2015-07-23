import re
import sys
import os

turnstilefiles = os.listdir("../turnstile_data")
tspattern = re.compile('turnstile_[0-9]{6}.txt')
arr0 = []
for t in turnstilefiles:
    for x in tspattern.findall(t):
        arr0.append(x)

for week in arr0:
    file1 = open("../turnstile_data/" + week)
    file2 = open("./new_ts/" + week, "w")
    turnstile = file1.readlines() 
    
    numbers = re.compile('([0-9])')
    letters = re.compile('([A-WYZ])')
    brokenfile = re.compile('(141206)')

    if len(brokenfile.findall(week)) <= 0:
        for x in turnstile:
            fields = x.split(',')
            station = fields[4]
            arr1 = set(numbers.findall(station))
            arr2 = set(letters.findall(station))
            allnums = ''.join(sorted(arr1))
            alllets = ''.join(sorted(arr2))
        
            file2.write(fields[0] + "," + fields[1]+ "," + fields[2] + "," + fields[3] + "," + allnums + alllets + "," + fields[5] + "," + fields[6] + "," + fields[7] + "," + fields[8] + "," + fields[9] + "," + fields[10] + "," + "\n")
  
    file2.close()
file1.close()
