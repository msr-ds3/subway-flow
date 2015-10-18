# CURRENT
# Riva Tropp
# 7/27/2015

import pylev
import re
import sys

#Function to give numbers larger weight for distance
def samewords(name1, name2): #Checks if two phrases consist of the same words.
    set1 = set()
    set2 = set()
    arr1 = name1.split()
    arr2 = name2.split()
    for v in arr1:
        set1.add(v)
    for x in arr2:
        set2.add(x)
    if set1 == set2:
        return -2
    else:
        return 0

def distanceoffset(name1, name2): #Checks if the numbers in the strings are the same.
    a = re.compile(r'[^0-9]*([0-9]+)[^0-9]*')

    if (not a.match(name1) and a.match(name2)) or (not a.match(name2) and a.match(name1)):
        #print >> sys.stderr, name1 + " has numbers ", name2 + " doesn't."
        return 2
    if not a.match(name1): #(and not a.match(name2)):
        return 0 #Don't affect the distance at all.

    match1 = re.findall(a, name1) #Find all the numbers in the string.
    match2 = re.findall(a, name2) #Find all the numbers in the string.
    
    set1 = set(match1)
    set2 = set(match2)

    if len(set1) != len(set2): #Different amounts of numbers in the string.
        if match1[0] != match2[0]:
            return len(max(name1, name2)) #Return the largest length as the distance so practically any match will be better.
        else:
            #print >> sys.stderr, "One of your strings has more numbers than the other, but the first pair matches."
            return 2
    else: #If there are the same amount of numbers in the string...
        if set1 != set2:
            #print >> sys.stderr, "Your numbers don't match."
            return len(max(name1, name2))
        else:
            return -5 #Same # of numbers, same numbers.

#Returns a given phrase without any of the spaces
def wordnospaces(name1):
    #Change to simple regex? Eh, don't mess with the merge.
    arr = name1.split()
    name1_ns = ""
    for x in arr:
        name1_ns = name1_ns + x
    return name1_ns

#Checks if one string is inside the other.
def isinside(name1, name2):
    if name1 in name2 or name2 in name1:
        return -2
    return 0

#Invoked when entering the files in, changes forms of 'avenue' into 'av'.
def one_ave(string1, pattern, string2):
    arr1 = string1.replace('-', ' ').rsplit()
    outbound = ""
    for x in xrange(0, len(arr1)):
        if pattern.match(arr1[x]):
            arr1[x] = string2
        outbound = outbound + " " + arr1[x]
    return outbound

#Further penalties if distance == one of the strings, to prevent overmatching small strings.
def penalize(string1, string2):
    if pylev.levenshtein(string1, string2) > min(len(string1), len(string2)):
        return 3
    return 0

################################################################################
#Actual code starts here:
################################################################################

#Files are already lowercase. (Command line).
f1 = open("ts2.txt")
f2 = open("stops2.txt") 

turns = f1.readlines()
gtfs = f2.readlines()

#Making lists to read all the station names into.

turn_terms = [] #Turnstile
gtfs_terms = [] #gtfs
orig_turn = []    
orig_gtfs = []
r_best = {}

pattern = re.compile(r'av[enu]+')

#Don't give me any PATH trains.
path = set(["NEWARK BM BW", "NEWARK C", "NEWARK HM HE", "NEWARK HW BMEBE", "HARRISON", "JOURNAL SQUARE", "GROVE STREET", "EXCHANGE PLACE", "PAVONIA NEWPORT", "CHRISTOPHER ST", "CITY   BUS"]) #Hard Coded Path trains.

#Don't give me any Staten Island Railroad stations.
SIRS = set(["Nassau", "Annadale", "Tottenville", "Stapleton", "Clifton", "Grasmere", "Old Town", "Dongan Hills", "Jefferson Av", "Grant City", "New Dorp", "Oakwood Heights", "Bay Terrace", "Great Kills", "Eltingville", "Huguenot", "Prince's Bay", "Pleasant Plains", "Richmond Valley", "Nassau", "Atlantic"])

for t in turns: #Do some formatting, put in a list, put original in an identically indexed list.
    a = t.strip('"').replace("/", ' ').replace("-", " ").strip() 
    if a not in path:
        temp1 = one_ave(a.lower(), pattern, "av")
        turn_terms.append(temp1)
        orig_turn.append(t)

f1.close()

for g in gtfs: #Same thing for GTFS
    a = g.replace('"', '').replace("/", ' ').replace("-", " ").strip()
    if a not in SIRS:
        temp1 = one_ave(a.lower(), pattern, "av")
        gtfs_terms.append(temp1)
        orig_gtfs.append(g)

f2.close()

bestmatches = {} #Where we'll store matches.

#Compare each station in the turnstile data to each station in the gtfs feed. 
for t in xrange(0, len(turn_terms)):
    for g in xrange(0, len(gtfs_terms)):
       
	#Compute distance:
        tinylist = [int(distanceoffset(turn_terms[t], gtfs_terms[g])) + int(pylev.levenshtein(gtfs_terms[g], turn_terms[t])) + int(isinside(turn_terms[t], gtfs_terms[g])) + int(samewords(turn_terms[t], gtfs_terms[g])) + int(penalize(gtfs_terms[g], turn_terms[t])), orig_gtfs[g], gtfs_terms[g], orig_turn[t]]
        
	#Make the highest default so anything better will take its place.   
        bestmatches.setdefault(turn_terms[t], [len(turn_terms[t])])
        r_best.setdefault(g, [len(gtfs_terms[g])])

	#Check against previous, update if it's a better match for both words than the things they matched before.
        if tinylist[0] < bestmatches[turn_terms[t]][0] and tinylist[0] < r_best[g]:
            bestmatches[turn_terms[t]] = tinylist
            r_best[g] = [tinylist[0], turn_terms[t]]
#            print turn_terms[t], tinylist
#            if "av n" in turn_terms[t]:
#                print bestmatches[turn_terms[t]], tinylist

f3 = open('./matchtable.txt', 'w') #Now stick it all in a nice file.

for g in bestmatches:
    f3.write(g + ",")
    for x in xrange(0, len(bestmatches[g])):
        if x == len(bestmatches[g])-1:
            f3.write(str(bestmatches[g][x]).strip().strip('"'))
        else:
            f3.write(str(bestmatches[g][x]).strip().strip('"') + ",")
    f3.write("\n")
f3.close()

#print bestmatches
