#Riva Tropp
#8/4/2015
#Makes some of my plots; all with a little tweaking. Requires a folder called "Graphics" in subway flow.

library(maptools)
library(ggplot2)
library(ggmap)
library(dplyr)
library(Cairo)
library(RgoogleMaps)
library(stringr)
library(rgdal)
library(RColorBrewer)
library(scales)
setwd("~/subway-flow")

create_city_basemap <- function(cityname, long=NULL, lat=NULL) {
  # Creates a map of a location
  if (is.null(long)){
    centre_map = data.frame(lon=c(long), lat=c(lat))
  }
  else{
    centre_map <- geocode(cityname)
  }
  
  city_mapdata <- get_map(c(lon=centre_map$lon, lat=centre_map$lat),zoom = 12, source = "google", maptype = "roadmap")
  return(city_mapdata)
}


load_shapefile <- function(filepath, shapefile_name){
  # Returns the mapdata (area polygons) for school zones
  
  shapefile = readOGR(dsn=filepath, layer=shapefile_name)
  t_shapefile<- spTransform(shapefile, CRS("+proj=longlat +datum=WGS84"))
  return(t_shapefile)
}


get_addresses <- function(filename){
  # Reads a csv file with addresses and adds their latitude and longitude
  address_input_df<- read.csv(filename)
  addresses <- paste(str_trim(address_input_df$street_address),address_input_df$zipcode, sep=" ")
  latlong_df <- geocode(addresses)
  address_df <- cbind(address_input_df, latlong_df)
  coordinates(address_df) <- ~ lon + lat
  return(address_df)
}

make_map <- function(subway_all){
  nyc_school_map <- nyc_map +                                         
    geom_polygon(aes(x=long, y=lat, group=group, fill= as.factor(true_pop_binned)), 
                 size=.2, color = "black", data=subway_all, alpha=.75) +
    #geom_point(aes(x = as.numeric(stop_lon), y = as.numeric(stop_lat)), data = subway_stations) +
    scale_fill_discrete() + 
    theme(legend.text = element_text(size = 10)) +
    ggtitle(paste0("Estimated Population: ", t_name)) +
    theme(plot.title=element_text(lineheight = 1.5, family="Palatino", size=15)) +
    scale_fill_manual(values = c("#fff5f0", "#fcbba1", "#fb6a4a", "#cb181d", "#a50f15", "#67000d"), 
                      name = "", 
                      labels = c("1-10K", "10K-30K", "30K-100K", "100K-300K", "300K-1M", "1M+"))
}
########################################################################################
########################################################################################

#load("~/subway-flow/nyc_map.RData")
nyc_map <- qmap(c(lon=-73.95, lat = 40.7389),zoom = 12, source = "google", maptype = "terrain")

########################################################################################
########################################################################################

