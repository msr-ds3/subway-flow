import sys
import fileinput
import networkx as nx

#Reading files from CSV
openingfile = open("/home/ewahmed/subway-flow/TrainTravel.csv")
traindata = openingfile.readlines()

#initializing the lists(features) we are going to need to graph with
trains=[]
fromstation=[]
tostation=[]
traveltime=[]

#Extracting data into select initalized lists ^ 
for line in traindata:
	traintravel = line.rstrip('\n').split(',')
	trains.append(traintravel[1])
	fromstation.append(traintravel[4])
	tostation.append(traintravel[5])
	traveltime.append(traintravel[6])

#length of our lists - to use in loops
length=range(0,len(trains))

#Getting rid of the extra quotations, making all the data look nice 
for i in length:
	trains[i] = trains[i].replace('"', '').strip()
	fromstation[i] = fromstation[i].replace('"','').strip()
	tostation[i] = tostation[i].replace('"','').strip()
	traveltime[i] = traveltime[i].replace('"','').strip()

#initializing a graph for the B train
B= nx.DiGraph()

#Looking where the B train's data begins and ends (index)
startindex=0

for train in trains:
	startindex+=1
	if(train=='B'):
		break

endindex=startindex
for train in trains:
	if(train=='B'):
		endindex+=1

endindex=endindex-1

#Extracting only the data of the B Train 
Bfromstation = fromstation[startindex:endindex]
Btostation = tostation[startindex:endindex]
Btraveltime = traveltime[startindex:endindex]

#Connecting nodes/stations with one another 
length= range(0,len(Bfromstation))

for i in length:
	B.add_edge(Bfromstation[i],Btostation[i])

	#fromstation[1],tostation[1])

def print_flow(flow):
     for edge in B.edges():
         n1, n2 = edge
         print edge, flow[n1][n2]

print_flow(B)














openingfile.close()