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

######################################################################################################################
# Merging turnstile data with GTSF data
######################################################################################################################
setwd("~/subway-flow")
source("trainnames.R")

######################################################################################################################
# modify subwaydata dataframe
######################################################################################################################
subwaydata <- as.data.frame(all_ts) %>%select(-AEILMN) # drop aeilmn column

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

subwaydata <- subwaydata %>% # rid data of weekends
  filter(day_of_week != "Sun" & day_of_week != "Sat")


subwaydata <- filter(subwaydata, time.delta <= 12) 

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

################################################################################################################
# hourly entries/exits stats
################################################################################################################
# compute entries/exits for time period for each date for all stations
entries_exits_rates <- group_by(subwaydata, station_id, entry_exits_period, date) %>%
  summarise(hourly_entries = sum(entries.delta)/4,hourly_exits = sum(exits.delta)/4, station = station[1], line_name=line_name[1]) 

write.csv(entries_exits_rates, file = "PrePres/subway_entries_exits.csv")

# average over all days, do not care about date
entries_exits_period <- group_by(subwaydata,station, station_id, entry_exits_period) %>%
  summarise(hourly_entries = sum(entries.delta)/4,hourly_exits = sum(exits.delta)/4, station = station[1], line_name=line_name[1]) 

write.csv(entries_exits_period, file = "PrePres/entries_exits_average.csv")




