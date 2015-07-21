library(dplyr)
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
#unique_train_stops$Station <- paste(unique_train_stops$Station,unique_train_stops$StopID, sep="")
#trains_names$X.stop_name. <- paste(trains_names$X.stop_name.,trains_names$stop_id,sep="")

#Getting the LineName so we can later join with Turnstile data
unique_train_stops$LineName = ""
linename_extraction <- unique_train_stops[order(unique_train_stops[,5], unique_train_stops[,1]), ] 

linename_extraction$counter=1

linename_extraction <- linename_extraction %>% group_by(StopID) %>% mutate(cdf = cumsum(counter))
n <- 1:length(linename_extraction$Train)
for (i in seq (along=n)){
  if(linename_extraction$cdf[i] ==1){
    linename_extraction$LineName[i] = linename_extraction$Train[i]
  i
  }
}

n <- 1:length(linename_extraction$Train)
for (i in seq (along=n)){
  if(linename_extraction$cdf[i] > 1){
    if (linename_extraction$LineName[i-1]==linename_extraction$Train[i]){
      linename_extraction$LineName[i] = linename_extraction$LineName[i-1]
    }
    else{
      linename_extraction$LineName[i] = paste(linename_extraction$LineName[i-1],linename_extraction$Train[i],sep="")
    i
    }
  }
}

maxcdf<- linename_extraction %>% group_by(StopID) %>% summarize(maxcdf = max(cdf))
linename_extraction <- inner_join(linename_extraction,maxcdf)

#Getting only the full linenames, not the buildup (ex. 1, 12, 123 vs just 123 each time)
unique_stopids <- filter(linename_extraction, cdf == maxcdf)
unique_stopids <- data.frame(unique_stopids[,c(5,7)])

#Reordering so that we have all trains and their stops with the stop_ids (even though this is a little inaccurate)
unique_train_lines <- unique_train_stops
unique_train_lines$LineName = NULL
unique_train_lines<- inner_join(unique_train_lines,unique_stopids)

#Put it in the order we want so we can manipulate the data 
unique_train_lines <- mutate(unique_train_lines, TrainStop2 = lag(TrainStop))
unique_train_lines<- mutate(unique_train_lines, Station2= lag(Station))
unique_train_lines<- mutate(unique_train_lines, FirstStopID = lag(StopID))
unique_train_lines<-mutate(unique_train_lines,FromLine=lag(LineName))

#Get rid of NA
unique_train_lines[unique_train_lines$Stop == "01",]$Station2=NA
unique_train_lines<- unique_train_lines[complete.cases(unique_train_lines),]

#Reformatting and getting rid of FromStop and ToStop ( you can add this back if you want but its not accurate)
unique_train_lines <-data.frame(unique_train_lines[,c(1,10,9,11,5,3,7,4)])

#Renaming
names(unique_train_lines)<- c('Train','FromStopID','FromStation','FromLine', 'ToStopID','ToStation','ToLine' ,'TravelTime')

#Seperate data frame for all the 

#Export as R file - change the dir/file name per needs
write.csv(unique_train_lines, "/home/ewahmed/subway-flow/TrainTravel_LineNames_StopIDs.csv") 


