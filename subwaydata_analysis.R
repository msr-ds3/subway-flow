# get entries/exits for each weekday ratios for all stations 
subway_time_ratios <- entry_exit_rates %>%
  group_by(station, day_of_week) %>% 
  summarize(mean_hourly_entries=mean(hourly_entries), mean_hourly_exits=mean(hourly_exits), entry_exit_ratio=mean_hourly_entries/mean_hourly_exits)

# get entries/exits for each time period for all stations
subway_time_ratios <- entry_exit_rates %>%
  group_by(entry_exits_period, station, station_id) %>% 
  summarize(mean_hourly_entries=mean(hourly_entries), mean_hourly_exits=mean(hourly_exits))

# get entries/exits per day ratios in time period for individual stations
subway_time_ratios <- entry_exit_rates %>%
  group_by(station, line_name,station_id, day_of_week) %>% 
  summarize(mean_hourly_entries=mean(hourly_entries), mean_hourly_exits=mean(hourly_exits))

subway_time_ratios <- gather(as.data.frame(subway_time_ratios), exit_or_entry, total, mean_hourly_entries:mean_hourly_exits)

subway_time_ratios <- subset(subway_time_ratios, "42 ST-TIMES SQ" == station)
ggplot(data = subway_time_ratios, aes(x = day_of_week, y = value, fill = variable)) + # check variance for each day
  geom_boxplot()

# get entries/exits per time period for individual stations
subway_time_ratios <- entry_exit_rates %>%
  group_by(station, line_name,station_id, entry_exits_period) %>% 
  summarize(mean_hourly_entries=mean(hourly_entries), mean_hourly_exits=mean(hourly_exits), entry_exit_ratio=mean_hourly_entries/mean_hourly_exits)

# plot variance in daily entries and exits
subway_time_ratios <- subset(subwaydata, "42 ST-TIMES SQ" == station)
subway_time_ratios <- gather(as.data.frame(subway_time_ratios), exit_or_entry, total, entries.delta:exits.delta)

ggplot(data = subway_time_ratios, aes(x = day_of_week, fill = variable)) + # check variance for each day
  geom_boxplot(aes(y=value))

subway_time_ratios

# need to fix
# boxplot of hourly_entries for all stations 
ggplot(data=subway_time_ratios, aes(x=station,
                                    y=entries_per_hr)) +
  ggtitle("Entries/hr for all stations") +
  xlab("station") +
  ylab("No. Entries & Exits per HR")+
  geom_boxplot() 

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

################################################################################################################
# get total entries/exits for each station to compute flow
################################################################################################################
entries_exits <- as.data.frame(subwaydata) %>%
  group_by(station_id, day_of_week, entry_exits_period, day_of_week) %>%
  summarise(entries = sum(entries.delta), exits = sum(exits.delta))
write.csv(entries_exits, file = "subway_entries_exits.csv")

#####################################################################################################
# plot 
#####################################################################################################
stations_type$morning_entry_ratio <- stations_type$mean_day_entries/stations_type$mean_day_exits

temp <- subset(entry_exit_rates, "FULTON ST" == station & line_name == "2345ACJZ")
ggplot(data=temp, aes(x = date, y = hourly_entries)) +
  facet_wrap(~entry_exits_period) +
  geom_point()

lexington_station<- filter(subwaydata, station == "LEXINGTON AVE")
lexington_station<- select(lexington_station ,day_of_week, exits.delta, entries.delta) %>%
  group_by(day_of_week) %>%
  summarise(total_entries=sum(entries.delta),total_exits=sum(exits.delta))
lexington_station<- gather(as.data.frame(lexington_station), exit_or_entry, total, total_entries:total_exits)

##PLot
ggplot(data=lexington_station, aes(x=day_of_week, y=value, fill=variable)) +
  geom_bar(colour="black", stat="identity",
           position=position_dodge(),
           size=.3) +                        # Thinner lines
  scale_fill_hue(name="Entry or Exit") +      # Set legend title
  xlab("Day of week") + ylab("Count") + # Set axis labels
  ggtitle("LEXINGTON AVE") +     # Set title
  theme_bw() 

par(mar=c(2,2,2,2))
png(filename="hist_morning_entry_ratio.png")
hist(stations_type$morning_entry_ratio, breaks=20)
dev.off()