########################################################################################################
# Plots
# *Note: facet wrapping dataframe is only used where facet wrapping or filling occurs
########################################################################################################
library(ggplot2)
library(reshape)
library(scales)
library(plotrix)

#########################################
# create new dataframe for facet graphing
#########################################
# entries dataframe
entries <- subwaydata_fil %>%
  select(station, linename,date.time, time, day_of_week,entries.delta, entries_per_timediff) %>%
  mutate(type = "entry")
entries <- dplyr::rename(entries, entries_exits_rate = entries_per_timediff)
entries <- dplyr::rename(entries, entries_exits = entries.delta)

# exits dataframee
exits <- subwaydata_fil %>%
  select(station, linename,date.time, time, day_of_week, exits.delta, exits_per_timediff) %>%
  mutate(type = "exit")
exits <- dplyr::rename(exits, entries_exits_rate = exits_per_timediff) 
exits <- dplyr::rename(exits, entries_exits = exits.delta)

# bind dataframes
subway_facet <- data.frame()
subway_facet <- rbind(entries,exits)
subway_facet <- as.data.frame(subway_facet)
subway_facet$entries_exits_rate[is.infinite(subway_facet$entries_exits_rate)] <- 0
##########################################
  
# total entries per day dataframe
daily_entries <- tapply(subwaydata$entries.delta, subwaydata$date, FUN=sum)

# total exits per day dataframe
daily_exits <- tapply(subwaydata$num_exits,subwaydata$date,FUN=sum)

##############################################
# plots
##############################################
##############################################
# Lexington Ave
##############################################
lexave_subwaydata <- subset(subwaydata_fil, station == "LEXINGTON AVE") 

# plot
ggplot(data=lexave_subwaydata, aes(x=time,
                               y=entries_exits_rate,
                               group=type,
                               colour=type)) +
  ggtitle("Lexington Ave - FNQR456 ") +
  xlab("Time of Day") +
  ylab("No. Entries & Exits")+
  geom_smooth() +
  facet_wrap(~ day_of_week) 

######################################
# 42 St-Times Sq
######################################
ts_subwaydata <- subset(subway_facet, station == "42 ST-TIMES SQ")

# plot
ggplot(data=ts_subwaydata, aes(x=time,
                               y=entries_exits_rate,
                               group=type,
                               colour=type)) +
  ggtitle("42-st Times Square") +
  xlab("Time of Day") +
  ylab("No. Entries & Exits")+
  geom_smooth() +
  facet_wrap(~ day_of_week) 

######################################
# Westchest Sq
######################################
ws_subwaydata <- subset(subway_facet, station == "WESTCHESTER SQ")

# Mean Entry and Exit Rates vs. Time
ggplot(data=ws_subwaydata, aes(x=time,
                      y=entries_exits_rate,
                      group=type,
                      colour=type)) +
  ggtitle("Westchester Square") +
  xlab("Time of Day") +
  ylab("No. Entries & Exits")+
  geom_smooth() +
  facet_wrap(~ day_of_week) 

# Rate of people entering/exitting
mean(subwaydata_fil$entries.delta) / mean(subwaydata_fil$exits.delta) # percent of people

##############################
# total exits vs. total time
##############################
t <- subwaydata_fil
entries <- subwaydata_fil %>%
  select(station, linename,date.time, time, day_of_week,entries.delta, entries_per_timediff) %>%
  mutate(type = "entry")
entries <- dplyr::rename(entries, entries_exits_rate = entries_per_timediff)
entries <- dplyr::rename(entries, entries_exits = entries.delta)

# exits dataframee
exits <- subwaydata_fil %>%
  select(station, linename,date.time, time, day_of_week, exits.delta, exits_per_timediff) %>%
  mutate(type = "exit")
exits <- dplyr::rename(exits, entries_exits_rate = exits_per_timediff) 
exits <- dplyr::rename(exits, entries_exits = exits.delta)

# bind dataframes
subwaydata_fil <- data.frame()
subwaydata_fil <- rbind(entries,exits)
subwaydata_fil <- as.data.frame(subwaydata_fil)
subwaydata_fil$entries_exits_rate[is.infinite(subwaydata_fil$entries_exits_rate)] <- 0

# plot it
ggplot(data=subwaydata_fil, aes(x=time,
                               y=entries_exits_rate,
                               group=type,
                               colour=type)) +
  ggtitle("Total Entries and Exits vs. Time of Day") +
  xlab("Time of Day") +
  ylab("No. Entries & Exits")+
  geom_smooth() +
  facet_wrap(~ day_of_week) 

# get patterns of stations ex. commuter station, residential station, commercial station
# might have rule 
