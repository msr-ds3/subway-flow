library(ggmap)
library(ggplot2)

data <- read.csv("PrePres/entries_exits_average.csv")
data$X <- NULL

by_station <- group_by(data,station_id) %>%
  summarise(hourly_entries = sum(hourly_entries)/6, hourly_exits = sum(hourly_exits)/6, station = station[1], lat = lat[1] , long = long[1])


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

ggmap(candle, zoom = 4)

newmap <- get_map(location = 'Manhattan', zoom = 12)

mapPoints <- ggmap(newmap)
head(mapPoints)
plot(newmap, zoom = 14)

head(data)