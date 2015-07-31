  library(dplyr)
  library(ggmap)
  library(RgooglMaps)
  library(ggmap)
  create_city_basemap <- function(cityname, long=NULL, lat=NULL) {
    # Creates a map of a location
    if (!is.null(long)){
      centre_map = data.frame(lon=c(long), lat=c(lat))
    }
    else{
      centre_map <- geocode(cityname)
    }
    
    city_mapdata <- get_map(c(lon=centre_map$lon, lat=centre_map$lat),zoom = 11, maptype = "terrain", source = "google")
    return(city_mapdata)
  }
  
  setwd("~/subway-flow/PrePres")
  noon <- read.table("f_noon.csv",header=TRUE, 
                      sep=",",fill=TRUE,quote = "",row.names = NULL,
                      stringsAsFactors = FALSE) 
  
  noon <- subset(noon,select=c("station_id","rounded_scaled_exits",
                                           "new_rounded_hourly_entries"))
  setwd("~/subway-flow/")
  noonflows <- read.table("noonflows.csv",header=FALSE, 
                      sep=",",fill=TRUE,quote = "",row.names = NULL,
                      stringsAsFactors = FALSE) 
  names(noonflows)<- c('fromstation','from_stationid','tostation','to_stationid','flow')
  noonflows$paircode <- rownames(noonflows)
  
  setwd("~/subway-flow")
  traintravel <- read.table("SingularTrainFlowLatLon.csv",header=TRUE, 
                      sep=",",fill=TRUE,quote = "",row.names = NULL,
                      stringsAsFactors = FALSE) 
  traintravel<- data.frame(traintravel[,c(2,3,4,5,6,7,8,9)])
  
  traintravel_noon <- inner_join(traintravel,noon)
  
#x11(width=6,height=48)
#nyc_basemap <- create_city_basemap("manhattan",long=-73.95, lat=40.7389)
 #ggmap(nyc_basemap) + geom_point(aes(x=stop_lon, y=stop_lat, color=train), data=traintravel_noon) + 
 #geom_path(aes(x=stop_lon, y=stop_lat, group=as.factor(station_id),color = as.factor(train),size=new_rounded), data=traintravel_noon)

#ggsave("~/subway-flow/MTAMap.jpeg")

#dummy <- traintravel_noon 
#names(noonflows)<- c("fromstation","station_id","tostation","tostationid","flow","paircode")
#dummy <- inner_join(noonflows,dummy)

df1 <- data.frame(traintravel_noon[,c("station_id","station","stop_lat","stop_lon")])
df1 <- unique(df1)
names(df1)<- c("from_stationid","station","stop_lat","stop_lon") #change fromstation_id to station_id to merge
df2 <- inner_join(df1,noonflows)
names(df1)<- c("to_stationid","station","stop_lat","stop_lon") #change fromstation_id to station_id to merge
df3 <- inner_join(df1,noonflows)

  
  
#pair code
x11(width=6,height=48)
nyc_basemap <- create_city_basemap("manhattan",long=-73.95, lat=40.7389)
ggmap(nyc_basemap) + geom_point(aes(x=stop_lon, y=stop_lat, color=train), data=dummy) + 
geom_path(aes(x=stop_lon, y=stop_lat, group=as.factor(paircode),color = as.factor(train),size=flow), data=dummy)
#qmplot(stop_lon, stop_lat, data = traintravel_noon, colour = as.factor(train))

#write.csv(traintravel_noon,"~/subway-flow/PrePres/GraphingData/traintravelnoon.csv",quote=FALSE)