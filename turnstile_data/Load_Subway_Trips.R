#################################################################
# Description: Code to load turnstile data into master dataframe
#################################################################
# *Note: C.A is unique to station
library(dplyr)
library(timeDate) # to get day of week function
library(reshape2)
library(stats)

# get data
# note is sorted by SCP (individual turnstyles)
# when dealing with more weeks, should be sorted by SCP
setwd("~/Documents/subway-flow/MergingData")
#n_names = read.table("./MergingData/readyformerge.txt",header=FALSE, sep=",", # current turnstyle dataframe
#                     quote = "", row.names = NULL, strip.white = TRUE, 
#                    stringsAsFactors = FALSE) 
n_names = read.table("readyformerge.txt",header=FALSE, sep=",", # current turnstyle dataframe
                     quote = "", row.names = NULL, strip.white = TRUE, 
                     stringsAsFactors = FALSE) 
names(n_names)[0:5] <- c("Transformed Turnstile Name", "Distance", "stop_name", "Transformed Google Name", "STATION")

n_names <- data.frame(n_names[,c(3,5)])

# l_lines = read.table("./MergingData/s_gtfs_names.csv",header=TRUE, sep=",", #Stop_ids
#                      fill=TRUE,quote = "", row.names = NULL, strip.white = TRUE,
#                      stringsAsFactors = FALSE) 
l_lines = read.table("s_gtfs_names.csv",header=TRUE, sep=",", #Stop_ids
                     fill=TRUE,quote = "", row.names = NULL, strip.white = TRUE,
                     stringsAsFactors = FALSE) 
all_lines <- as.data.frame(sapply(l_lines, function(x) gsub("\"", "", x)))

all_lines <- data.frame(all_lines[,c(2,3,4)])
names(all_lines) <- c("station_id", "line_name", "stop_name")

names_lines <- left_join(n_names, all_lines)
names_lines <- data.frame(names_lines[,c(2,3,4)])
# 
setwd("~/Documents/subway-flow/MergingData/new_ts")
txts <-c()
#txts <- Sys.glob(sprintf('%s/turnstile_1*.txt', "~/Documents/subway-flow/MergingData/new_ts"))
subwaydata <- data.frame()
for (txt in txts) {
  tmp <- read.table(txt, header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)
  subwaydata <- rbind(subwaydata, tmp)
}
setwd("~/Documents/subway-flow/MergingData/new_ts")
subwaydata = read.table("turnstile_150704.txt",header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE) 
subwaydata <- right_join(subwaydata, names_lines, by = c("STATION", "AEILMN" = "line_name"))

# creating dataframe with num_entries, num_exits, and time difference
names(subwaydata) <- tolower(names(subwaydata))
subwaydata$date.time <- with(subwaydata, paste(date, time, sep=' '))
subwaydata$date.time <- with(subwaydata, strptime(date.time, "%m/%d/%Y %H:%M:%S"))
subwaydata$date.time <- with(subwaydata, as.POSIXct((date.time)))
subwaydata <- group_by(subwaydata, c.a, unit, scp, station,aeilmn)

subwaydata <- arrange(subwaydata, date.time) %>%
  mutate(time.delta = as.numeric(date.time-lag(date.time),units="hours"),
         entries.delta = entries - lag(entries),
         exits.delta = exits - lag(exits),
         day_of_week = dayOfWeek(as.timeDate(date)),
         entries_per_timediff = entries.delta / time.delta,
         exits_per_timediff = exits.delta / time.delta,
         is_weekday = ifelse(isWeekday(date.time) == TRUE, 1, 0))

subwaydata <- filter(subwaydata, time.delta>.2) 

# subwaydata <- mutate(subwaydata,
#                      time.delta = order_by(date.time, difftime(date.time, lag(date.time), units = "hours")),
#                      entries.delta = order_by(date.time, entries - lag(entries)),
#                      exits.delta = order_by(date.time, exits - lag(exits)),
#                      day_of_week = dayOfWeek(as.timeDate(date)),
#                      entries_per_timediff = entries.delta / as.numeric(time.delta),
#                      exits_per_timediff = exits.delta / as.numeric(time.delta),
#                      is_weekday = ifelse(isWeekday(date.time) == TRUE, 1, 0))


######################################################################
# filter subwaydata
######################################################################

# removed NAs and rows with 0 < num_entries or num_exits < 6000 
subwaydata_fil <- as.data.frame(subwaydata)
subwaydata_fil <- subwaydata_fil %>% 
  filter(entries.delta < 100000) %>%
  filter(exits.delta < 100000) %>%
  filter(exits.delta > -1) %>%
  filter(entries.delta > -1)

# removing path trains from data
subwaydata_fil<-subwaydata_fil[!subwaydata_fil$division == "PTH", ]


station <- group_by(subwaydata_fil,station,aeilmn) %>%
  summarise(mean_time = entries.delta)

# check ratio of entries and exits per time chunk
subwaydata_fil <- subwaydata_fil %>%
  mutate(entry_exits_period = ifelse(time > "0:00:00" & time <= "04:00:00", "0:4",
                                     ifelse(time > "04:00:00" & time <= "08:00:00", "4:8",
                                            ifelse(time > "08:00:00" & time <= "12:00:00", "8:12",
                                                   ifelse(time > "12:00:00" & time <= "16:00:00", "12:16",
                                                          ifelse(time > "16:00:00" & time <= "20:00:00", "16:20", "20:0"))))))

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

# find missing stations 20:0
# reason not all stations have times after 20:00
a <- filter(subwaydata_fil, entry_exits_period == "20:0") 
missing_stations <- anti_join(subwaydata_fil, a, by="station")
unique(missing_stations$station)

# get entries/exits per day ratios for all stations, used for network flow
subway_time_ratios <- subwaydata_fil %>%
  group_by(is_weekday,station_id, station) %>% 
  filter(is_weekday == 1) %>%
  summarize(entries_per_hr=mean(entries_per_timediff), exits_per_hr=mean(exits_per_timediff),
            entries_exits_ratio=entries_per_hr/exits_per_hr) %>%
  select(station,station_id,entries_per_hr,exits_per_hr)

temp <- as.data.frame(subway_time_ratios) %>% select(station, station_id, entries_per_hr, exits_per_hr)
write.csv(subwaydata_fil, file = "hourly_entries_exits.csv")

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

# percent of rows kept - 99.3%
length(subwaydata_fil$station) / length(subwaydata$station)

#####################################################################################################
# plot 
#####################################################################################################
stations_type$morning_entry_ratio <- stations_type$mean_day_entries/stations_type$mean_day_exits

par(mar=c(2,2,2,2))
png(filename="hist_morning_entry_ratio.png")
hist(stations_type$morning_entry_ratio, breaks=20)
dev.off()

write.csv(subwaydata_fil, file = "turnstyle_df.csv")
write.csv(stations_type, file = "station_classifications.csv")
write.csv(subwaydata, file="master_subwaydata_dataframe.csv")


