############################################################
# Different Entries
############################################################
# get data
# note is sorted by SCP (individual turnstyles)
# when dealing with more weeks, should be sorted by SCP
currentTsData = read.table("turnstile_150711.txt",header=TRUE, sep=",", # current turnstyle dataframe
                           fill=TRUE,quote = "", row.names = NULL, 
                           stringsAsFactors = FALSE) 

num_entries <- c() # intialize empty vector
num_exits <- c() # initialize empty vector
error_dates <- c() # keep track of dates where turnstyle acting up
error_stations <- c() # keep track of station where turnstyle acting up
pre_entry <- currentTsData$ENTRIES[1] # holds previous entry
pre_exit <- currentTsData$EXITS[1] # holds previous exits
j = 1

# find number of entries 
for(i in currentTsData$ENTRIES){
  if(scp == currentTsData$SCP[j]){ # check if scp has changed
    num_entries <- c(num_entries,i-pre_entry)
    pre_entry <- i
  }
  else{ # if scp has changed
    pre_entry <- i # set to next entry and cancel
    num_entries <- c(num_entries, 0) # set new scp num_entries to 0
  }
  
#  if(currentTsData$ENTRIES[j]==currentTsData$ENTRIES[j+1]==currentTsData$ENTRIES[j+2]){ # if within 12 hours there
#    error_dates <- c(error_dates, currentTsData$DATE[j])                                # are no entries indicate
#    error_stations <- c(error_stations, currentTsData$STATION[j])                       # there is an error
#  }
  
  scp <- currentTsData$SCP[j]
  j = j + 1
}

j = 1 # reset j 

# find number of exits 
for(i in currentTsData$EXITS){
  if(scp == currentTsData$SCP[j]){ # check if scp has changed
    num_exits <- c(num_exits,i-pre_exits)
    pre_exits <- i
  }
  else{ # if scp has changed
    pre_exits <- i # set to next entry and cancel
    num_exits <- c(num_exits, 0) # set new scp num_entries to 0
  }
  scp <- currentTsData$SCP[j]
  j = j + 1
}

# append entries column
currentTsData <- cbind(currentTsData, num_entries)

# append exits column
currentTsData <- cbind(currentTsData, num_exits)

# percent of negative values
filter(currentTsData, num_exits < 0) %>% nrow()
select(currentTsData, num_exits) %>% nrow()
923/191033 # = 0.004831626

# play with data without negative values
ts <- currentTsData
ts <- filter(currentTsData, num_entries < 10000 & num_entries >= 0 & num_exits < 100000 & num_exits >= 0) 

# convert date column 
library(timeDate) # to get day of week
dates <- as.timeDate(ts$DATE)
day_of_week <- dayOfWeek(dates)

# convert exits to integer
num_exits <- as.integer(ts$num_exits)

# create newly formatted dataframe
ts <- select(ts, C.A, SCP, STATION, LINENAME, TIME, num_entries)
ts <- cbind(ts, num_exits, dates, day_of_week)
names(ts) <- c('c.a','scp','station','line_name','time','num_entries','num_exits','dates','day_of_week')
########################################################################################################
# Plots
########################################################################################################
library(ggplot2)
# plot no. entries vs. date
qplot(day_of_week, num_entries, data=ts,
      geom_histogram(),
      color = station,
      main="No. Entries vs. Dates",
      xlab="Dates", ylab="No. Entries")

# plot no. exits vs. date
qplot(day_of_week, num_exits, data=ts,
      geom_histogram(),
      color = station,
      main="No. Exits vs. Dates",
      xlab="Dates", ylab="No. Exits")

# seperate graphs by days of the week
# plot no. exits vs. date


# No. entries vs. time
qplot(data = ts, x = time, y = num_entries, color = as.factor(day_of_week))

qplot(data = ts, x = time, y = num_exits, color = as.factor(day_of_week))

qplot(data = ts, x = day_of_week, y = num_entries, color = as.factor(station))

qplot(ts, num_entries, )
head(ts)

# No. Entries vs. Time for each day of week
ggplot(data=ts, aes(x=time,y=num_entries))+
  facet_wrap(~ day_of_week)+
  geom_line()

# total entries per day of week
ggplot(data=ts, aes(x=day_of_week,y=num_entries))+
  geom_line()

# total exits per day of week
ggplot(data=ts, aes(x=day_of_week,y=num_exits))+
  geom_line()

# total entries per day dataframe
daily_entries <- tapply(ts$num_entries, ts$date, FUN=sum)

# total exits per day dataframe
daily_exits <- tapply(ts$num_exits,ts$date,FUN=sum)

str(daily_entries)
head(daily_entries)

length(unique(ts$station))
# search for outliers
head(unique(ts$time)) # time changes =(

# work for today: Riva/Eiman, getting the graph up and running. Shannon/Steven, 
# full data cleaning/input (clean code to the Git) and graphs for basic data analysis 
# (inflow/outflow by day of week, inflow/outflow by hour of day, etc., histograms of flow 
# by station to check for outliers) 
# load library ggplot

write.csv(ts, file = "turnstyle_df.csv")

