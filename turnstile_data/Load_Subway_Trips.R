#################################################################
# Description: Code to load turnstile data into master dataframe
#################################################################
# *Note: C.A is unique to station
library(dplyr)
library(timeDate) # to get day of week function
library(data.table)

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
# subwaydata <- read.delim('turnstile_150530.txt', header=TRUE, sep=',')
names(subwaydata) <- tolower(names(subwaydata))
subwaydata$date.time <- with(subwaydata, paste(date, time, sep=' '))
subwaydata$date.time <- with(subwaydata, strptime(date.time, "%m/%d/%Y %H:%M:%S"))
subwaydata$date.time <- with(subwaydata, as.POSIXct((date.time)))
subwaydata <- group_by(subwaydata, c.a, unit, scp, station)
subwaydata <- mutate(subwaydata,
               time.delta = order_by(date.time, date.time - lag(date.time)),
               entries.delta = order_by(date.time, entries - lag(entries)),
               exits.delta = order_by(date.time, exits - lag(exits)),
               day_of_week = dayOfWeek(as.timeDate(date))) 

t <- as.data.table(subwaydata)
setkeyv(t,c("unit","scp","date.time"))
t <- data.frame(t[!duplicated(t),],with = FALSE)

# filter subwaydata
# removed NAs and rows with 0 < num_entries or num_exits < 6000 
subwaydata_fil <- subwaydata
subwaydata_fil <- subwaydata_fil %>% 
  filter(entries.delta < 6000) %>%
  filter(exits.delta < 6000) %>%
  filter(exits.delta > -1) %>%
  filter(entries.delta > -1)

# percent of rows kept - 99.3%
length(subwaydata_fil$station) / length(subwaydata$station) 

time_pos <- strftime(strptime(subwaydata$time, format="%H:%M:%S"),"%H") 
time_pos <- as.POSIXlt(subway)
# ratios, time of day, variation 

write.csv(ts, file = "turnstyle_df.csv")


# Getting num_exits and num_entries via loops, may be buggy
# 
# # #dates <- as.timeDate(subwaydata$DATE) # convert st
# #dates_pos <- as.POSIXct(strptime(subwaydata$DATE, "%m/%d/%Y")) # convert str date to posixtct date
# #time_pos <- as.POSIXct(strptime(subwaydata$TIME, "%H:%M:%S")) # convert str time to posixtct time
# time_date <- paste(subwaydata$DATE, subwaydata$TIME)
# time_date <- as.POSIXct(strptime(time_date, "%m/%d/%Y %H:%M:%S"))
# day_of_week <- dayOfWeek(as.timeDate(subwaydata$DATE))
# subwaydata <- cbind(subwaydata, time_date) 
# subwaydata <- cbind(subwaydata, day_of_week)
# 
# # creating dataframe with num_entries, num_exits, and time difference
# subwaydata <-subwaydata %>% 
#   group_by(C.A,SCP,DATE) %>% 
#   mutate(num_entries = ENTRIES -lag(ENTRIES),
#   num_exits = EXITS -lag(EXITS),
#   time_diff = time_date - lag(time_date))
# 
# num_entries <- c() # intialize empty vector
# num_exits <- c() # initialize empty vector
# error_dates <- c() # keep track of dates where turnstyle acting up
# error_stations <- c() # keep track of station where turnstyle acting up
# pre_entry <- currentTsData$ENTRIES[1] # holds previous entry
# pre_exit <- currentTsData$EXITS[1] # holds previous exits
# scp <- as.character('0')
# j <- 1
# 
# # find number of entries 
# for(i in currentTsData$ENTRIES){
#   if(scp == currentTsData$SCP[j]){ # check if scp has changed
#     num_entries <- c(num_entries,i-pre_entry)
#     pre_entry <- i
#   }
#   else{ # if scp has changed
#     pre_entry <- i # set to next entry and cancel
#     num_entries <- c(num_entries, -1) # set new scp num_entries to 0
#   }
#   
# #  if(currentTsData$ENTRIES[j]==currentTsData$ENTRIES[j+1]==currentTsData$ENTRIES[j+2]){ # if within 12 hours there
# #    error_dates <- c(error_dates, currentTsData$DATE[j])                                # are no entries indicate
# #    error_stations <- c(error_stations, currentTsData$STATION[j])                       # there is an error
# #  }
#   
#   scp <- currentTsData$SCP[j]
#   j <- j + 1
# }
# 
# j <- 1 # reset j 
# 
# # find number of exits 
# for(i in currentTsData$EXITS){
#   if(scp == currentTsData$SCP[j]){ # check if scp has changed
#     num_exits <- c(num_exits,i-pre_exits)
#     pre_exits <- i
#   }
#   else{ # if scp has changed
#     pre_exits <- i # set to next entry and cancel
#     num_exits <- c(num_exits, -1) # set new scp num_entries to 0
#   }
#   scp <- currentTsData$SCP[j]
#   j <- j + 1
# }
# 
# # append entries column
# currentTsData <- cbind(currentTsData, num_entries)
# 
# # append exits column
# currentTsData <- cbind(currentTsData, num_exits)


