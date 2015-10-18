#Eiman Ahmed

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

#Joining the stop names with the stop_times data frame so we know the names of the various stops
stop_times_names <- inner_join(stop_times,stops)

#Read in the information so that I have trips only 
trips <- read.table("trips.txt",header=TRUE, 
                    sep=",",fill=TRUE,quote = "",row.names = NULL,
                    stringsAsFactors = FALSE) 

#Parse so we have the trains with their trip_ids and we can then merge so we have only trains
trips <- data.frame(trips[,c(1,3)])
trains_info <- inner_join(trips, stop_times_names)

#getting the day of the week the trip was recorded on (THE 3 TRAIN HAS NO TRIPS ON WKD?????????)
trains_info$day <- substr(trains_info$trip_id,10,12)

#Subtracting times: column n - column n-1
trains_info$departure_time <- as.POSIXct(trains_info$departure_time, format='%H:%M:%S')
trains_info<- mutate(trains_info, duration = departure_time - lag(arrival_time))

#Trying to get only times between 9am-6pm 
trains_info$departure_time <- strftime(trains_info$departure_time, format="%H:%M:%S")
trains_info <- trains_info %>% mutate(is_good = ifelse(departure_time<= "18:00:00" & departure_time > "09:00:00", 1, 0))

#Filtering for day= WKD and timing between 9am 6pm
trains_info <- filter(trains_info,is_good==1 & day=="WKD")

#reformatting with only columns we need
trains_info$trip_id=NULL
trains_info<- data.frame(trains_info[,c(1,6,4,5,8)])

#Renaming columns because..... I want to 
colnames(trains_info) <- c("Train","Station","StopID","Stop","Duration")

#Combine trips with their stops to get format of B01 B02 etc
zero<- "0"
trains_info$Stop <- paste(zero,trains_info$Stop,sep="")
trains_info$TrainStop <- 
  paste(trains_info$Train,trains_info$Stop,sep="")

#Get rid of north and south on the stop ids
trains_info$StopID <- substr(trains_info$StopID,0,3)

#Getting rid of duplicate train info that we do not need

#You can try this too but just to be on the safe side, I did manual check and plug in 
#trains_info$counter=1
#trains_info <- trains_info %>% group_by(TrainStop) %>% mutate(cdf = cumsum(counter))
#trains_info <- filter(trains_info,cdf==1)

#Entire 1 track is from rows 25894 - 25931
train_extraction<- rbind(trains_info[25894:25931,])
#Entire 2 track is from rows 36200  - 36251
train_extraction <- rbind(train_extraction,trains_info[36200:36251,])
#Entire 3 track is from 41064 - 41097
train_extraction <- rbind(train_extraction,trains_info[41064:41097,])
#Entire 4 track is from rows 551 - 585
train_extraction <- rbind(train_extraction,trains_info[551:585,])
#Entire 5 track is from 4701- 4726
train_extraction <- rbind(train_extraction,trains_info[4701:4726,])
#Entire 6 track is from 10454 - 10491
train_extraction <- rbind(train_extraction,trains_info[10454:10491,])
#Entire 6X track is from 10763 - 10795
train_extraction <- rbind(train_extraction,trains_info[10763:10795,])
#Entire 7 track is from 19960-19980
train_extraction <- rbind(train_extraction,trains_info[19960:19980,])
#Entire 7X track is from 20128 - 20138
train_extraction <- rbind(train_extraction,trains_info[20128:20138,])
#Entire A track is from 86703 - 86739
train_extraction <- rbind(train_extraction,trains_info[86703:86739,])
#Entire B track is from 91513 - 91549
train_extraction <- rbind(train_extraction,trains_info[91513:91549,])
#Entire C track is from 94855 - 94894
train_extraction <- rbind(train_extraction,trains_info[94855:94894,])
#Entire D track is from 99301 - 99336
train_extraction <- rbind(train_extraction,trains_info[99301:99336,])
#Entire E track is from 46019 - 46038 
train_extraction <- rbind(train_extraction,trains_info[46019:46038,])
#Entire F track is from 49821 - 49865
train_extraction <- rbind(train_extraction,trains_info[49821:49865,])
#Entire FS track is from 57467 - 57470
train_extraction <- rbind(train_extraction, trains_info[57467:57470,])
#Entire GS track is from 25278 - 25279 
train_extraction <- rbind(train_extraction,trains_info[25278:25279,])
#Entire G track is from 57899- 57919
train_extraction<- rbind(train_extraction,trains_info[57899:57919,])
#Entire H track is from 60372- 60376
train_extraction <- rbind(train_extraction,trains_info[60372:60376,])
#Entire J track is from 60819 - 60848
train_extraction<- rbind(train_extraction,trains_info[60819:60848,])
#Entire L track is from 64186 - 64209
train_extraction <- rbind(train_extraction,trains_info[64186:64209,])
#Entire M track is from 69305 -  69340 
train_extraction <- rbind(train_extraction,trains_info[69305:69340,])
#Entire N track is from 73407 - 73438 
train_extraction <- rbind(train_extraction,trains_info[73407:73438,])
#Entire Q track is from 77073 - 77107
train_extraction <- rbind(train_extraction,trains_info[77073:77107,])
#Entire R track is from 81046 - 81090 
train_extraction <- rbind(train_extraction,trains_info[81046:81090,])
#Entire SI track is from 103409 - 103430
train_extraction <- rbind(train_extraction,trains_info[103409:103430,])
#Entire Z track is from 62521 - 62541
train_extraction <- rbind(train_extraction,trains_info[62521:62541,])

#Clean the duration so that we get rid of the weird durations (-7k etc)
trains_info <- train_extraction
trains_info[trains_info$Stop == "01",]$Duration=0

#Put the stop id's next to the station 
trains_info$Station <- paste(trains_info$Station,trains_info$StopID,sep="")

#Put it in the order we want so we can manipulate the data
trains_info <- mutate(trains_info, TrainStop2 = lag(TrainStop))
trains_info <- mutate(trains_info, Station2= lag(Station))
trains_info <- mutate(trains_info,StopID2= lag(StopID))

#Get rid of NA
trains_info[trains_info$Stop == "01",]$Station2=NA
trains_info<- trains_info[complete.cases(trains_info),]

#Change the names of the columns and add a column with the train being tracked
trains_info <- data.frame(trains_info[,c(1,8,9,2,3,5)])
names(trains_info) <- c("Train","FromStation",'FromStationID','ToStation','ToStationID',"TravelTime")

#Export as R file - change the dir/file name per needs
write.csv(trains_info, "/home/ewahmed/subway-flow/TrainTravel.csv")