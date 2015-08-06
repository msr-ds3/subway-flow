#Author : Eiman Ahmed
import sys
import fileinput
import networkx as nx
import matplotlib.pyplot as plt
import csv

#change this directory to wherever you located the TrainTravel.csv file 
openingfile = open("./subway-flow/SingularTrainFlow.csv")
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

files = ['f_latenight.csv','f_morning.csv','f_noon2.csv','f_evening.csv','f_night.csv','f_latemorning.csv','f_am.csv','f_pm.csv','f_allday.csv']
for name in files:

	openingfile = open("./subway-flow/PrePres/BalancedData/"+name)
	noondata = openingfile.readlines()
	openingfile.close()

	name= name[2:len(name)-4]

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

	fromstations=[]
	tostations=[]
	flows=[]

	for x in flow:
	    for y in flow[x]:
	    	fromstations.append(x)
	    	tostations.append(y)

	length = xrange(0, len(fromstations))

	fromids = []
	toids=[]

	for i in length:
		flows.append(flow[fromstations[i]][tostations[i]])
		fromids.append(fromstations[i][len(fromstations[i])-3:])
		toids.append(tostations[i][len(tostations[i])-3:len(tostations[i])])

	rows = zip(fromids,toids,flows)

	out= open("/home/ewahmed/subway-flow/PrePres/Flows/" + name+"flows.csv", "wb")
	out.write('\n')
	for i in length: 
		out.write(fromstations[i] +',' + fromids[i] + ',' + tostations[i] + ',' + toids[i] + ',' + str(flows[i]) + '\n')
	out.close()
	
	   






