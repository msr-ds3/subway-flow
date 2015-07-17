############################################################
# Different Entries
############################################################
library(dplyr)
# get data
# note is sorted by SCP (individual turnstyles)
# when dealing with more weeks, should be sorted by SCP
currentTsData = read.table("turnstile_150704.txt",header=TRUE, sep=",", # current turnstyle dataframe
                           fill=TRUE,quote = "", row.names = NULL, 
                           stringsAsFactors = FALSE) 

num_entries <- c() # intialize empty vector
num_exits <- c() # initialize empty vector
error_dates <- c() # keep track of dates where turnstyle acting up
error_stations <- c() # keep track of station where turnstyle acting up
pre_entry <- currentTsData$ENTRIES[1] # holds previous entry
pre_exit <- currentTsData$EXITS[1] # holds previous exits
scp <- as.character('0')
j <- 1

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
  j <- j + 1
}

j <- 1 # reset j 

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
  j <- j + 1
}

# append entries column
currentTsData <- cbind(currentTsData, num_entries)

# append exits column
currentTsData <- cbind(currentTsData, num_exits)

currentTsData <-dfarr %>%
  group_by(as.factor(SCP)) %>%
  mutate(num_enteries = lag(ENTRIES -lag(ENTRIES,default=ENTRIES[1])),
  num_exits = lag(EXITS -lag(EXITS,default=EXITS[1]))) 

# percent of negative values
filter(currentTsData, num_entries < 0) %>% nrow()
select(currentTsData, num_entries) %>% nrow()
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


write.csv(ts, file = "turnstyle_df.csv")

