import pylev

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
        if pylev.levenshtein(ts_station, g_station) == 0: 	#If the distance is 0, we have a perfect match!
            tinylist1 = [0, ts_station]
            perfectmatches[g_station] = tinylist1
            break
        else:
            bestmatches.setdefault(g_station, [len(g_station)])
            nextbestmatches.setdefault(g_station, len(g_station))
            tinylist = [pylev.levenshtein(ts_station, g_station), ts_station]

            if tinylist[0] < bestmatches[g_station][0]:
                nextbestmatches[g_station] = bestmatches[g_station]
                bestmatches[g_station] = tinylist


f3 = open('./matchtable.txt', 'w')
for p in perfectmatches:
	print >> f3, p, perfectmatches[p]
for g in bestmatches:
    print >> f3, g, bestmatches[g]

for x in nextbestmatches:
    print >> f3, x, nextbestmatches[x]

f3.close()

