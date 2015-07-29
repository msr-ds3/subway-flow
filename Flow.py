#Author : Eiman Ahmed
import sys
import fileinput
import networkx as nx
import matplotlib.pyplot as plt

#change this directory to wherever you located the TrainTravel.csv file 
openingfile = open("/home/ewahmed/subway-flow/SingularTrainFlow.csv")
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
	traveltime.append(traintravel[5])

#initializing a graph to represent the connections on 
G= nx.DiGraph()

#Connecting all stations with one another on the graph
length = range(1, len(trains))

for i in length:
	if(trains[i-1]==trains[i]):
		G.add_edge(stations[i-1],stations[i],weight=traveltime[i])
		G.add_edge(stations[i],stations[i-1],weight=traveltime[i])


#nx.draw_spring(G, with_labels=True, node_color='w', node_size=300, font_size=6)
#plt.show()

openingfile = open("/home/ewahmed/subway-flow/f_noon.csv")
noondata = openingfile.readlines()
openingfile.close()

#Extracting data into select initalized lists ^ 
noondata.pop(0)
total = 0
for line in noondata:
	_, _, station, exits, entries = line.rstrip('\n').split(',')
	G.node[station]["demand"]=int(exits)-int(entries)
	total += int(exits) - int(entries)

#print "Total = ", total
#print "Demands recorded = ", len(noondata)
#print "Number of nodes = ", G.number_of_nodes()


for n in G.nodes():
	if "demand" not in G.node[n]:
		G.remove_node(n)

turnstile_stations = [record.strip().split(',')[2] for record in noondata]
gtfs_stations = G.nodes()

# print "Number of turnstile stations = ", len(turnstile_stations)
#print "Deduped number = ", len(set(turnstile_stations))

#print set(turnstile_stations) - set(gtfs_stations)
extra_nodes = set(gtfs_stations) - set(turnstile_stations)

#print G.number_of_nodes()
#print len(noondata)
#print sum(G.node[n]["demand"] for n in G.nodes())

#flow = nx.min_cost_flow(G)
#for n1 in flow:
#	for n2 in flow[n1]:
#		print n1, n2, flow[n1][n2]

