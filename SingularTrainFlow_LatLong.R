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

write.csv(stops_flow,"/home/ewahmed/subway-flow/SingularTrainFlowLatLon.csv",quote=FALSE)