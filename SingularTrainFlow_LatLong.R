library(dplyr)

#Reading in the information from stop_times.txt
setwd("/home/ewahmed/Desktop/SubwayData/")
stops <- read.table("stops.txt",header=TRUE, 
                         sep=",",fill=TRUE,quote = "",row.names = NULL,
                         stringsAsFactors = FALSE) 

setwd("/home/ewahmed/subway-flow/")
flow <- read.table("SingularTrainFlow.csv",header=TRUE, 
                   sep=",",fill=TRUE,quote = "",row.names = NULL,
                   stringsAsFactors = FALSE) 

stops$stop_id = substr(stops$stop_id, 0, 3)
stops<- unique(subset(stops,select=c("stop_id","stop_lat","stop_lon")))

stops_flow <- inner_join(flow,stops)

#taking only the first lat long for each station
firstids <- stops_flow %>% group_by(station_id) %>% summarise(stop_lat=first(stop_lat),stop_lon=first(stop_lon))
stops_flow$stop_lat= NULL
stops_flow$stop_lon=NULL
stops_flow <- inner_join(stops_flow,firstids,by="station_id")

stops_flow <- subset(stops_flow,select=c("train","train_stop","station_id","station","time_travel","line_name","stop_lat","stop_lon"))

write.csv(stops_flow,"/home/ewahmed/subway-flow/SingularTrainFlowLatLon.csv",quote=FALSE)