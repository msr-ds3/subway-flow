#Setworking Directory
setwd("~/Documents/subway-flow/turnstile_data")


#Loading required libraries
library(dplyr)
library(ggplot2)
library(scales)
library(timeDate) # to get day of week
library(tidyr)



########################################
# load and clean turnstile data
########################################
#week of 6/27/15 to 7/3/15
mydata = read.table("turnstile_150704.txt",header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)

#week of 7/4/15 to 7/8/15
mydata2 = read.table("turnstile_150711.txt",header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)

# set the data directory
data_dir <- '.'

# load each month of the trip data into one big data frame
txts <- Sys.glob(sprintf('%s/turnstile*.txt', data_dir))
data <- data.frame()
for (txt in txts) {
  tmp <- read.table(txt, header=TRUE, sep=',',fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)
  data <- rbind(data, tmp)
}




#Creating dataframe with num_entries and num_exits
#data <- read.delim('turnstile_150704.txt', header=TRUE, sep=',')
names(data) <- tolower(names(data))
data$date.time <- with(data, paste(date, time, sep=' '))
data$date.time <- with(data, strptime(date.time, "%m/%d/%Y %H:%M:%S"))
data$date.time <- with(data, as.POSIXct((date.time)))

data <- group_by(data, c.a, unit, scp, station)
data <- mutate(data,
               time.delta = order_by(date.time, date.time - lag(date.time)),
               entries.delta = order_by(date.time, entries - lag(entries)),
               exits.delta = order_by(date.time, exits - lag(exits)),
               day_of_week = dayOfWeek(as.timeDate(date)) 
)
##removing path trains from data
data<-data[!data$division == "PTH", ]


#Lexave Station

lexave_station<- filter(data, station == "LEXINGTON AVE", entries.delta > 0 , exits.delta > 0)
lexave_station<- select(lexave_station,day_of_week, exits.delta, entries.delta) %>% 
  group_by(day_of_week) %>%
  summarise(total_entries=sum(entries.delta),total_exits=sum(exits.delta))

#sort by day of week here


lexave_station<- gather(lexave_station, exit_or_entry, total, total_entries:total_exits)



##PLot

ggplot(data=lexave_station, aes(x=day_of_week, y=total, fill=exit_or_entry)) + 
  geom_bar(colour="black", stat="identity",
           position=position_dodge(),
           size=.3) +                        # Thinner lines
  scale_fill_hue(name="Entry or Exit") +      # Set legend title
  xlab("Day of week") + ylab("Count") + # Set axis labels
  ggtitle("Entries vs Exits") +     # Set title
  theme_bw()



#trying another station

sterling_station<- filter(data, station == "STERLING ST", entries.delta > 0 , exits.delta > 0)
sterling_station<- select(sterling_station,day_of_week, exits.delta, entries.delta) %>% 
  group_by(day_of_week) %>%
  summarise(total_entries=sum(entries.delta),total_exits=sum(exits.delta))

#sort by day of week here

#lexave_station<-arrange(lexave_station,day_of_week)

sterling_station<- gather(sterling_station, exit_or_entry, total, total_entries:total_exits)



##PLot

ggplot(data=sterling_station, aes(x=day_of_week, y=total, fill=exit_or_entry)) + 
  geom_bar(colour="black", stat="identity",
           position=position_dodge(),
           size=.3) +                        # Thinner lines
  scale_fill_hue(name="Entry or Exit") +      # Set legend title
  xlab("Day of week") + ylab("Count") + # Set axis labels
  ggtitle("Sterling St") +     # Set title
  theme_bw()



#trying whole network

station<- filter(data, entries.delta > 0 & entries.delta <6000 , exits.delta > 0 & exits.delta <6000)
station<- select(station,day_of_week, exits.delta, entries.delta) %>% 
  group_by(day_of_week) %>%
  summarise(total_entries=sum(entries.delta),total_exits=sum(exits.delta))

#sort by day of week here

#lexave_station<-arrange(lexave_station,day_of_week)

station<- gather(station, exit_or_entry, total, total_entries:total_exits)



##PLot

ggplot(data=station, aes(x=day_of_week, y=total/length(unique(data$date)), fill=exit_or_entry)) + 
  geom_bar(colour="black", stat="identity",
           position=position_dodge(),
           size=.3) +                        # Thinner lines
  scale_fill_hue(name="Entry or Exit") +      # Set legend title
  xlab("Day of week") + ylab("Count") + # Set axis labels
  ggtitle("Lexington Station") +     # Set title
  theme_bw() 



#trying whole network

station<- filter(data, entries.delta > 0 & entries.delta <6000 , exits.delta > 0 & exits.delta <6000)
station<- select(station,day_of_week, exits.delta, entries.delta) %>% 
  group_by(day_of_week) %>%
  summarise(total_entries=sum(entries.delta),total_exits=sum(exits.delta))

#sort by day of week here


station<- gather(station, exit_or_entry, total, total_entries:total_exits)



##PLot

ggplot(data=station, aes(x=day_of_week, y=total/length(unique(data$date)), fill=exit_or_entry)) + 
  geom_bar(colour="black", stat="identity",
           position=position_dodge(),
           size=.3) +                        # Thinner lines
  scale_fill_hue(name="Entry or Exit") +      # Set legend title
  xlab("Day of week") + ylab("Count") + # Set axis labels
  ggtitle("Entire System") +     # Set title
  theme_bw()



#42nd street

station_42<- filter(data,station == "42 ST-PA BUS TE", entries.delta > 0 & entries.delta <6000 , exits.delta > 0 & exits.delta <6000)
station_42<- select(station_42,day_of_week, exits.delta, entries.delta) %>% 
  group_by(day_of_week) %>%
  summarise(total_entries=sum(entries.delta),total_exits=sum(exits.delta))

#sort by day of week here



station_42<- gather(station_42, exit_or_entry, total, total_entries:total_exits)



##PLot

ggplot(data=station_42, aes(x=day_of_week, y=total/length(unique(data$date)), fill=exit_or_entry)) + 
  geom_bar(colour="black", stat="identity",
           position=position_dodge(),
           size=.3) +                        # Thinner lines
  scale_fill_hue(name="Entry or Exit") +      # Set legend title
  xlab("Day of week") + ylab("Count") + # Set axis labels
  ggtitle("42 ST-PA BUS TE") +     # Set title
  theme_bw()

#tramway



trams<- filter(data, c.a == "TRAM1" & c.a == "TRAM2", entries.delta > 0 , exits.delta > 0)
trams<- select(trams,day_of_week, exits.delta, entries.delta) %>% 
  group_by(day_of_week) %>%
  summarise(total_entries=sum(entries.delta),total_exits=sum(exits.delta))

#sort by day of week here


trams<- gather(trams, exit_or_entry, total, total_entries:total_exits)



##PLot

ggplot(data=trams, aes(x=day_of_week, y=total, fill=exit_or_entry)) + 
  geom_bar(colour="black", stat="identity",
           position=position_dodge(),
           size=.3) +                        # Thinner lines
  scale_fill_hue(name="Entry or Exit") +      # Set legend title
  xlab("Day of week") + ylab("Count") + # Set axis labels
  ggtitle("trams") +     # Set title
  theme_bw()
