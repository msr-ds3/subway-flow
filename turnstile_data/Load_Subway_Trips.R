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
#My Merge Table is read in.
n_names = read.table("./MergingData/readyformerge.txt",header=FALSE, sep=",", # current turnstyle dataframe
                     quote = "", row.names = NULL, strip.white = TRUE, 
                     stringsAsFactors = FALSE) 

#Formatting stuff
names(n_names)[0:5] <- c("Transformed Turnstile Name", "Distance", "stop_name", "Transformed Google Name", "STATION")
n_names <- data.frame(n_names[,c(3,5)])

#Eiman's Station names are read in:
l_lines = read.table("./NewGoogleLineNames.csv",header=TRUE, sep=",", #Stop_ids
                     fill=TRUE,quote = "", row.names = NULL, strip.white = TRUE,
                     stringsAsFactors = FALSE) 

#MOAR Formatting!
all_lines <- as.data.frame(sapply(l_lines, function(x) gsub("\"", "", x)))
all_lines <- data.frame(all_lines[,c(2,3,4)])
names(all_lines) <- c("station_id", "line_name", "stop_name")

#Eiman's stuff is combined with the nametable
names_lines <- inner_join(n_names, all_lines)
names_lines <- data.frame(names_lines[,c(2,3,4)])

#Now we just have the station, E's ID, and the linenames.

#Loading in all TS Files.
data_dir <- "./MergingData/new_ts/"
txts <- Sys.glob(sprintf('%s/turnstile_1*.txt', data_dir))
ts_data <- data.frame()
txts <- txts[12:13]
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

<<<<<<< HEAD

################################################################################################################
=======
subwaydata <- subwaydata %>% 
  filter(entries.delta < 100000) %>%
  filter(exits.delta < 100000) %>%
  filter(exits.delta > -1) %>%
  filter(entries.delta > -1) %>%
  filter(is_weekday == 1)


hourly_entries_exits<-group_by(subwaydata, station, aeilmn , entry_exits_period, date) %>%
  summarise(hourly_entries = sum(entries.delta)/4,hourly_exits = sum(exits.delta)/4)


######################################################################
>>>>>>> 91fc11d3daf12f86b6fed9762a5e277fa313f66b
# filter subwaydata
################################################################################################################

subwaydata <- filter(subwaydata, time.delta <= 12) 

subwaydata <- subwaydata %>% 
  filter(entries.delta < 100000) %>%
  filter(exits.delta < 100000) %>%
  filter(exits.delta > -1) %>%
<<<<<<< HEAD
  filter(entries.delta > -1) 

################################################################################################################
# hourly entries/exits stats
################################################################################################################
# compute entries/exits for time period for each day for all stations
entries_exits_rates <- group_by(subwaydata, station, station_id,line_name , entry_exits_period, date) %>%
  summarise(hourly_entries = sum(entries.delta)/4,hourly_exits = sum(exits.delta)/4) 

write.csv(entries_exits_rates, file = "subway_entries_exits.csv")

entries_exits_avg <- group_by(entries_exits_rates, station, station_id,line_name , entry_exits_period) %>%
  summarise(mean_hourly_entries = mean(hourly_entries),mean_hourly_exits = mean(hourly_exits)) 

write.csv(entries_exits_avg, file = "entries_exits_average.csv")



=======
  filter(entries.delta > -1)



station<- select(subwaydata ,day_of_week, exits.delta, entries.delta) %>% 
  group_by(day_of_week) %>%
  summarise(total_entries=sum(entries.delta),total_exits=sum(exits.delta))


station<- gather(station, exit_or_entry, total, total_entries:total_exits)

sterling_station<- filter(subwaydata, station == "STERLING ST")
sterling_station<- select(sterling_station ,day_of_week, exits.delta, entries.delta) %>% 
  group_by(day_of_week) %>%
  summarise(total_entries=sum(entries.delta),total_exits=sum(exits.delta))

sterling_station<- gather(sterling_station, exit_or_entry, total, total_entries:total_exits)

##PLot


ggplot(data=sterling_station, aes(x=day_of_week, y=total, fill=exit_or_entry)) + 
  geom_bar(colour="black", stat="identity",
           position=position_dodge(),
           size=.3) +                        # Thinner lines
  scale_fill_hue(name="Entry or Exit") +      # Set legend title
  xlab("Day of week") + ylab("Count") + # Set axis labels
  ggtitle("Sterling St") +     # Set title
  theme_bw()

####42nd street

lexington_station<- filter(subwaydata, station == "LEXINGTON AVE")
lexington_station<- select(lexington_station ,day_of_week, exits.delta, entries.delta) %>% 
  group_by(day_of_week) %>%
  summarise(total_entries=sum(entries.delta),total_exits=sum(exits.delta))
lexington_station<- gather(lexington_station, exit_or_entry, total, total_entries:total_exits)

##PLot


ggplot(data=lexington_station, aes(x=day_of_week, y=total, fill=exit_or_entry)) + 
  geom_bar(colour="black", stat="identity",
           position=position_dodge(),
           size=.3) +                        # Thinner lines
  scale_fill_hue(name="Entry or Exit") +      # Set legend title
  xlab("Day of week") + ylab("Count") + # Set axis labels
  ggtitle("LEXINGTON AVE") +     # Set title
  theme_bw()






















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
>>>>>>> 91fc11d3daf12f86b6fed9762a5e277fa313f66b


