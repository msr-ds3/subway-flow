#Author : Eiman Ahmed
import sys
import fileinput
import networkx as nx
import matplotlib.pyplot as plt


graph1 = raw_input("Which train are you taking?      ") 
graph2 = raw_input("Which other train are you taking?	")

#change this directory to wherever you located the TrainTravel.csv file 
openingfile = open("./subway-flow/TrainTravel.csv")
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
	fromstation.append(traintravel[2])
	tostation.append(traintravel[4])
	traveltime.append(traintravel[6])

#length of our lists - to use in loops
length=range(0,len(trains))

#Getting rid of the extra quotations, making all the data look nice 
for i in length:
	trains[i] = trains[i].replace('"', '').strip()
	fromstation[i] = fromstation[i].replace('"','').strip()
	tostation[i] = tostation[i].replace('"','').strip()
	traveltime[i]= traveltime[i].replace('"','').strip()

#change this directory to where you located the Transfers file
openingfile= open("./UniqueTransfers.csv")
transfers = openingfile.readlines()
openingfile.close()

#initializing seperate lists for graphing with the transfer data
transfertrains=[]
transferfrom=[]
transferto=[]
transfertime=[]

#Parsing data into lists
for transfer in transfers:
	stoptransfers = transfer.rstrip('\n').split(',')
	transfertrains.append(stoptransfers[1])
	transferfrom.append(stoptransfers[4])
	transferto.append(stoptransfers[7])	
	transfertime.append(stoptransfers[8])

#length of our lists - to use in loops (same process being repeated)
length=range(0,len(transfertrains))

#Getting rid of the extra quotations, making all the data look nice 
for i in length:
	transfertrains[i] = transfertrains[i].replace('"', '').strip()
	transferfrom[i] = transferfrom[i].replace('"','').strip()
	transferto[i] = transferto[i].replace('"','').strip()
	transfertime[i]= transfertime[i].replace('"','').strip()

#initializing a graph to represent the connections on 
G= nx.Graph()
#G= nx.MultiGraph()

#Looking where the train's data begins and ends (index)
starttrain=-1

for train in trains:
	starttrain+=1
	if(train==graph1):
		break

endtrain=starttrain
for train in trains:
	if(train==graph1):
		endtrain+=1

endtrain=endtrain-1

#Looking where transfer data begins and ends for given train
starttransfer=-1

for transfer in transfertrains:
	starttransfer+=1
	if(transfer==graph1):
		break

endtransfer=starttransfer
for transfer in transfertrains:
	if(transfer==graph1):
		endtransfer+=1

#Connecting stations with one another on the graph from train data
#length= range(1,846)
length= range(starttrain,endtrain+1)
for i in length:
	G.add_cycle([fromstation[i],tostation[i]],weight=traveltime[i])

#Connecting transfers with one another on graph with transfer data
#length = range(1,317)
length = range(starttransfer,endtransfer)
for i in length:
	G.add_cycle([transferfrom[i],transferto[i]],weight=transfertime[i])

	#Looking where the train's data begins and ends (index)
starttrain=-1

for train in trains:
	starttrain+=1
	if(train==graph2):
		break

endtrain=starttrain
for train in trains:
	if(train==graph2):
		endtrain+=1

endtrain=endtrain-1

#Looking where transfer data begins and ends for given train
starttransfer=-1

for transfer in transfertrains:
	starttransfer+=1
	if(transfer==graph2):
		break

endtransfer=starttransfer
for transfer in transfertrains:
	if(transfer==graph2):
		endtransfer+=1

#Connecting stations with one another on the graph from train data
#length= range(1,846)
length= range(starttrain,endtrain+1)
for i in length:
	G.add_cycle([fromstation[i],tostation[i]],weight=traveltime[i])

# nx.draw_spring(G, with_labels=True, node_color='g', node_size=300, font_size=10)

#Connecting transfers with one another on graph with transfer data
#length = range(1,317)
length = range(starttransfer,endtransfer)
for i in length:
	G.add_cycle([transferfrom[i],transferto[i]],weight=transfertime[i])

nx.draw_spring(G, with_labels=True, node_color='w', node_size=300, font_size=10)

print nx.is_connected(G)

plt.show()