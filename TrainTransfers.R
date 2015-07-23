library(dplyr)
setwd("/home/ewahmed/Desktop/SubwayData")
#Reading in the train sequences file
stop_times <- read.table("stop_times.txt",header=TRUE, 
                         sep=",",fill=TRUE,quote = "",row.names = NULL,
                         stringsAsFactors = FALSE) 

#Getting rid of columns I dont need (stop_headsign, pickup_type, dropoff_type, shape_dist_traveled)
stop_times <- data.frame(stop_times[,c(1,2,3,4,5)])

#Reading in train stations with their stop_ids file
stops <- read.table("modifiedstops.txt",header=TRUE, 
                    sep=",",fill=TRUE,quote = "",row.names = NULL,
                    stringsAsFactors = FALSE) 

#Joining the two data frames so that we know which trains go to which stops (only had ids before)
stop_times_names <- inner_join(stop_times,stops)

#Read in the information of the trips 
trips <- read.table("trips.txt",header=TRUE, 
                    sep=",",fill=TRUE,quote = "",row.names = NULL,
                    stringsAsFactors = FALSE) 

#Joining with trips so we know which trains we are actually looking at 
trains_names <- inner_join(stop_times_names,trips)

#Getting rid of unnecessary columns
trains_names <- data.frame(trains_names[,c(1,2,3,4,5,6,7)])

#Need to convert into Hour/Minute/Second format to subtract the arrival time from departure (to get duration)
trains_names$arrival_time <- as.POSIXct(trains_names$arrival_time, format='%H:%M:%S')
trains_names$departure_time <- as.POSIXct(trains_names$departure_time, format='%H:%M:%S')

#Subtracting times: column n - column n-1
trains_names <- mutate(trains_names, TravelTime = departure_time - lag(arrival_time))

#Getting rid of both departure and arrival time since we have TravelTime now 
trains_names <- data.frame(trains_names[,c(7,6,4,5,8)])

#Combine trips with their stops to get format of B01 B02 etc
zero<- "0"
trains_names$stop_sequence <- paste(zero,trains_names$stop_sequence,sep="")
trains_names$TrainStop <- paste(trains_names$route_id,trains_names$stop_sequence,sep="")

#Getting rid of duplicate train info that we do not need
trains_names$counter=1
trains_names <- trains_names %>% group_by(TrainStop) %>% mutate(cdf = cumsum(counter))
unique_train_stops <- filter(trains_names,cdf==1)

#Renaming features and reformatting data frame... yet again
unique_train_stops<- data.frame(unique_train_stops[,c(1,6,2,5,3,4)])
names(unique_train_stops) <- c('Train','TrainStop','Station','TravelTime','StopID','Stop')

#Clean the duration so that we get rid of the weird durations (-7k etc)
unique_train_stops[unique_train_stops$Stop == "01",]$TravelTime=0
trains_names[trains_names$stop_sequence == "01",]$TravelTime=0

#Getting rid of North and south on StopIDs
unique_train_stops$StopID= substr(unique_train_stops$StopID,0,3)
trains_names$stop_id= substr(trains_names$stop_id,0,3)

#Combining Stations + StopIDs as one feature
unique_train_stops$Station <- paste(unique_train_stops$Station,unique_train_stops$StopID, sep="")

#Loading unique transfer data (differentstopids)
setwd("/home/ewahmed/subway-flow/CleanTransfers/")
transfers <- read.table("differentstopids.txt",header=TRUE, 
                        sep=",",fill=TRUE,quote = "",row.names = NULL,
                        stringsAsFactors = FALSE) 

#Renaming so we can join the transfer data to the train_stopid_lines dataframe
names(transfers)<- c('StopID','TransferID','TransferTime')
names(stops)<- c('TransferID','StationName')
transfers <- inner_join(transfers, stops)

#Combining Stations + TransferIDs as one feature in the transfers data frame 
transfers$StationName <- paste(transfers$StationName,transfers$TransferID, sep="")

#Putting train and transferfrom station info into the transfers dataframe, reformatting, renaming
transfers<- inner_join(unique_train_stops,transfers)
transfers <- data.frame(transfers[,c(1,2,3,4,9,8)])
names(transfers) <- c('Train','TrainStop','Station','TravelTime','TransferStation','TransferTime')
write.csv(transfers, "/home/ewahmed/subway-flow/TransferTrains.csv")
##########################################################3