library(dplyr)
setwd("~/subway-flow/gtfs_data/")
#Reading in the train sequences file
stop_times <- read.table("stop_times.txt",header=TRUE, 
                         sep=",",fill=TRUE,quote = "",row.names = NULL,
                         stringsAsFactors = FALSE) 

#Getting rid of columns I dont need (stop_headsign, pickup_type, dropoff_type, shape_dist_traveled)
stop_times <- data.frame(stop_times[,c(1,2,3,4,5)])

#Reading in train stations with their stop_ids file
setwd("~/subway-flow/")
stops <- read.table("modifiedstops.txt",header=TRUE, 
                    sep=",",fill=TRUE,quote = "",row.names = NULL,
                    stringsAsFactors = FALSE) 

#Joining the two data frames so that we know which trains go to which stops (only had ids before)
stop_times_names <- inner_join(stop_times,stops)

setwd("~/subway-flow/gtfs_data/")
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
trains_names$X.stop_name. <- paste(trains_names$X.stop_name.,trains_names$stop_id,sep="")

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

#Loading unique transfer data (differentstopids)
setwd("~/subway-flow/")
transfers <- read.table("differentstopids.txt",header=TRUE, 
                         sep=",",fill=TRUE,quote = "",row.names = NULL,
                         stringsAsFactors = FALSE) 
#Renaming so we can join the transfer data to the train_stopid_lines dataframe
names(transfers)<- c('StopID','TransferID','TransferTime')
names(stops)<- c('TransferID','StationName')
transfers <- inner_join(transfers, stops)

#Combining Stations + TransferIDs as one feature

transfers$StationName <- paste(transfers$StationName,transfers$TransferID, sep="")
#joining 
transfers_stopids_lines <- inner_join(unique_train_lines,transfers)
#joining the two data frames together
transfer_lines <- train_stopid_lines
transfer_lines$Station=NULL
transfer_lines$Train=NULL
names(transfer_lines) <- c('TransferID','LineName2')
transfers_stopids_lines <- left_join(transfers_stopids_lines,transfer_lines)
transfers_stopids_lines <- transfers_stopids_lines %>% group_by(Train) %>% arrange(TransferID)
transfers_stopids_lines$Train= NULL

transfers_stopids_lines<- transfers_stopids_lines[!duplicated(transfers_stopids_lines),] 
#joining the linenames together so we can merge with turnstile data
transfers_stopids_lines$LineName3 = ""
transfers_stopids_lines <- transfers_stopids_lines %>% group_by(StopID) %>% arrange(LineName2)
transfers_stopids_lines$counter=1

transfers_stopids_lines <- transfers_stopids_lines %>% group_by(StopID) %>% mutate(cdf = cumsum(counter))
n <- 1:length(transfers_stopids_lines$TransferID)
for (i in seq (along=n)){
  if(transfers_stopids_lines$cdf[i] > 1){
      transfers_stopids_lines$LineName3[i] = paste(transfers_stopids_lines$LineName3[i-1],transfers_stopids_lines$LineName2[i],sep="")
      }
    else{
    transfers_stopids_lines$LineName3[i] = paste(transfers_stopids_lines$LineName[i],transfers_stopids_lines$LineName2[i],sep="")
      i
    }
}

maxcdf<- transfers_stopids_lines %>% group_by(StopID) %>% summarize(maxcdf = max(cdf))
transfers_stopids_lines <- inner_join(transfers_stopids_lines,maxcdf)
transfers_stopids_lines <- filter(transfers_stopids_lines,cdf==maxcdf)
transfers_lines <- data.frame(transfers_stopids_lines[,c(1,2,7)])
names(transfers_lines)<-c('Station','StopID','LineName')
all_stopid_line2 <- data.frame(train_stopid_lines[,c(3,4)])
transfers_lines$Station=NULL
transfers_lines<- rbind(all_stopid_line2,transfers_lines)
transfers_lines$counter = 1
transfers_lines <- transfers_lines %>% group_by(StopID) %>% mutate(cdf = cumsum(counter))
maxcdf<- transfers_lines %>% group_by(StopID) %>% summarize(maxcdf = max(cdf))
transfers_lines <- inner_join(transfers_lines,maxcdf)
transfers_lines<- filter(transfers_lines, cdf == maxcdf)
transfers_lines <- data.frame(transfers_lines[,c(1,2)])
names(transfers_lines)<- c('stop_id','line_name')
transfers_lines <- inner_join(transfers_lines,stops)
names(transfers_lines)<- c('stop_id','line_name','google_station')
#Export as R file - change the dir/file name per needs
write.csv(transfers_lines, "~/subway-flow/OldGoogleLineNames.csv") 
