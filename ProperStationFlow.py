#Author : Eiman Ahmed
import sys
import fileinput
import networkx as nx
import matplotlib.pyplot as plt

#change this directory to wherever you located the TrainTravel.csv file 
openingfile = open("/home/ewahmed/subway-flow/TrainTravel.csv")
traindata = openingfile.readlines()
openingfile.close()

#initializing the lists(features) we are going to need to graph with
#You can also use a dictionary to store in the following format - {"TrainName",[FromStation,ToStation,TravelTime]}

trains=[]
fromstation=[]
tostation=[]
traveltime=[]

#Extracting data into select initalized lists ^ 
for line in traindata:
	traintravel = line.rstrip('\n').split(',')
	print traintravel
	trains.append(traintravel[1])
	fromstation.append(traintravel[3])
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
G= nx.Graph()

################################################################################################################################
#########################                      FOR A ONE/TWO TRAIN'S FLOW RUN THE FOLLOWING          ###########################
#################################################################################################################################

graphme = raw_input("Which train are you taking?      ") 
graphme2 = raw_input("Which other train are you taking? 		")

#Looking where the train's data begins and ends (index)
startindex=-1

for train in trains:
	startindex+=1
	if(train==graphme):
		break

endindex=startindex
for train in trains:
	if(train==graphme):
		endindex+=1

endindex=endindex

#Extracting only the data of that Train 
Gfromstation = fromstation[startindex:endindex]
Gtostation = tostation[startindex:endindex]
Gtraveltime = traveltime[startindex:endindex]

# Connecting stations with one another on the graph
length= range(0,len(Gfromstation))

for i in length:
	G.add_cycle([Gfromstation[i],Gtostation[i]],weight=Gtraveltime[i])

nx.draw_spring(G, with_labels=True, node_color='g', node_size=300, font_size=10)

# Looking where the other train's data begins and ends (index)
startindex=-1

for train in trains:
	startindex+=1
	if(train==graphme2):
		break

endindex=startindex
for train in trains:
	if(train==graphme2):
		endindex+=1

endindex=endindex

# Connecting stations with one another on the graph
length= range(0,len(Gfromstation))

for i in length:
	G.add_cycle([Gfromstation[i],Gtostation[i]],weight=Gtraveltime[i])


#Connecting all stations with one another on the graph
# length = range(0, len(trains))

# for i in length:
# 	G.add_cycle([fromstation[i],tostation[i]])

# def print_flow(flow):
#      for edge in G.edges():
#          n1, n2 = edge
#          print edge, flow[n1][n2]

# print_flow(G)

nx.draw_spring(G, with_labels=True, node_color='w', node_size=300, font_size=6)
plt.show()


