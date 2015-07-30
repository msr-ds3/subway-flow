# Riva Tropp
# 7/27/2015
# Simple script to grab one chunk of data (all stations for one day at one four hour interval)

library(dplyr)
library(dplyr)
setwd("~/subway-flow/")

#Reading in train travel info 
traintravel <- read.table("SingularTrainFlow.csv",header=TRUE, 
                          sep=",",fill=TRUE,quote = "",row.names = NULL,
                          stringsAsFactors = FALSE) 

#Reformatting in a way that we'll be able to merge on easily 
traintravel <- data.frame(traintravel[,c(2,3,4,5,6,7,8,9)])
names(traintravel) <- c('train','train_stop','stop_id','station','time_travel','stop','line_name','station_id')

############################################################################################3

setwd("~/subway-flow/PrePres/")
all_sub <- read.table("entries_exits_average.csv",header=TRUE, sep=",", # current turnstyle dataframe
                     quote = "\"", row.names = NULL, strip.white = TRUE, 
                     stringsAsFactors = FALSE) 
head(all_sub)

#joinng 
nrow(all_sub)
uniquetravel<- unique(subset(traintravel,select=c("station_id","station")))
all_sub<- inner_join(uniquetravel,all_sub, by = "station_id")
nrow(all_sub)

all_sub %>% group_by(entry_exits_period) %>% 
  summarise(sum_entries = sum(hourly_entries), sum_exits = sum(hourly_exits)) -> sums

sums %>% mutate(ratio = sum_entries/sum_exits) -> sums
sums$sum_exits <- NULL
sums$sum_entries <- NULL
new_sub <- merge(all_sub, sums, by = "entry_exits_period")

new_sub %>% mutate(scaled_exits = hourly_exits * ratio) -> new_sub
new_sub %>% mutate(rounded_scaled_exits = as.integer(scaled_exits+.5)) -> new_sub2
new_sub2 %>% mutate(rounded_hourly_entries = as.integer(hourly_entries+.5)) -> new_sub2

new_sub2 %>% group_by(entry_exits_period) %>% 
  summarise(sum_entries = sum(rounded_hourly_entries), sum_exits = sum(rounded_scaled_exits)) -> diff_sub

diff_sub$diff <- diff_sub$sum_entries-diff_sub$sum_exits

diff_sub <- data.frame(diff_sub[,c(1,4)])

new_sub2 <- inner_join(new_sub2, diff_sub)

#new_sub2 %>% mutate(new_rounded_hourly_entries = ifelse(station_id == "127" & train=="1", rounded_hourly_entries - diff, rounded_hourly_entries)) -> new_sub2
new_sub2 %>% mutate(new_rounded_hourly_entries = ifelse(station_id == "127", rounded_hourly_entries - diff, rounded_hourly_entries)) -> new_sub2

View(new_sub2)

head(new_sub2)
the_wanted <- subset(new_sub2,select=c('entry_exits_period','station.x','rounded_scaled_exits','new_rounded_hourly_entries'))

latenight <- filter(the_wanted, entry_exits_period == "0:4")
morning <- filter(the_wanted, entry_exits_period == "4:8")
latemorning <- filter(the_wanted, entry_exits_period == "8:12")
noon <- filter(the_wanted, entry_exits_period == "12:16")
evening <- filter(the_wanted, entry_exits_period == "16:20")
night <- filter(the_wanted, entry_exits_period == "20:0")
allday <- the_wanted
am <- filter(the_wanted, entry_exits_period == "0:4" | entry_exits_period == "4:8" | entry_exits_period == "8:12")
pm <- filter(the_wanted, entry_exits_period == "12:16" | entry_exits_period == "16:20" | entry_exits_period == "20:0")


write.csv(latenight, "f_latenight.csv",quote=FALSE)
write.csv(morning, "f_morning.csv",quote=FALSE)
write.csv(noon, "f_noon.csv",quote=FALSE)
write.csv(evening, "f_evening.csv",quote=FALSE)
write.csv(night, "f_night.csv",quote=FALSE)
write.csv(latemorning, "f_latemorning.csv",quote=FALSE)
write.csv(allday, "f_allday.csv",quote=FALSE)
write.csv(am, "f_am.csv",quote=FALSE)
write.csv(pm, "f_pm.csv",quote=FALSE)


#Checking to make sure it's 0:

new_sub2 %>% group_by(entry_exits_period) %>% 
  summarise(sum_entries = sum(new_rounded_hourly_entries), sum_exits = sum(rounded_scaled_exits)) -> diff_sub

diff_sub$diff <- diff_sub$sum_entries-diff_sub$sum_exits
head(diff_sub)
