#################################################################
# Description: Code to load turnstile data into master dataframe
#################################################################
library(dplyr)
library(timeDate) 
library(reshape)
library(ggplot2)
library(data.table)

setwd("~/Desktop/subway-flow/MergingData")
######################################################################################################################
# Merging turnstile data with GTSF data
######################################################################################################################
n_names = read.table("readyformerge.txt",header=FALSE, sep=",", # current turnstyle dataframe
                     quote = "", row.names = NULL, strip.white = TRUE, 
                     stringsAsFactors = FALSE) 
names(n_names)[0:5] <- c("Transformed Turnstile Name", "Distance", "stop_name", "Transformed Google Name", "STATION")

n_names <- data.frame(n_names[,c(3,5)])

l_lines = read.table("s_gtfs_names.csv",header=TRUE, sep=",", #Stop_ids
                     fill=TRUE,quote = "", row.names = NULL, strip.white = TRUE,
                     stringsAsFactors = FALSE) 
all_lines <- as.data.frame(sapply(l_lines, function(x) gsub("\"", "", x)))

all_lines <- data.frame(all_lines[,c(2,3,4)])
names(all_lines) <- c("station_id", "line_name", "stop_name")

names_lines <- left_join(n_names, all_lines)
names_lines <- data.frame(names_lines[,c(2,3,4)])

setwd("~/Desktop/subway-flow/MergingData/new_ts") # go to file to store merged turnstile data
txts <- Sys.glob(sprintf('%s/turnstile_1*.txt', "~/Desktop/subway-flow/MergingData/new_ts"))
txts <- txts[12] # take three months of data
subwaydata <- data.frame()
for (txt in txts) {
   tmp <- read.table(txt, header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)
   subwaydata <- rbind(subwaydata, tmp)
}
setwd("~/Desktop/subway-flow/MergingData/new_ts")
subwaydata <- right_join(subwaydata, names_lines, by = c("STATION", "AEILMN" = "line_name"))
######################################################################################################################
# modify subwaydata dataframe
######################################################################################################################
# creating dataframe with num_entries, num_exits, and time difference
names(subwaydata) <- tolower(names(subwaydata))
setnames(subwaydata, old=c("aeilmn"), new=c("line_name"))
subwaydata$date.time <- with(subwaydata, paste(date, time, sep=' '))
subwaydata$date.time <- with(subwaydata, strptime(date.time, "%m/%d/%Y %H:%M:%S"))
subwaydata$date.time <- with(subwaydata, as.POSIXct((date.time)))
subwaydata <- group_by(subwaydata, c.a, unit, scp, station, line_name)

subwaydata <- arrange(subwaydata, date.time) %>%
  mutate(time.delta = as.numeric(date.time-lag(date.time),units="hours"),
         entries.delta = entries - lag(entries),
         exits.delta = exits - lag(exits),
         day_of_week = dayOfWeek(as.timeDate(date)),
         is_weekday = ifelse(isWeekday(date.time) == TRUE, 1, 0))

subwaydata <- filter(subwaydata, time.delta <= 12) 

# create time periods
subwaydata <-subwaydata %>%
  mutate(entry_exits_period = ifelse(time > "0:00:00" & time <= "04:00:00", "0:4",
                              ifelse(time > "04:00:00" & time <= "08:00:00", "4:8",
                              ifelse(time > "08:00:00" & time <= "12:00:00", "8:12",
                              ifelse(time > "12:00:00" & time <= "16:00:00", "12:16",
                              ifelse(time > "16:00:00" & time <= "20:00:00", "16:20", '20:0'))))))

# compute hourly entries/exits 
entry_exit_rates <- group_by(subwaydata, station, line_name , entry_exits_period, date) %>%
  summarise(hourly_entries = sum(entries.delta)/4,hourly_exits = sum(exits.delta)/4)

# determine part of day
entry_exit_rates <- subwaydata %>% 
  mutate(is_night = ifelse(time <= "16:00:00" & time >= "04:00:00",  1, 0))

################################################################################################################
# filter subwaydata
################################################################################################################

subwaydata <- subwaydata %>% 
  filter(entries.delta < 100000) %>%
  filter(exits.delta < 100000) %>%
  filter(exits.delta > -1) %>%
  filter(entries.delta > -1) %>%
  filter(is_weekday == 1)
     
