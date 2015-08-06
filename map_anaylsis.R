library(ggmap)
library(ggplot2)
library(dplyr)
data <- read.csv("PrePres/entries_exits_average.csv")
data$X <- NULL
#creating a dataframe of hourly entries and exits by station
by_station <- group_by(data,station_id) %>%
  summarise(hourly_entries = sum(hourly_entries)/6, hourly_exits = sum(hourly_exits)/6, station = station[1], lat = lat[1] , long = long[1])

qmplot(long, lat, data = data, color = as.factor(line_name), size = I(3), darken = .25) 

entries_exits_stats <- data %>%
  mutate(is_night = ifelse(entry_exits_period == "4:8" | entry_exits_period == "8:12" | entry_exits_period == "12:16",  0, 1))

day_entries_exits <-entries_exits_stats %>%
  group_by(station_id, is_night) %>%
  filter(is_night == 0) %>%
  summarise(day_entries = mean(hourly_entries), day_exits = mean(hourly_exits),station = station[1], lat = lat[1] , long = long[1])
day_entries_exits$is_night <- NULL

night_entries_exits <- entries_exits_stats %>%
  group_by(station_id, is_night) %>%
  filter(is_night == 1) %>%
  summarise(night_entries = mean(hourly_entries), night_exits = mean(hourly_exits),station = station[1], lat = lat[1] , long = long[1])
night_entries_exits$is_night <- NULL

# bind day entries/exits and night entries/exits
station_types <- inner_join(day_entries_exits,night_entries_exits)

station_types <- station_types%>%
  mutate(station_type = ifelse(day_entries > 1.1*day_exits & night_exits > 1.1*night_entries, "residential", 
                               ifelse(day_entries < 1.5*day_exits & night_exits < 1.5 * night_entries, "commercial", "link")))

qmplot(long, lat, data = station_types, color = as.factor(station_type), size = I(3), darken = .25) 
   #scale_fill_continuous(name="Station_type")


station_volume <- entries_exits_stats %>% 
  group_by(station_id) %>%
  mutate(volume = ifelse(mean(hourly_entries)>500, "high" , "low" ))

qmplot(long, lat, data = station_volume, color = as.factor(volume), size = I(3), darken = .25) 



#splitting volume by day and night
station_volume_temp <- station_volume %>% 
  group_by(station_id, is_night) %>%
  mutate(volume = ifelse(mean(hourly_entries)>500, "high" , "low" ))

qmplot(long, lat, data = station_volume_temp, color = as.factor(volume), size = I(3), darken = .25) +
  facet_wrap(~is_night)+
  ggtitle("Stations by Volume") + 
  theme_bw()


#######################################################################################################################


station_volume_day <- group_by(entries_exits_stats ,station_id) %>%
  summarise(hourly_entries = sum(hourly_entries)/6, hourly_exits = sum(hourly_exits)/6, station = station[1], line_name=line_name[1], lat = lat[1] , long = long[1])

qmplot(long, lat, data = station_volume_day,  fill = line_name, colour = log(hourly_entries), size = I(3), darken = .25) 

qmplot(long, lat, data = station_volume_day, colour = log(hourly_entries), size = I(3)) +
  scale_colour_gradient(low = "green", high = "red") 


qmplot(long, lat, data = station_volume_day, colour = log(hourly_entries/hourly_exits), size = I(3)) +
  scale_colour_gradient(low = "green", high = "red") 





