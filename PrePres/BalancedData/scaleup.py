# CURRENT
# Riva Tropp
# 7/29/2015
# Scales up exits to match entries.
###############################################################################
#Scale up
###############################################################################
f1 = open("f_noon.csv") #Be sure to have the correct file.
time = f1.readlines()
sum_ent = 0.0
sum_x = 0.0
entries = []
exits = []
ratio = 0.0
timesq = 0
time.pop(0) #Header

#Grab original sum and ratio:
for thing in time:
    fields = thing.split(",")
    e = float(fields[6].strip('"'))
    x = float(fields[7].strip('\n').strip('"'))        
    sum_ent += e
    sum_x += x
    entries.append(e)
    exits.append(x)
    if "127" in fields[3]: #Grab the index of times square to adjust there later
        timesq = entries.index(e)
f1.close()

#diff = sum_ent - sum_x
ratio = sum_ent/sum_x

#Scale up each exit by the ratio.
for x in xrange(0, len(exits)):
    exits[x] = exits[x] * ratio

sum_ent = 0
sum_x = 0

#Round all the entries and exits, find the differences. 
for e in xrange(0, len(entries)):
    entries[e] = int(entries[e] + .5)
    exits[e] = int(exits[e] + .5)
    sum_ent += entries[e]
    sum_x += exits[e]

diff = sum_ent - sum_x
sum_ent = 0
sum_x = 0

#Subtract the difference from entries.
entries[timesq] -= diff

############################################################################
#To Check:
###########################################################################
#for e in xrange(0, len(entries)):
#    entries[e] = int(entries[e])
#    exits[e] = int(exits[e])
#    sum_ent += entries[e]
#    sum_x += exits[e]

#diff = sum_ent - sum_x
#print sum_ent, sum_x, diff
