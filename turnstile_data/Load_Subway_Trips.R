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
# compute entries/exits for time period for each day for all stations
entries_exits_rates <- group_by(subwaydata, station, station_id,line_name , entry_exits_period, date) %>%
  summarise(hourly_entries = sum(entries.delta)/4,hourly_exits = sum(exits.delta)/4) 

write.csv(entries_exits_rates, file = "subway_entries_exits.csv")

entries_exits_avg <- group_by(subwaydata, station, station_id,line_name , entry_exits_period) %>%
  summarise(hourly_entries = sum(entries.delta)/4,hourly_exits = sum(exits.delta)/4) 

write.csv(entries_exits_avg, file = "entries_exits_average.csv")