map_stuff <- function(times, plot_zip, nyc_map, t_name, i) {
#    times = c("0:4")
#    t_name = "Test"
#    i = 1
    
    #Joining two datasets to create population/zipcode dataframe.
    names(census)[3] <-  "NTACode" 
    zip_pop_data <- inner_join(zip_shape@data, census)
  
    zip_pop_data$id <- as.numeric(row.names(zip_pop_data))-1 #zip_shape@data and census share id/rownames.
    plot_zip$id <- as.numeric(plot_zip$id)

    #Recombine Zip-code/population data with the shapefile, fix stupid formatting. 
    zip_pop_shape <- inner_join(plot_zip, zip_pop_data)
    zip_pop_shape$pop_2010 <- as.numeric(gsub(",", "", zip_pop_shape$pop_2010))
  
    ################################################################################

    #Now loading in subway information.    
    subway_flow <- read.table("PrePres/Census/all_entries_exits.csv",header=TRUE, 
                         sep=",",fill=TRUE, quote = "\"", row.names = NULL,  
                         stringsAsFactors = FALSE) 
  
    #Make maps that add each time period's offset to the next.
    subway_flow <- filter(subway_flow, entry_exits_period %in% times)
    subway_flow <- subway_flow %>% mutate(net_gain = (rounded_scaled_exits-new_rounded_hourly_entries)*4)
    
    
  
    subway_stations <- read.table("SingularTrainFlowLatLon.csv",header=TRUE, 
                            sep=",",fill=TRUE, quote = "\"", row.names = NULL,  
                            stringsAsFactors = FALSE) 

    s_points <- subway_stations
    subway_stations <- inner_join(subway_stations, subway_flow, by = "station_id")
    subway_stations <- subway_stations[!duplicated(subway_stations),]
    subway_stations <- subway_stations[c("station_id", "stop_lat", "stop_lon", "station.x", "net_gain")]
  
  coordinates(subway_stations) <- ~stop_lon + stop_lat
  proj4string(subway_stations) <- proj4string(zip_shape) #Makes the projection the same
  temp <- over(subway_stations, zip_shape)
  subway_plot <- cbind(subway_stations, temp)
  
  subway_plot %>% group_by(NTACode) %>% mutate(offset = sum(net_gain)) -> subway_plot
  
  subway_all <- right_join(subway_plot, zip_pop_shape)
  subway_all <- subway_all %>% mutate(offset = ifelse(is.na(offset), 0, offset))
  
  subway_all$true_pop = subway_all$offset + subway_all$pop_2010
  
  if(times[length(times)] == "c"){
      subway_all$true_pop <- subway_all$pop_2010
  }
  subway_all$true_pop <- pmax(subway_all$true_pop, 1)
  scale <- c(1, 10000, 30000, 100000, 300000, 1000000, 1500000)
  subway_all$true_pop_binned <- cut(subway_all$true_pop, scale, ordered_result = TRUE, include.lowest = TRUE)

  nyc_subway_map <- nyc_map +                                         
    geom_polygon(aes(x=long, y=lat, group=group, fill= as.factor(true_pop_binned)), 
                 size=.2, data=subway_all, alpha=.75) +
    geom_polygon(aes(x=long, y=lat, group=group, fill= as.factor(true_pop_binned)), 
                 size=.2, color = "black", data=subway_all, alpha=.1, show_guide = FALSE) +
    #geom_point(aes(x = as.numeric(stop_lon), y = as.numeric(stop_lat)), data = s_points) +
    theme(legend.text = element_text(size = 10)) +
    guides(colour = guide_legend(override.aes = list(alpha = 1))) +
    ggtitle(paste0("Population Estimate: ", t_name)) +
      theme(plot.title=element_text(lineheight = 1.5, family="Palatino", size=15)) +
      scale_fill_manual(values = c("#fff5f0", "#fcbba1", "#fb6a4a", "#cb181d", "#a50f15", "#67000d"), 
                      name = "", 
                      labels = c("1-10K", "10K-30K", "30K-100K", "100K-300K", "300K-1M", "1M+"))
  
  #nyc_points_map <- nyc_map + 
  #  geom_point(aes(x = as.numeric(stop_lon), y = as.numeric(stop_lat)), data = s_points)
  
    
  print (times)

  print (nyc_subway_map)
  filepath <- paste0("./Graphics/", i, "_", times[length(times)])
  filename <- paste0(filepath, "_mapbucket.png")
  
  ggsave(file =  filename, plot = nyc_subway_map)
}

#################################################################################################
#START HERE
################################################################################################

#Vector of timeframes to go through and their names.
all_times <- c("4:8", "8:12", "12:16", "16:20", "20:0", "0:4", "c")
names_times <- c("8 a.m. - Early Morning", "12 p.m. - Noon", "4 p.m. - Afternoon", "8 p.m. - Evening", "12 a.m. - Night", "4 a.m. - Late Night", "Census Numbers")
put_times <- c()

#Zip code information.
filepath <- "../Downloads/nynta_14d"
shapefile <- "nynta"

#Amit's code to load shapefiles.
zip_shape <- load_shapefile(filepath, shapefile)

#Makes into a plot?
plot_zip <- fortify(zip_shape) 

#Load in census information with NTA codes.
census <- read.table("../Downloads/pop_nta.csv",header=TRUE, 
                       sep=",",fill=TRUE, quote = "\"", row.names = NULL,  
                       stringsAsFactors = FALSE) 


names(census)[3] <-  "NTACode" #Make columns consistent.

#Now we have census data per zip codes.
zip_pop_data <- inner_join(zip_shape@data, census)

#To make our population per boundary consistent with the data inside the shapefile.
zip_pop_data$id <- as.numeric(row.names(zip_pop_data))-1 

plot_zip$id <- as.numeric(plot_zip$id)

zip_pop_shape <- inner_join(plot_zip, zip_pop_data)
zip_pop_shape$pop_2010 <- as.numeric(gsub(",", "", zip_pop_shape$pop_2010))
scale <- c(1, 10000, 30000, 100000, 300000, 1000000, 1500000)
zip_pop_shape$pop_2010 <- cut(zip_pop_shape$pop_2010, scale, ordered_result = TRUE, include.lowest = TRUE)


for (i in 1:length(all_times)){

  put_times[i] <- all_times[i]
  map_stuff(put_times, plot_zip, nyc_map, names_times[i], i)

}

