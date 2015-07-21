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
    arr = name1.split()
    name1_ns = ""
    for x in arr:
        name1_ns = name1_ns + x
    return name1_ns

def isinside(name1, name2):
    if name1 in name2 or name2 in name1:
        return -2
    return 0

def one_ave(string1, pattern, string2):
    arr1 = string1.replace('-', ' ').rsplit()
    outbound = ""
    for x in xrange(0, len(arr1)):
        if pattern.match(arr1[x]):
            arr1[x] = string2
        outbound = outbound + " " + arr1[x]
    return outbound

def penalize(string1, string2):
    if pylev.levenshtein(string1, string2) > min(len(string1), len(string2)):
        return 3
    return 0

#Break up dataset into numbered and non-numbered streets

################################################################################

################################################################################

#Files are already lowercase. (Command line).
f1 = open("ts2.txt")
f2 = open("stops2.txt") 

turns = f1.readlines()
google = f2.readlines()

#Making lists to read all the station names into.

turn_terms = [] #Turnstile
google_terms = [] #Google
orig_turn = []    
orig_google = []
r_best = {}

pattern = re.compile(r'av[enu]+')

path = set(["NEWARK BM BW", "NEWARK C", "NEWARK HM HE", "NEWARK HW BMEBE", "HARRISON", "JOURNAL SQUARE", "GROVE STREET", "EXCHANGE PLACE", "PAVONIA/NEWPORT", "CHRISTOPHER ST"]) #Hard Coded Path trains.

SIRS = set(["Nassau", "Annadale", "Tottenville", "Stapleton", "Clifton", "Grasmere", "Old Town", "Dongan Hills", "Jefferson Av", "Grant City", "New Dorp", "Oakwood Heights", "Bay Terrace", "Great Kills", "Eltingville", "Huguenot", "Prince's Bay", "Pleasant Plains", "Richmond Valley", "Nassau", "Atlantic"])
for t in turns:
    a = t.strip('\"').strip()
    if a not in path:
        temp1 = one_ave(a.lower(), pattern, "av")
        turn_terms.append(temp1)
        orig_turn.append(t)

f1.close()

for g in google:
    a = g.replace('"', '').strip()
    if a not in SIRS:
        
        temp1 = one_ave(a.lower(), pattern, "av")
        google_terms.append(temp1)
        orig_google.append(g)

f2.close()

bestmatches = {}
print "Length of google = ", len(google_terms)
print "Length of turns = ", len(turn_terms)
#Compare each station in the turnstile data to each station in the google feed. 
for t in xrange(0, len(turn_terms)):
    for g in xrange(0, len(google_terms)):
    #Make the highest default so anything better will take its place.          
        tinylist = [int(distanceoffset(turn_terms[t], google_terms[g])) + int(pylev.levenshtein(google_terms[g], turn_terms[t])) + isinside(turn_terms[t], google_terms[g]) + samewords(turn_terms[t], google_terms[g]) + penalize(turn_terms[t], google_terms[g]), orig_google[g], google_terms[g], orig_turn[t]]
        
        bestmatches.setdefault(turn_terms[t], [len(turn_terms[t])])
        r_best.setdefault(g, [len(google_terms[g])])
        #Compute distance with levenshtein and numbers
        if tinylist[0] < bestmatches[turn_terms[t]][0] and tinylist[0] < r_best[g]:
            bestmatches[turn_terms[t]] = tinylist
            r_best[g] = [tinylist[0], turn_terms[t]]

            

f3 = open('./matchtable.txt', 'w')

for g in bestmatches:
    f3.write(g + ",")
    for x in xrange(0, len(bestmatches[g])):
        if x == len(bestmatches[g])-1:
            f3.write(str(bestmatches[g][x]).strip())
        else:
            f3.write(str(bestmatches[g][x]).strip() + ",")
    f3.write("\n")

f3.close()
