import pylev
import re
import sys

#Function to give numbers larger weight for distance
def distanceoffset(name1, name2):
    a = re.compile(r'[^0-9]*([0-9]+)[^0-9]*')

    if not a.match(name1):
        #print >> sys.stderr, name1 + " doesn't have any numbers!"
        return 0
    if not a.match(name2):
        #print >> sys.stderr, name2 + " doesn't have any numbers!"
        return 0
    match1 = re.findall(a, name1)
    match2 = re.findall(a, name2)
    if len(match1) != len(match2):
        if match1[0] != match2[0]:
            #print >> sys.stderr, name1 + " doesn't match " + name2 + " at all."
            return len(max(name1, name2))
        else:
            #print >> sys.stderr, "One of your strings has more numbers than the other, but the most of them match."
            return 2
    else:
        for x in xrange(0, len(match1)):
            if match1[x] != match2[x]:
                #print >> sys.stderr, "Your numbers don't match."
                return len(max(name1, name2))
            else:
                #print >> sys.stderr, name1 + " and " + name2 + " match!"
                return 0

#Returns a given phrase without any of the spaces
def wordnospaces(name1):
    offset = 0
    foo = name1.split()
    name1_ns = ""
    for x in foo:
        name1_ns = name1_ns + x
    return name1_ns

#Files are already lowercase. (Command line).
f1 = open("./lc_ts_names.txt") #Station names from turnstile
f2 = open("./lc_gtfs_names.txt") #Station names from google feed
#This is a relational path, so you should change it to your lowercase station names.

turns = f1.readlines()
google = f2.readlines()

#Making lists to read all the station names into.
ts_terms = []   
gtfs_terms = []

#Get rid of trailing whitespace, append all station names to a list.
for turn in turns:
    temp1 = turn.strip()
    ts_terms.append(temp1)

for page in google:
    temp2 = page.strip()
    gtfs_terms.append(temp2)

f1.close()
f2.close()


perfectmatches = {}
bestmatches = {}
nextbestmatches = {}

#Compare every station in the turnstile feed with every station in the google feed. 

for g_station in gtfs_terms:		
    for ts_station in ts_terms:	
	turnstile = wordnospaces(ts_station)
        google = wordnospaces(g_station)
        if pylev.levenshtein(turnstile, google) == 0: 	#If the distance is 0, we have a perfect match!
            tinylist1 = [0, ts_station]
            perfectmatches[g_station] = tinylist1
            break
        else:
            bestmatches.setdefault(g_station, [len(g_station)])
            nextbestmatches.setdefault(g_station, [len(g_station)])
            tinylist = [int(distanceoffset(ts_station, g_station)) + int(pylev.levenshtein(turnstile, google)), ts_station]

            if tinylist[0] < bestmatches[g_station][0]:
                nextbestmatches[g_station] = bestmatches[g_station]
                bestmatches[g_station] = tinylist


f3 = open('./matchtable.txt', 'w')
for p in perfectmatches:
	print >> f3, p,",", perfectmatches[p][0], ",", perfectmatches[p][1]

for g in bestmatches:
    for x in xrange(1, len(bestmatches[g]), 2):
        print >> f3, g, "," , bestmatches[g][x-1], "," , bestmatches[g][x]


for g in nextbestmatches:
    for x in xrange(1, len(nextbestmatches[g]), 2):
        print >> f3, g, "," , nextbestmatches[g][x-1], "," , nextbestmatches[g][x]

f3.close()

