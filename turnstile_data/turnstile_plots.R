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
subway_facet <- subway_facet %>%
  mutate(subway_error <- std.error(subway_facet$entries_exits_rate))
subway_error <- std.error(subway_facet$entries_exits_rate)
###################################################################################
  
# total entries per day dataframe
daily_entries <- tapply(subwaydata$entries.delta, subwaydata$date, FUN=sum)

# total exits per day dataframe
daily_exits <- tapply(subwaydata$num_exits,subwaydata$date,FUN=sum)

###################################################################################
# plots
###################################################################################
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
  ylab("No. Entries & Exits per HR")+
  geom_smooth() +
  geom_errorbar(limits, position=dodge, width=0.25) +
  facet_wrap(~ day_of_week) 
  
######################################
# 42 St-Times S
######################################
ts_subwaydata <- subset(subway_facet, station == "42 ST-TIMES SQ")

# plot
ggplot(data=ws_subwaydata, aes(x=time,
                               y=entries_exits_rate,
                               group=type,
                               colour=type)) +
  ggtitle("42-st Times Square") +
  xlab("Time of Day") +
  ylab("No. Entries & Exits per HR")+
  geom_smooth() +
  facet_wrap(~ day_of_week) 

######################################
# Westchest Sq
######################################
ws_subwaydata <- subset(subway_facet, station == "WESTCHESTER SQ")

ggplot(data=ws_subwaydata, aes(x=time,
                      y=entries_exits_rate,
                      group=type,
                      colour=type)) +
  ggtitle("Westchester Square") +
  xlab("Time of Day") +
  ylab("No. Entries & Exits per HR")+
  geom_smooth() +
  facet_wrap(~ day_of_week) 

# Rate of people entering/exitting
mean(subwaydata_fil$entries.delta) / mean(subwaydata_fil$exits.delta) # percent of people

##############################
# total exits vs. total time
##############################
subway_total <- subwaydata_fil

entries <- subwaydata_total %>%
  select(station, linename,date.time, time, day_of_week,entries.delta, entries_per_timediff) %>%
  mutate(type = "entry")
entries <- dplyr::rename(entries, entries_exits_rate = entries_per_timediff)
entries <- dplyr::rename(entries, entries_exits = entries.delta)

# exits dataframee
exits <- subwaydata_total %>%
  select(station, linename,date.time, time, day_of_week, exits.delta, exits_per_timediff) %>%
  mutate(type = "exit")
exits <- dplyr::rename(exits, entries_exits_rate = exits_per_timediff) 
exits <- dplyr::rename(exits, entries_exits = exits.delta)

# bind dataframes
subwaydata_total <- data.frame()
subwaydata_total <- rbind(entries,exits)
subwaydata_total <- as.data.frame(subwaydata_total)
subwaydata_total$entries_exits_rate[is.infinite(subwaydata_total$entries_exits_rate)] <- 0

# plot it
ggplot(data=subwaydata_total, aes(x=time,
                               y=entries_exits_rate,
                               group=type,
                               colour=type)) +
  ggtitle("Total Entries and Exits vs. Time of Day") +
  xlab("Time of Day") +
  ylab("No. Entries & Exits per HR")+
  geom_smooth() +
  facet_wrap(~ day_of_week) 

#########################################################
# plot means and variance of total exits and enries
#########################################################
subway_stats <- summarySE(subwaydata_fil, measurevar="entries_exits", groupvars = )

# get patterns of stations ex. commuter station, residential station, commercial station
# might have rule 
