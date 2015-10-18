  library(dplyr)
  library(ggmap)
  library(RgoogleMaps)
  library(ggmap)
  library(grid)
  library(geosphere)
  
  # Creates a map of a location
  create_city_basemap <- function(cityname, long=NULL, lat=NULL) {
        if (!is.null(long)){
      centre_map = data.frame(lon=c(long), lat=c(lat))
    }
    else{
      centre_map <- geocode(cityname)
    }
    
    city_mapdata <- get_map(c(lon=centre_map$lon, lat=centre_map$lat),zoom = 12, maptype = "terrain", source = "google")
    return(city_mapdata)
  }
  
#time period for which to calculate the flow 
time<- "Noon"
timeperiod<- paste(tolower(time),"flows.csv",sep="")

#reading flow data for specific time
setwd("~/subway-flow/PrePres/")
  
timeflows <- read.table(timeperiod,header=FALSE, 
                      sep=",",fill=TRUE,quote = "",row.names = NULL,
                      stringsAsFactors = FALSE) 
names(timeflows)<- c('fromstation','from_stationid','tostation','to_stationid','flow')
timeflows <- data.frame(timeflows[,c(1,3,5)])
timeflows<- filter(timeflows, flow >0)
  
#reading traintravel data
setwd("~/subway-flow/")
  
traintravel <- read.table("SingularTrainFlowLatLon.csv",header=TRUE, 
                      sep=",",fill=TRUE,quote = "",row.names = NULL,
                      stringsAsFactors = FALSE) 
traintravel<- data.frame(traintravel[,c(2,5,6,8,9)])

traintravel2<- read.table("SingularTrainFlow.csv",header=TRUE, 
                         sep=",",fill=TRUE,quote = "",row.names = NULL,
                         stringsAsFactors = FALSE) 
  
names(traintravel)<- c("train","fromstation","timetravel","stop_lat","stop_lon")
traintravel<- left_join(traintravel,timeflows)
  
#Combining the station lat/lons with flow data frame
station_info <- subset(traintravel,select=c("fromstation","stop_lat","stop_lon"))
names(station_info) <- c('fromstation','from_lat','from_lon')
timeflows <- left_join(timeflows,station_info)
names(station_info) <- c('tostation','to_lat','to_lon')
timeflows <- left_join(timeflows,station_info)
timeflows <- unique(timeflows)

distancetoCentral <- function(lon,lat){
  points<- cbind(lon,lat) 
  distGeo(points,t(matrix(c(-73.9765, 40.7528))))  #METERS. THIS POINT = GRAND CENTRAL
}

timeflows <- timeflows %>%  mutate(inbound = distancetoCentral(from_lon,from_lat)>distancetoCentral(to_lon,to_lat))
timeflows$inbound <-ifelse(timeflows$inbound==TRUE, "Inbound","Outbound")

#nyc_basemap <- create_city_basemap("manhattan",long=-73.95, lat=40.7389)

#saved <- ggmap(nyc_basemap)+ geom_point(aes(x=to_lon, y=to_lat, color = inbound, size=flow,alpha= 0.5), data=timeflows) + scale_size_area() +
#geom_segment(data=filter(timeflows),
 #            aes(x=from_lon, y=from_lat, xend=(to_lon+from_lon)/2, yend=(to_lat+from_lat)/2, 
  #                       color=inbound)) + ggtitle(paste(time,"Flow", sep=" ")) 



saved <- ggmap(nyc_basemap)+ 
  geom_point(data=timeflows, 
    aes(x=to_lon, y=to_lat, colour = inbound, size=flow,alpha= 0.3),show_guide=FALSE) +
      scale_size_area(max_size=4) +
  geom_segment(data=timeflows,
    aes(x=to_lon, y=to_lat, xend=(from_lon+to_lon)/2, yend=(to_lat+from_lat)/2,  colour=inbound)) + 
 # ggtitle(paste(time,"Flow\n", sep=" ")) +
  theme(legend.title=element_blank(),axis.text.y=element_blank(),axis.ticks=element_blank(), 
        axis.text.x=element_blank(),axis.title.x=element_blank(), axis.title.y=element_blank(),
        legend.position=c(.15,.9)) + 
  scale_colour_manual(values = c("#2b3277","#841d3f"))

timeperiod<- substr(timeperiod,0,3)
name=paste("/home/ewahmed/Images/",time,"flows.png",sep="")

ggsave(file=name,plot= saved, width=6, height = 5)

new <- ggmap(nyc_basemap)+ 
  geom_point(data=traintravel, 
             aes(x=stop_lon, y=stop_lat, colour = train)) + geom_path(data=traintravel,aes(x=stop_lon,y=stop_lat,colour=train))+
  scale_size_area(max_size=4) +
  theme(legend.title=element_blank(),axis.text.y=element_blank(),axis.ticks=element_blank(), 
        axis.text.x=element_blank(),axis.title.x=element_blank(), axis.title.y=element_blank(),legend.key.size=unit(0.8,"lines"),
        legend.position=c(.1,.5))

ggsave(file="/home/ewahmed/Images/mta.png",plot= new, width=6, height = 5)