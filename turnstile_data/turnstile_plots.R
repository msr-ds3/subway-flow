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

axis.POSIXct(1, at=lexave_subwaydata$date.time, format = "H:%M")
plot(fit.mo, get.data=T, xlim =c(0,24),ylim=c(0,6000))

ggplot(data=means, aes(x=time)) +
  ylim(0,6000) + 
  geom_point(aes(y=exits.delta, colour= 'exits')) +
  geom_point(aes(y=entries.delta, colour='entries'))

str(daily_entries)
head(daily_entries)

length(unique(ts$station))
# search for outliers
head(unique(ts$time)) # time changes =(