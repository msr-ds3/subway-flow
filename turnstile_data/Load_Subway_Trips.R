#################################################################
# Description: Code to load turnstile data into master dataframe
#################################################################
# *Note: C.A is unique to station
library(dplyr)
library(timeDate) # to get day of week function
library(reshape)



namespace dplyr {
  data.attr( "vars") = vars ;
  data.attr( "drop" ) = true ;
} else {
  -                data.attr( "class" ) = classes_grouped()  ;
  +                data.attr( "class" ) = classes_not_grouped()  ;
  data.attr( "drop" ) = true ;
}
}

# get data
# note is sorted by SCP (individual turnstyles)
# when dealing with more weeks, should be sorted by SCP
data_dir <- '.'
# load each month of the trip data into one big data frame
txts <- Sys.glob(sprintf('%s/turnstile_1*.txt', data_dir))
subwaydata <- data.frame()
for (txt in txts) {
  tmp <- read.table(txt, header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)
  subwaydata <- rbind(subwaydata, tmp)
}

# creating dataframe with num_entries, num_exits, and time difference
names(subwaydata) <- tolower(names(subwaydata))
subwaydata$date.time <- with(subwaydata, paste(date, time, sep=' '))
subwaydata$date.time <- with(subwaydata, strptime(date.time, "%m/%d/%Y %H:%M:%S"))
subwaydata$date.time <- with(subwaydata, as.POSIXct((date.time)))
subwaydata <- group_by(subwaydata, c.a, unit, scp, station)
subwaydata <- mutate(subwaydata,
               time.delta = order_by(date.time, difftime(date.time, lag(date.time), units = "hours")),
               entries.delta = order_by(date.time, entries - lag(entries)),
               exits.delta = order_by(date.time, exits - lag(exits)),
               day_of_week = dayOfWeek(as.timeDate(date)),
               entries_per_timediff = entries.delta / as.numeric(time.delta),
               exits_per_timediff = exits.delta / as.numeric(time.delta)) 

######################################################################
# filter subwaydata
######################################################################

# removed NAs and rows with 0 < num_entries or num_exits < 6000 
subwaydata_fil <- as.data.frame(subwaydata)
subwaydata_fil <- subwaydata_fil %>% 
  filter(entries.delta < 6000) %>%
  filter(exits.delta < 6000) %>%
  filter(exits.delta > -1) %>%
  filter(entries.delta > -1)


# removing path trains from data
subwaydata_fil<-subwaydata_fil[!subwaydata_fil$division == "PTH", ]

# new column morning night, group by morning and night and look at morning vs. night, look at aggregates (shannons)
# add station type
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
stations_type$morning_entry_ratio <- stations_type$mean_day_entries/stations_type$mean_day_exits
stations_type <- statio

par(mar=c(2,2,2,2))
hist(stations_type$morning_entry_ratio, breaks=50)

write.csv(subwaydata_fil, file = "turnstyle_df.csv")
write.csv(stations_type, file = "station_classifications.csv")

