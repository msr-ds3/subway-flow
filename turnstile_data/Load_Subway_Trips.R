#################################################################
# Description: Code to load turnstile data into master dataframe
#################################################################
library(dplyr)
library(timeDate) 
library(reshape)
library(ggplot2)
library(data.table)

setwd("~/subway-flow")
######################################################################################################################
# Merging turnstile data with GTSF data
######################################################################################################################
#My Merge Table is read in.
n_names = read.table("./MergingData/readyformerge.txt",header=FALSE, sep=",", # current turnstyle dataframe
                     quote = "", row.names = NULL, strip.white = TRUE, 
                     stringsAsFactors = FALSE) 

#Formatting stuff
names(n_names)[0:5] <- c("Transformed Turnstile Name", "Distance", "stop_name", "Transformed Google Name", "STATION")
n_names <- data.frame(n_names[,c(3,5)])

#Eiman's Station names are read in:
l_lines = read.table("./GoogleLineNames.csv",header=TRUE, sep=",", #Stop_ids
                     fill=TRUE,quote = "", row.names = NULL, strip.white = TRUE,
                     stringsAsFactors = FALSE) 

#MOAR Formatting!
all_lines <- as.data.frame(sapply(l_lines, function(x) gsub("\"", "", x)))
all_lines <- data.frame(all_lines[,c(2,3,4)])
names(all_lines) <- c("station_id", "line_name", "stop_name")

#Eiman's stuff is combined with the nametable
names_lines <- left_join(n_names, all_lines)
names_lines <- data.frame(names_lines[,c(2,3,4)])

#Now we just have the station, E's ID, and the linenames.

#Loading in all TS Files.
data_dir <- "./MergingData/new_ts/"
txts <- Sys.glob(sprintf('%s/turnstile_1*.txt', data_dir))
ts_data <- data.frame()
txts <- txts[1]
for (txt in txts) {
  tmp <- read.table(txt, header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)
  ts_data <- rbind(ts_data, tmp)
}

#Joining TS Files with Eiman's Station Names
all_ts <- left_join(names_lines, ts_data, by = "STATION")

#Turn both linename fields to strings
all_ts$AEILMN <- sapply(all_ts$AEILMN, toString)
all_ts$line_name <- sapply(all_ts$line_name, toString)

#Sebastian's function to get intersection lengths.
overlap <- function(x,y) {length(intersect(strsplit(x, "")[[1]], strsplit(y, "")[[1]]))}

#Columns to get intersection, get min length of string
all_ts$intersect <- mapply(overlap, all_ts$AEILMN, all_ts$line_name)
all_ts$lenline <- sapply(all_ts$line_name, nchar)
all_ts$lenaiel <- sapply(all_ts$AEILMN, nchar)
all_ts$minline <- mapply(min, all_ts$lenaiel, all_ts$lenline)
all_ts$lenline <- NULL
all_ts$lenaiel <- NULL

#Test if the intersection is meaningful.
all_ts <- all_ts %>% mutate(matches = (intersect == minline))
all_ts$minline <- NULL
all_ts$intersect <- NULL

#Filter out nonmeaningful intersections (i.e, station names without shared lines).
all_ts <- all_ts %>% filter(matches == TRUE)
all_ts$matches <- NULL

######################################################################################################################
# modify subwaydata dataframe
######################################################################################################################
subwaydata <- as.data.frame(all_ts) %>%select(-AEILMN) # drop aeilmn column
  
# creating dataframe with num_entries, num_exits, and time difference
names(subwaydata) <- tolower(names(subwaydata))
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

################################################################################################################
# filter subwaydata
################################################################################################################

subwaydata <- filter(subwaydata, time.delta <= 12) 

subwaydata <- subwaydata %>% 
  filter(entries.delta < 100000) %>%
  filter(exits.delta < 100000) %>%
  filter(exits.delta > -1) %>%
  filter(entries.delta > -1) %>%
  filter(is_weekday == 1)

# compute hourly entries/exits 
entry_exit_rates <- group_by(subwaydata, station, line_name , entry_exits_period, date) %>%
  summarise(hourly_entries = sum(entries.delta)/4,hourly_exits = sum(exits.delta)/4)



# determine part of day
entry_exit_rates <- subwaydata %>% 
  mutate(is_night = ifelse(time <= "16:00:00" & time >= "04:00:00",  1, 0))


################################################################################################################
# get total entries/exits for each station to compute flow
################################################################################################################
entries_exits <- as.data.frame(subwaydata) %>%
  group_by(station, line_name, station_id) %>%
  summarise(entries = sum(entries.delta), exits = sum(exits.delta))
write.csv(entries_exits, file = "subway_entries_exits.csv")

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

# get entries/exits per day ratios in time period for all stations 
subway_time_ratios <- subwaydata_fil %>%
  group_by(entry_exits_period, is_weekday) %>% 
  filter(is_weekday == 1) %>%
  summarize(entries_per_day=mean(entries_per_timediff), exits_per_day=mean(exits_per_timediff), entries_exits_ratio=entries_per_day/exits_per_day)

# get entries/exits per day ratios in time period for individual stations
subway_time_ratios <- subwaydata_fil %>%
  group_by(entry_exits_period, station,aeilmn,is_weehekday) %>%
  filter(is_weekday == 1) %>%
  summarize(entries_per_hr=mean(entries_per_timediff), exits_per_hr=mean(exits_per_timediff), entries_exits_ratio=entries_per_hr/exits_per_hr, standard_entries = sd(entries_per_timediff), standard_exits = sd(exits_per_timediff))

################################################################################################
# add station type
################################################################################################
class(subwaydata_fil$time)
stations_type <- data.frame()
stations_type <- mutate(subwaydata_fil,is_morning = 0)
stations_type <- stations_type %>%
  mutate(is_night = ifelse(time <= "16:00:00" & time > "04:00:00",  1, 0))

# get mean entries and exits for day and night
stations_type <- stations_type %>% 
  select(station, time, exits_per_timediff, entries_per_timediff, is_night) %>%
  group_by(station, is_night) %>%
  summarize(mean_entries = mean(exits_per_timediff), mean_exits=mean(entries_per_timediff))

mean_day_entries <- as.data.frame(stations_type) %>%
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


#####################################################################################################
# plot 
#####################################################################################################
stations_type$morning_entry_ratio <- stations_type$mean_day_entries/stations_type$mean_day_exits

par(mar=c(2,2,2,2))
png(filename="hist_morning_entry_ratio.png")
hist(stations_type$morning_entry_ratio, breaks=20)
dev.off()

