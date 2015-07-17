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