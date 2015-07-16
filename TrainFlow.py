import sys
import fileinput
import networkx as nx
import matplotlib.pyplot as plt

################################################################################################################################
#########################                      FOR A SPECIFIC TRAIN'S FLOW RUN THE FOLLOWING          ###########################
#################################################################################################################################

graphme = raw_input("Which train are you taking?      ") 

#change this directory to wherever you located the TrainTravel.csv file 
openingfile = open("/home/ewahmed/subway-flow/TrainTravel.csv")
traindata = openingfile.readlines()

#initializing the lists(features) we are going to need to graph with
#You can also use a dictionary to store in the following format - {"TrainName",[FromStation,ToStation,TravelTime]}

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

#initializing a graph to represent the connections on 
G= nx.DiGraph()

#Looking where the train's data begins and ends (index)
startindex=0

for train in trains:
	startindex+=1
	if(train==graphme):
		break

endindex=startindex
for train in trains:
	if(train==graphme):
		endindex+=1

endindex=endindex-1

#Extracting only the data of that Train 
Gfromstation = fromstation[startindex:endindex]
Gtostation = tostation[startindex:endindex]
Gtraveltime = traveltime[startindex:endindex]

#Connecting stations with one another on the graph
length= range(0,len(Gfromstation))

for i in length:
	G.add_cycle([Gfromstation[i],Gtostation[i]])
	#G.add_edge(Gfromstation[i],Gtostation[i])
	G.edge[Gfromstation[i]][Gtostation[i]]['weight'] = Gtraveltime[i]

def print_flow(flow):
     for edge in G.edges():
         n1, n2 = edge
         print edge, flow[n1][n2]

fromhere = raw_input("Which train station are you departuring from?            ")
tothere = raw_input("Which train station are you trying to go to               ") 

print "You will arrive at your desination in ",len(nx.shortest_path(G, fromhere, tothere))-1, " stops" 
print "The train will travel in the following format:     ", nx.shortest_path(G, fromhere, tothere)

nx.draw(G, with_labels=True, node_color='w', node_size=500)
plt.show()

openingfile.close()