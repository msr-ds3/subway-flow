########################################################################################################
# Plots
########################################################################################################
library(ggplot2)
library(reshape)
library(scales)
library(plotrix)
library(locfit)
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
ggplot(data=subwaydata, aes(x=time,y=entries.delta))+
  facet_wrap(~ day_of_week)+
  geom_line()

# total entries per day of week
ggplot(data=subwaydata, aes(x=day_of_week,y=entries.delta))+
  geom_line()

# total exits per day of week
ggplot(data=subwaydata, aes(x=day_of_week,y=exits.delta))+
  geom_line()

# total entries per day dataframe
daily_entries <- tapply(subwaydata$entries.delta, subwaydata$date, FUN=sum)

# total exits per day dataframe
daily_exits <- tapply(subwaydata$num_exits,subwaydata$date,FUN=sum)

# Lexington Ave
lexave_subwaydata <- filter(subwaydata_fil, "LEXINGTON AVE" %in% station) 
# find mean No. Entries vs. time
means <- lexave_subwaydata %>%
  group_by(time) %>%
  mutate(mean_entries = mean(entries.delta))

lexave_fit <- locfit(entries.delta~date.time,
                     data=lexave_subwaydata,
                     alpha=0.5)
plot(, lexave_subwaydata$entries.delta)
lexave_fit
par("mar"=c(1,1,1,1))
lines(lexave_fit)
plot(lexave_fit, ylim=c(0,6000))

# aggregate
mean_time_entries <- aggregate( formula=entries.delta~time+day_of_week, data=lexave_subwaydata, FUN=mean)
mean_time_exits <- aggregate( formula=exits.delta~time+day_of_week, data=lexave_subwaydata, FUN=mean)

# Entries vs. Time
ggplot(data=mean_time_entries, aes(x=time, y = entries.delta)) +
  facet_wrap(~day_of_week) +
  ylim(0,500) + 
  geom_point()

# Exits vs. Time
ggplot(data=mean_time_exits, aes(x=time, y = exits.delta)) +
  facet_wrap(~day_of_week) +
  ylim(0,500) + 
  geom_point()

# 42 St-Times Sq
ts_subwaydata <- filter(subwaydata_fil, "42 ST-TIMES SQ" %in% station)

# aggregate
# create rate have denominator be # of hours 
mean_time_entries <- aggregate( formula=entries.delta~time+day_of_week, data=ts_subwaydata, FUN=mean)
mean_time_exits <- aggregate( formula=exits.delta~time+day_of_week, data=ts_subwaydata, FUN=mean)

# Entries vs. Time
ggplot(data=mean_time_entries, aes(x=time, y = entries.delta))+
  facet_wrap(~day_of_week) +
  ylim(0,500) + 
  geom_point()

# Exits vs. Time
ggplot(data=mean_time_exits, aes(x=time, y = exits.delta, group = 1)) +
  facet_wrap(~day_of_week) +
  ylim(0,500) + 
  geom_smooth()
