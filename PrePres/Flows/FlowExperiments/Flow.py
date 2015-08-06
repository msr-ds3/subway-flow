#sAuthor : Eiman Ahmed
import sys
import fileinput
import networkx as nx
import matplotlib.pyplot as plt
import csv

#change this directory to wherever you located the TrainTravel.csv file 
openingfile = open("../../../SingularTrainFlow.csv")
traindata = openingfile.readlines()
openingfile.close()

#initializing the lists(features) we are going to need to graph with
#You can also use a dictionary to store in the following format - {"TrainName",[FromStation,ToStation,TravelTime]}

trains=[]
stations=[]
traveltime=[]

traindata.pop(0)
#Extracting data into select initalized lists ^ 
for line in traindata:
	traintravel = line.rstrip('\n').split(',')
	trains.append(traintravel[1])
	stations.append(traintravel[4])
	traveltime.append(int(traintravel[5]))

#initializing a graph to represent the connections on 
G= nx.DiGraph()

#Connecting all stations with one another on the graph
length = xrange(1, len(trains))

for i in length:
	if(trains[i-1]==trains[i]):
		G.add_edge(stations[i-1],stations[i],weight=traveltime[i])
		G.add_edge(stations[i],stations[i-1],weight=traveltime[i])

#nx.draw_spring(G, with_labels=True, node_color='w', node_size=300, font_size=6)
#plt.show()

openingfile = open("../../BalancedData/f_noon.csv")
noondata = openingfile.readlines()
openingfile.close()

#Extracting data into select initalized lists ^ 
noondata.pop(0)
total = 0
for line in noondata:
	_, _, station, exits, entries,stationid = line.rstrip('\n').split(',')
	G.node[station]["entries"] = int(entries)
	G.node[station]["exits"] = int(exits)
	G.node[station]["demand"]=int(exits)-int(entries)
	G.node[station]["stationid"]=stationid
	total += int(exits) - int(entries)

for n in G.nodes():
	if "demand" not in G.node[n]:
		G.remove_node(n)

turnstile_stations = [record.strip().split(',')[2] for record in noondata]
gtfs_stations = G.nodes()

#print set(turnstile_stations) - set(gtfs_stations)
extra_nodes = set(gtfs_stations) - set(turnstile_stations)

nx.draw_spring(G, with_labels=True, node_color='w', node_size=350, font_size=7)
#plt.show()

flow = nx.min_cost_flow(G)


   
#write.csv()






