library(dplyr)
#Reading in the information from stop_times.txt
stop_times <- read.table("stop_times.txt",header=TRUE, 
                    sep=",",fill=TRUE,quote = "",row.names = NULL,
                    stringsAsFactors = FALSE) 

#Reading in the information from stops.txt
stops <- read.table("modifiedstops.txt",header=TRUE, 
                         sep=",",fill=TRUE,quote = "",row.names = NULL,
                         stringsAsFactors = FALSE) 

#Getting rid of the following columns: stop_headsign, pickup_type, drop_off_type, shape_dist_traveled
stop_times <- data.frame(stop_times[,c("trip_id","arrival_time","departure_time","stop_id","stop_sequence")])

#Need to convert into Hour/Minute/Second format to subtract
stop_times$arrival_time <- as.POSIXct(stop_times$arrival_time, format='%H:%M:%S')
stop_times$departure_time <- as.POSIXct(stop_times$departure_time, format='%H:%M:%S')

#Subtracting times: column n - column n-1
stop_times_names <- mutate(stop_times, duration = departure_time - lag(arrival_time))

#Joining the stop names with the stop_times data frame so we know the names of the various stops
stop_times_names <- inner_join(stop_times_names,stops)

#Get rid of the arrival times and departure times since they are the same, keep only the duration
stop_times_names<- data.frame(stop_times_names[,c(1,7,5,6)])

#Read in the information so that I have trips only 
trips <- read.table("trips.txt",header=TRUE, 
                    sep=",",fill=TRUE,quote = "",row.names = NULL,
                    stringsAsFactors = FALSE) 

#Parse so we have the trains with their trip_ids and we can then merge so we have only trains
trips <- data.frame(trips[,c(1,3)])
trains_info <- inner_join(trips, stop_times_names)
trains_info$trip_id = NULL

#Renaming columns because..... I want to 
colnames(trains_info) <- c("Train","Station","Stop","Duration")

#Combine trips with their stops to get format of B01 B02 etc
zero<- "0"
trains_info$Stop <- paste(zero,trains_info$Stop,sep="")
trains_info$TrainStop <- 
  paste(trains_info$Train,trains_info$Stop,sep="")

#Getting rid of duplicate train info that we do not need
trains_info$counter=1
trains_info <- trains_info %>% group_by(TrainStop) %>% mutate(cdf = cumsum(counter))
trains_info <- filter(trains_info,cdf==1)

#Clean the duration so that we get rid of the weird durations (-7k etc)
trains_info[trains_info$Stop == "01",]$Duration=0

#Parse so we only have the information we need aka the Trains/Stops , Station Name , and the Duration
trains_info<-data.frame(trains_info[,c(1,5,2,4,3)])

#Put it in the order we want so we can manipulate the data
trains_info <- mutate(trains_info, TrainStop2 = lag(TrainStop))
trains_info <- mutate(trains_info, Station2= lag(Station))

#Get rid of NA
trains_info[trains_info$Stop == "01",]$Station2=NA
trains_info<- trains_info[complete.cases(trains_info),]

#Change the names of the columns and add a column with the train being tracked
trains_info <- data.frame(trains_info[,c(1,6,2,7,3,4)])
names(trains_info) <- c("Train","Train_Stop","Train_Stop2","From_Station","To_Station","Travel_Time")

#Export as R file - change the dir/file name per needs
write.table(trains_info, "/home/ewahmed/subway-flow/TrainTravel.csv", sep=",") 
