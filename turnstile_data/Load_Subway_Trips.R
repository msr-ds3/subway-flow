#################################################################
# Description: Code to load turnstile data into master dataframe
#################################################################
# *Note: C.A is unique to station
library(dplyr)
library(timeDate) # to get day of week function

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

subwaydata <- read.delim('turnstile_150530.txt', header=TRUE, sep=',')
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
               entries_per_timediff = entries.delta / as.integer(time.delta),
               exits_per_timediff = exits.delta / as.integer(time.delta)) 

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

# ratios, time of day, variation 

# create rate have denominator be # of hours 

write.csv(ts, file = "turnstyle_df.csv")

