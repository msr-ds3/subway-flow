#Author : Eiman Ahmed
import sys
import fileinput
import networkx as nx
import matplotlib.pyplot as plt

graphme = raw_input("Which train are you taking?      ") 

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
G= nx.DiGraph()

#Looking where the train's data begins and ends (index)
starttrain=-1

for train in trains:
	starttrain+=1
	if(train==graphme):
		break

endtrain=starttrain
for train in trains:
	if(train==graphme):
		endtrain+=1

endtrain=endtrain-1

#initalizing 
Gfromstation = fromstation[starttrain:endtrain]
Gtostation = tostation[starttrain:endtrain]

print Gfromstation
print Gtostation

#Connecting stations with one another on the graph
length=range(starttrain,endtrain)
for i in length:
 	G.add_cycle([fromstation[i],tostation[i]])

#Print flow function
def print_flow(flow):
     for edge in G.edges():
         n1, n2 = edge
         print edge, flow[n1][n2]

print_flow(G)

nx.draw_spring(G, with_labels=True, node_color='w', node_size=300, font_size=10)

#paths = nx.shortest_path(G, 'D40','635') #From brighton to fulton st aka my school route
#print paths
plt.show()


# plt.axis('off') #turning off grid
# plt.show() #showing graph

