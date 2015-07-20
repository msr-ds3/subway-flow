import networkx as nx
import pylev
import re
import sys
import matplotlib.pyplot as plt

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
    if not a.match(name1) and not a.match(name2):
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

#(Break up dataset into numbered and non-numbered streets)
################################################################################

################################################################################

#Files are already lowercase. (Command line).
f1 = open("ts2.txt")
f2 = open("stops2.txt") 

turns = f1.readlines()
google = f2.readlines()

#Making lists to read all the station names into.

turn_terms = []
google_terms = []
orig_turn = []
orig_google = []

pattern = re.compile(r'av[nue]+')

path = set(["NEWARK BM BW", "NEWARK C", "NEWARK HM HE", "NEWARK HW BMEBE", "HARRISON", "JOURNAL SQUARE", "GROVE STREET", "EXCHANGE PLACE", "PAVONIA/NEWPORT", "LACKAWANNA"]) #Hard Coded Path trains.

B = nx.DiGraph()

#Add Nodes:
for t in turns:
    a = t.strip()
    if a not in path:
        temp1 = one_ave(a.lower().strip(), pattern, "av")
        turn_terms.append(temp1)
        orig_turn.append(a)
        B.add_node(temp1, demand = 1)

f1.close()

for g in google:
    temp1 = one_ave(g.lower().strip(), pattern, "av")
    google_terms.append(temp1)
    orig_google.append(g)
    B.add_node(temp1, demand = -1)

B.add_node("Dummy1", demand = 1)
B.add_node("Dummy2", demand = 1)

turn_terms.append("Dummy1")
turn_terms.append("Dummy2")


f2.close()

bestmatches = {}
sawts = {}

#Add dummy nodes

for t in turn_terms:		
    for g in google_terms:      
         #Compute distance with levenshtein and numbers
        distance = int(pylev.levenshtein(g,t)) + int(distanceoffset(t, g)) + int(isinside(t, g)) 
# int(samewords(t, g))
        #turnstrings = orig_google[g], google_terms[g], orig_turn[t]
        B.add_edge(g, t, weight = distance)
        #if distance < 3:
        #    print "google = ", g, "turn = ", t, "distance = ",  distance




#Min cost flow

#flow = nx.min_cost_flow(B)
#print flow




#Go through dictionary, value of each edge = 1 or 0

#For loop over edges print out non 0 edges
#pos=nx.spring_layout(B) # positions for all nodes
#elarge=[(u,v) for (u,v,d) in B.edges(data=True) if d['weight'] < 0] #takes more than 2 minutes
#nx.draw_networkx_edges(B,pos,edgelist=elarge, width=2) #edges
#nx.draw_networkx_labels(B,pos,font_size=10,font_family='sans-serif') #labels

#nx.draw(BD)
#plt.show()

#            bestmatches[turn_terms[t]] = tinylist

#f3 = open('./matchtable.txt', 'w')

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
#f3.close()
