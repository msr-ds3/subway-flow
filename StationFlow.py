#Author : Eiman Ahmed
import sys
import fileinput
import networkx as nx
import matplotlib.pyplot as plt


#graphme = raw_input("Which train are you taking?      ") 

#change this directory to wherever you located the TrainTravel.csv file 
openingfile = open("/home/ewahmed/subway-flow/TrainTravel_LineNames_StopIDs.csv")
traindata = openingfile.readlines()
openingfile.close()

#initializing the lists(features) we are going to need to graph with
#You can also use a dictionary to store in the following format - {"TrainName",[FromStation,ToStation,TravelTime]}

trains=[]
fromstation=[]
tostation=[]
fromstopid=[]
tostopid=[]
traveltime=[]
fromline=[]
toline=[]

#Extracting data into select initalized lists ^ 
for line in traindata:
	traintravel = line.rstrip('\n').split(',')
	trains.append(traintravel[1])
	fromstopid.append(traintravel[2])
	tostopid.append(traintravel[5])
	fromstation.append(traintravel[3])
	tostation.append(traintravel[6])
	traveltime.append(traintravel[8])
	fromline.append(traintravel[4])
	toline.append(traintravel[7])

#length of our lists - to use in loops
length=range(0,len(trains))

#Getting rid of the extra quotations, making all the data look nice 
for i in length:
	trains[i] = trains[i].replace('"', '').strip()
	fromstation[i] = fromstation[i].replace('"','').strip()
	tostation[i] = tostation[i].replace('"','').strip()
	fromstopid[i] = fromstopid[i].replace('"','').strip()
	tostopid[i] = tostopid[i].replace('"','').strip()
	traveltime[i] = traveltime[i].replace('"','').strip()
	fromline[i] = fromline[i].replace('"','').strip()
	toline[i] = toline[i].replace('"','').strip()

#change this directory to where you located the Transfers file
openingfile= open("/home/ewahmed/subway-flow/CleanTransfers/differentstopids.txt")
transfers = openingfile.readlines()
openingfile.close()

#initalize lists to graph with later (make connections)
transferfrom=[]
transferto=[]
transfertime=[]

#Parsing data into lists
for transfer in transfers:
	stoptransfers = transfer.rstrip('\n').split(',')
	transferfrom.append(stoptransfers[0])
	transferto.append(stoptransfers[1])
	transfertime.append(stoptransfers[2])	

#initializing a graph to represent the connections on 
G= nx.DiGraph()

#Connecting stations with one another on the graph
length= range(1,len(trains))
for i in length:
	G.add_cycle([fromstopid[i],tostopid[i]],fromname=fromstation[i])

#Connecting transfers to one another on the graph
length = range(1,len(transferto))
for i in length:
	G.add_cycle([transferfrom[i],transferto[i]],transfertime=transfertime[i])

#Print flow function
def print_flow(flow):
     for edge in G.edges():
         n1, n2 = edge
         print edge, flow[n1][n2]

print_flow(G)

nx.draw(G, with_labels=True, node_color='w', node_size=500, font_size=10)

#paths = nx.shortest_path(G, 'D40','635') #From brighton to fulton st aka my school route
#print paths
plt.show()


# plt.axis('off') #turning off grid
# plt.show() #showing graph

