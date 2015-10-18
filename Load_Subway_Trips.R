########################################################################################################################################################################
# Description: Code to load turnstile data into master dataframe and review statistics
# 
########################################################################################################################################################################
library(dplyr)
library(timeDate) 
library(reshape)
library(ggplot2)
library(data.table)
library(tidyr)

setwd("~/subway-flow")

######################################################################################################################
# Merging turnstile data with GTSF data
######################################################################################################################
source("trainnames.R")

######################################################################################################################
# modify subwaydata dataframe
######################################################################################################################
allts <- read.csv("allts.csv", stringsAsFactors = FALSE)  # read csv file 
subwaydata <- as.data.frame(allts) %>%select(-AEILMN) # drop aeilmn column

# creating dataframe with num_entries, num_exits, and time difference
names(subwaydata) <- tolower(names(subwaydata))
subwaydata$date.time <- with(subwaydata, paste(date, time, sep=' '))
subwaydata$date.time <- with(subwaydata, strptime(date.time, "%m/%d/%Y %H:%M:%S"))
subwaydata$date.time <- with(subwaydata, as.POSIXct((date.time)))

subwaydata <- group_by(subwaydata, c.a, unit, scp, station, line_name) # select unique turnstiles for each station

subwaydata <- arrange(subwaydata, date.time) %>%
  mutate(time.delta = as.numeric(date.time-lag(date.time),units="hours"),
         entries.delta = entries - lag(entries),
         exits.delta = exits - lag(exits),
         day_of_week = dayOfWeek(as.timeDate(date)))

subwaydata <- filter(subwaydata, time.delta <= 12) 

subwaydata$time
# create time periods
subwaydata <-subwaydata %>%
  mutate(entry_exits_period = as.character(ifelse(time > "0:00:00" & time <= "04:00:00", as.character("0:4"),
                                           ifelse(time > "04:00:00" & time <= "08:00:00", "4:8",
                                           ifelse(time > "08:00:00" & time <= "12:00:00", "8:12",
                                           ifelse(time > "12:00:00" & time <= "16:00:00", "12:16",
                                           ifelse(time > "16:00:00" & time <= "20:00:00", "16:20", "20:0")))))))


################################################################################################################
# filter subwaydata
################################################################################################################

subwaydata <- filter(subwaydata, time.delta <= 12) 

subwaydata <- subwaydata %>% 
  filter(entries.delta < 100000) %>%
  filter(exits.delta < 100000) %>%
  filter(exits.delta > -1) %>%
  filter(entries.delta > -1) 

# compute entries/exits for time period for each date for all stations
entries_exits_rates_weekends <- group_by(subwaydata, station_id, entry_exits_period, date) %>%
  summarise(hourly_entries = sum(entries.delta)/4,hourly_exits = sum(exits.delta)/4, station = station[1], line_name=line_name[1], lat=lat[1], long=long[1]) 

write.csv(entries_exits_rates_weekends, file = "subway_entries_exits_weekends.csv")

subwaydata <- subwaydata %>% # rid data of weekends
  filter(day_of_week != "Sun" & day_of_week != "Sat")

################################################################################################################
# hourly entries/exits stats
################################################################################################################
# compute entries/exits for time period for each date for all stations
entries_exits_rates <- group_by(subwaydata, station_id, entry_exits_period, date) %>%
  summarise(hourly_entries = sum(entries.delta)/4,hourly_exits = sum(exits.delta)/4, station = station[1], line_name=line_name[1], lat=lat[1], long=long[1]) 

write.csv(entries_exits_rates, file = "subway_entries_exits.csv")

# average over all days, do not care about date
entries_exits_period <- group_by(entries_exits_rates, station_id, entry_exits_period) %>%
  summarise(hourly_entries = mean(hourly_entries),hourly_exits = mean(hourly_exits), station = station[1], line_name=line_name[1], lat=lat[1], long=long[1]) 

write.csv(entries_exits_period, file = "entries_exits_average.csv")

# average whole day entries/exits, not six 4-hr periods
entries_exits_daily <- entries_exits_period %>%
  group_by(station,station_id) %>%
  summarise(daily_entries = sum(hourly_entries)/6, daily_exits = sum(hourly_exits)/6)

write.csv(entries_exits_daily, file = "entries_exits_wholeday.csv")

# average 0:12 entries/exits, 
entries_exits_012 <- entries_exits_period %>%
  filter(entry_exits_period  == "0:4" | entry_exits_period == "4:8" | entry_exits_period == "8:12")   %>%
  group_by(station,station_id) %>%
  summarise(daily_entries = sum(hourly_entries)/3, daily_exits = sum(hourly_exits)/3)

write.csv(entries_exits_012, file = "entries_exits_012.csv")

# average 12:24 entries/exits, 
entries_exits_1224 <- entries_exits_period %>%
  group_by(station,station_id) %>%
  filter(entry_exits_period  == "12:16" | entry_exits_period == "16:20" | entry_exits_period == "20:0") %>%
  summarise(daily_entries = sum(hourly_entries)/3, daily_exits = sum(hourly_exits)/3)

write.csv(entries_exits_1224, file = "entries_exits_1224.csv")

temp <- group_by(entries_exits_rates,station, station_id, line_name) %>% summarise(lat = lat[1],long=long[1]) 
temp <- mutate(temp, station_color = ifelse(line_name[1] == "1", "red", "blue"))
