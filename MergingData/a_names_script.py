import pylev
import re
import sys


#Function to give numbers larger weight for distance
def samewords(name1, name2):
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

def distanceoffset(name1, name2):
    a = re.compile(r'[^0-9]*([0-9]+)[^0-9]*')

    if (not a.match(name1) and a.match(name2)) or (not a.match(name2) and a.match(name1)):
        #print >> sys.stderr, name1 + " has numbers ", name2 + " doesn't."
        return 2
    if not a.match(name1) and a.match(name2):
        #print >> sys.stderr, name1 + " doesn't have any numbers!"
        return 0 #Don't affect the distance at all.
    
    set1 = set()
    set2 = set()
    match1 = re.findall(a, name1) #Find all the numbers in the string.
    match2 = re.findall(a, name2) #Find all the numbers in the string.
    for x in match1:
        set1.add(x)
    for v in match2:
        set2.add(v)
    
    if len(match1) != len(match2): #Different amounts of numbers in the string.
        if match1[0] != match2[0]:
            #print >> sys.stderr, name1 + " doesn't match " + name2 + " at all."
            return len(max(name1, name2)) #Return the largest length as the distance so practically any match will be better.
        else:
            #print >> sys.stderr, "One of your strings has more numbers than the other, but the most of them match."
            return 2
    else: #If there are the same amount of numbers in the string...
        if set1 != set2:
            #print >> sys.stderr, "Your numbers don't match."
            return len(max(name1, name2))
        else:
            #print >> sys.stderr, name1 + " and " + name2 + " match!"
            return -5

#Returns a given phrase without any of the spaces
def wordnospaces(name1):
    arr = name1.split()
    name1_ns = ""
    for x in arr:
        name1_ns = name1_ns + x
    return name1_ns
#?Regex?

def isinside(name1, name2):
    if name1 in name2 or name2 in name1:
        return -2
    return 0

def one_ave(string1, pattern, string2):
    arr1 = string1.replace('-', ' ').rsplit()
    outbound = ""
    for x in xrange(0, len(arr1)):
        if pattern.match(arr1[x]):
            #print "changed something"
            arr1[x] = string2
        outbound = outbound + " " + arr1[x]
    return outbound


        
#Break up dataset into numbered and non-numbered streets


################################################################################

################################################################################

#Files are already lowercase. (Command line).
f1 = open("ts2.txt")
f2 = open("stops2.txt") 

turns = f1.readlines()
google = f2.readlines()

#Making lists to read all the station names into.

ts_terms = []
gtfs_terms = []
orig_ts = []
orig_gtfs = []

pattern = re.compile(r'av[nue]+')

for t in turns:
    temp1 = one_ave(t.lower(), pattern, "av")
    #if t != temp1:
    #    print t, temp1
    ts_terms.append(temp1)
    orig_ts.append(t)

for g in google:
    fields = g.split(",")
    temp1 = one_ave(fields[1].lower(), pattern, "av")
    gtfs_terms.append(temp1)
    orig_gtfs.append(g)

#for v in xrange(0, len(ts_terms)):
#    print ts_terms[v], orig_ts[v]

f1.close()
f2.close()

bestmatches = {}
sawts = {}

#Compare each station in the turnstile data to each station in the google feed. 
for g in xrange(0, len(gtfs_terms)):		
    for t in xrange(0, len(ts_terms)):
        #Make the highest default so anything better will take its place.
        bestmatches.setdefault(gtfs_terms[g], [len(gtfs_terms[g])])
            
            #Compute distance with levenshtein and numbers
        tinylist = [int(distanceoffset(ts_terms[t], gtfs_terms[g])) + int(pylev.levenshtein(gtfs_terms[g], ts_terms[t])) + isinside(ts_terms[t], gtfs_terms[g]) + samewords(ts_terms[t], gtfs_terms[g]), orig_gtfs[g], ts_terms[t], orig_ts[t]]

        if tinylist[0] < bestmatches[gtfs_terms[g]][0]:
            bestmatches[gtfs_terms[g]] = tinylist

f3 = open('./matchtable2.txt', 'w')

print bestmatches
#for g in xrange(0, len(bestmatches)):
#    for x in xrange(0, len(g)):
#        print 
#for g in bestmatches:
#    f3.write(g + ",")
#    for x in xrange(0, len(bestmatches[g])):
#        if x == len(bestmatches[g])-1:
#            f3.write(str(bestmatches[g][x]).strip())
#        else:
#            f3.write(str(bestmatches[g][x]).strip() + ",")
#    f3.write("\n")
#for g in bestmatches:
#    print g, bestmatches[g]
    
#    if g is list:
#       for x in g:
#           print x
#print bestmatches
f3.close()
