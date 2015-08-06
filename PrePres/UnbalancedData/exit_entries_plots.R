library(dplyr)
library(tidyr)
library(timeDate) 
library(data.table)
library(ggplot2)
library(scales)
#reading in subway_entries_exits.csv
subway_entries_exits<- read.table("PrePres/subway_entries_exits.csv", header=T, sep=',')
subway_entries_exits$X <- NULL

#creating a data frame to find total number of entries and exits across the entire system by date
subway_entries_exits_totals <- group_by(subway_entries_exits,date) %>%
  summarise(Entries=sum(hourly_entries)*4, Exits=sum(hourly_exits)*4)
subway_entries_exits_totals<- gather(subway_entries_exits_totals, exit_or_entry, total, Entries:Exits)

subway_entries_exits_totals$date <- as.Date(as.character(subway_entries_exits_totals$date), format = "%m/%d/%Y") 

#Plotting Entries vs Exits for Entire System

ggplot(data=subway_entries_exits_totals,aes(x=date, y=total, colour=exit_or_entry, group=exit_or_entry)) + 
  geom_line()+
  geom_point()+
  xlab("")  +
  scale_y_continuous(" ", limits=c(0, 7e6 ), breaks =c(0,2e6,4e6,6e6), labels = c("0", "2M" , "4M" , "6M"))+
  ggtitle("Entries vs Exits for Entire System\n") + 
  theme_bw()+
  scale_x_date(breaks = date_breaks("month"))+
  theme(legend.title = element_blank(), legend.position = c(.9,.1)) 
ggsave(file="Entries_vs_exits_entire_system.png", height = 7 , width = 10)


#Bargraph of entries vs exits
subway_entries_exits_means <- arrange(subway_entries_exits_totals, date) %>%
  mutate(day_of_week = dayOfWeek(as.timeDate(date)))
subway_entries_exits_means$day_of_week<-factor(subway_entries_exits_means$day_of_week, levels = c("Mon","Tue", "Wed","Thu","Fri"))

subway_entries_exits_means <- group_by(subway_entries_exits_means, as.factor(day_of_week), exit_or_entry) %>%
  summarise(avg=mean(total))

setnames(subway_entries_exits_means, old="as.factor(day_of_week)", new = "day_of_week")

ggplot(data=subway_entries_exits_means, aes(x=day_of_week, y=avg, fill=exit_or_entry,show_guide = FALSE)) + 
  geom_bar() + 
  geom_bar(colour="black", stat="identity",
           position=position_dodge(),
           size=.3 , show_guide = FALSE) +                       
  scale_fill_hue(name="Entry or Exit") +      
  xlab("")  +
  scale_y_continuous(" ", limits=c(0, 7e6 ), breaks =c(0,2e6,4e6,6e6), labels = c("0", "2M" , "4M" , "6M"))+
  ggtitle("Average Entries vs Exits per Day\n") +     
  theme_bw()+
  theme(legend.title = element_blank()) 

ggsave(file="Ave_Entries_vs_Exits_per_day.png")

