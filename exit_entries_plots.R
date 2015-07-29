library(dplyr)
library(tidyr)
library(timeDate) 
library(data.table)
library(ggplot2)

subway_entries_exits<- read.table("subway_entries_exits.csv", header=T, sep=',')

subway_entries_exits$X <- NULL
#should we still be leaving out weekends for this?

subway_entries_exits_totals <- group_by(subway_entries_exits,date) %>%
  summarise(total_entries=sum(hourly_entries)*4,total_exits=sum(hourly_exits)*4)
subway_entries_exits_totals<- gather(subway_entries_exits_totals, exit_or_entry, total, total_entries:total_exits)

subway_entries_exits_totals$date <- as.Date(as.character(subway_entries_exits_totals$date), format = "%m/%d/%Y") 
#Plots




#Entries vs Exits for Entire System

ggplot(data=subway_entries_exits_totals,aes(x=date, y=total, colour=exit_or_entry, group=exit_or_entry)) + 
     geom_line()+
   geom_point()+
  xlab("Date") + ylab("Count") +
  ggtitle("Entries vs Exits for Entire System") + 
  theme_bw()
ggsave(file="Entries_vs_Exits_for_Entire_System.png", width=4, height=4)

#Bargraph of exit vs entry
subway_entries_exits_means <- arrange(subway_entries_exits_totals, date) %>%
  mutate(day_of_week = dayOfWeek(as.timeDate(date)))
subway_entries_exits_means$day_of_week<-factor(subway_entries_exits_means$day_of_week, levels = c("Mon","Tue", "Wed","Thu","Fri"))

subway_entries_exits_means <- group_by(subway_entries_exits_means, as.factor(day_of_week), exit_or_entry) %>%
  summarise(avg=mean(total))

setnames(subway_entries_exits_means, old="as.factor(day_of_week)", new = "day_of_week")

ggplot(data=subway_entries_exits_means, aes(x=day_of_week, y=avg, fill=exit_or_entry)) + 
  geom_bar(colour="black", stat="identity",
           position=position_dodge(),
           size=.3) +                        
  scale_fill_hue(name="Entry or Exit") +      
  xlab("Day of week") + ylab("Count") + 
  ggtitle("Entries vs Exits") +     
  theme_bw()
ggsave(file="Entries vs Exits.png")