################################################################################################################
# hourly entries/exits stats
################################################################################################################

# get entries/exits per day ratios in time period for all stations 
subway_time_ratios <- subwaydata %>%
  group_by(entry_exits_period, is_weekday) %>% 
  filter(is_weekday == 1) %>%
  summarize(entries_per_hr=mean(hourly_entries), exits_per_hr=mean(hourly_exits), entries_exits_ratio=entries_per_hr/exits_per_hr)

# get entries/exits for each weeekday ratios in time period for all stations
subway_time_ratios <- subwaydata %>%
  group_by(entry_exits_period, station, is_weekday, station_id, day_of_week) %>%
  filter(is_weekday == 1) %>%
  summarize(entries_per_hr=mean(hourly_entries), exits_per_hr=mean(hourly_exits), entries_exits_ratio=entries_per_hr/exits_per_hr, standard_entries = sd(hourly_entries), standard_exits = sd(hourly_exits))

# get entries/exits per day ratios in time period for individual stations
subway_time_ratios <- subwaydata %>%
  group_by(entry_exits_period, station, is_weekday, station_id) %>%
  filter(is_weekday == 1) %>%
  summarize(entries_per_hr=mean(hourly_entries), exits_per_hr=mean(hourly_exits), entries_exits_ratio=entries_per_hr/exits_per_hr, standard_entries = sd(hourly_entries), standard_exits = sd(hourly_exits))

# get entries/exits for each weekday ratios in time period for individual stations
subway_time_ratios <- subwaydata %>%
  group_by(entry_exits_period, station, is_weekday, station_id, day_of_week) %>%
  filter(is_weekday == 1) %>%
  summarize(entries_per_hr=mean(hourly_entries), exits_per_hr=mean(hourly_exits), entries_exits_ratio=entries_per_hr/exits_per_hr, standard_entries = sd(hourly_entries), standard_exits = sd(hourly_exits))

# boxplot of entries_per_hr for all stations
ggplot(data=subway_time_ratios, aes(x=station,
                                y=entries_per_hr)) +
  ggtitle("Entries/hr for all stations") +
  xlab("station") +
  ylab("No. Entries & Exits per HR")+
  geom_boxplot() 

ggplot(data=subwaydata, aes(x=station,
                     y=hourly_entries)) +
  ggtitle("Entries/HR for all stations") +
  xlab("station") +
  ylab("No. Entries & Exits per hr")+
  geom_boxplot() 

#################################################################################################
# get mean entries and exits for day and night
#################################################################################################

# get mean entries and exits for day and night
stations_type <- stations_type %>% 
  select(station, time, hourly_entries, hourly_exits, is_night) %>%
  group_by(station, is_night) %>%
  summarize(mean_entries = mean(hourly_exits), mean_exits=mean(hourly_entries))

mean_day_entries <- subwaydata %>%
  filter(is_night == 0) %>%
  select(mean_entries)
mean_day_entries <- rename(mean_day_entries, c(mean_entries="mean_day_entries"))
  
mean_night_entries <- as.data.frame(stations_type) %>%
  filter(is_night == 1) %>%
  select(mean_entries)
mean_night_entries <- rename(mean_night_entries, c(mean_entries="mean_night_entries"))

mean_day_exits <- as.data.frame(stations_type) %>%
  filter(is_night == 0) %>%
  select(mean_exits) 
mean_day_exits <- rename(mean_day_exits, c(mean_exits="mean_day_exits"))

mean_night_exits <- as.data.frame(stations_type) %>% 
  filter(is_night == 1) %>%
  select(mean_exits)
mean_night_exits <- rename(mean_night_exits, c(mean_exits="mean_night_exits"))

stations <- unique(stations_type$station)

stations_stats <- data.frame() # store new stats in new dataframe
stations_stats <- cbind(stations, mean_day_exits, mean_day_entries, mean_night_exits, mean_night_entries)

stations_type <- stations_stats %>%
  mutate(station_type = ifelse(mean_day_entries > 2*mean_day_exits & mean_night_exits > 2*mean_night_entries, "residential", 
                                ifelse(mean_day_entries < 2*mean_day_exits & mean_night_exits < 2 * mean_night_entries, "commercial", "commuter")))


