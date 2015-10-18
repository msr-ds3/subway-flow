# Riva Tropp
# 7/27/2015
# Simple script to scale up exits to match entries for use in min-cost-flow algorithm.

library(dplyr)
library(dplyr)
setwd("~/subway-flow")

#Reading in train travel info 
traintravel <- read.table("SingularTrainFlow.csv",header=TRUE, 
                          sep=",",fill=TRUE,quote = "",row.names = NULL,
                          stringsAsFactors = FALSE) 

#Reformatting in a way that we'll be able to merge on easily 
traintravel <- data.frame(traintravel[,c(2,3,4,5,6,7,8,9)])
names(traintravel) <- c('train','train_stop','stop_id','station','time_travel','stop','line_name','station_id')

############################################################################################3

all_sub <- read.table("entries_exits_average.csv",header=TRUE, sep=",", # current turnstyle dataframe
                      quote = "\"", row.names = NULL, strip.white = TRUE, 
                      stringsAsFactors = FALSE) 

balancethings <- function(all_sub){
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
  
  new_sub2 %>% mutate(new_rounded_hourly_entries = ifelse(station_id == "127", rounded_hourly_entries - diff, rounded_hourly_entries)) -> new_sub2
  return(new_sub2)
}

#joining 
new_sub2 <- balancethings(all_sub)
the_wanted <- subset(new_sub2,select=c('entry_exits_period','station.x','rounded_scaled_exits','new_rounded_hourly_entries','station_id'))

latenight <- filter(the_wanted, entry_exits_period == "0:4")
morning <- filter(the_wanted, entry_exits_period == "4:8")
latemorning <- filter(the_wanted, entry_exits_period == "8:12")
noon <- filter(the_wanted, entry_exits_period == "12:16")
evening <- filter(the_wanted, entry_exits_period == "16:20")
night <- filter(the_wanted, entry_exits_period == "20:0")


write.csv(latenight, "f_latenight.csv",quote=FALSE)
write.csv(morning, "f_morning.csv",quote=FALSE)
write.csv(noon, "f_noon.csv",quote=FALSE)
write.csv(evening, "f_evening.csv",quote=FALSE)
write.csv(night, "f_night.csv",quote=FALSE)
write.csv(latemorning, "f_latemorning.csv",quote=FALSE)
write.csv(the_wanted, "all_entries_exits.csv", quote = FALSE)

#Morning hours
am_sub <- read.table("entries_exits_012.csv",header=TRUE, sep=",", # current turnstyle dataframe
                     quote = "\"", row.names = NULL, strip.white = TRUE, 
                     stringsAsFactors = FALSE) 
am_sub2 <- balancethings(am_sub)
am_wanted <- subset(am_sub2,select=c('entry_exits_period','station.x','rounded_scaled_exits','new_rounded_hourly_entries','station_id'))
write.csv(am_wanted, "f_am.csv",quote=FALSE)

#PM hours
pm_sub <- read.table("entries_exits_1224.csv",header=TRUE, sep=",", # current turnstyle dataframe
                     quote = "\"", row.names = NULL, strip.white = TRUE, 
                     stringsAsFactors = FALSE) 
pm_sub2 <- balancethings(pm_sub)
pm_wanted <- subset(pm_sub2,select=c('entry_exits_period','station.x','rounded_scaled_exits','new_rounded_hourly_entries','station_id'))
write.csv(pm_wanted, "f_pm.csv",quote=FALSE)

#All hours
sub <- read.table("entries_exits_wholeday.csv",header=TRUE, sep=",", # current turnstyle dataframe
                  quote = "\"", row.names = NULL, strip.white = TRUE, 
                  stringsAsFactors = FALSE) 
sub2 <- balancethings(sub)
sub_wanted <- subset(sub2,select=c('entry_exits_period','station.x','rounded_scaled_exits','new_rounded_hourly_entries','station_id'))
write.csv(sub_wanted, "f_allday.csv",quote=FALSE)

#Checking to make sure it's 0:

new_sub2 %>% group_by(entry_exits_period) %>% 
  summarise(sum_entries = sum(new_rounded_hourly_entries), sum_exits = sum(rounded_scaled_exits)) -> diff_sub

diff_sub$diff <- diff_sub$sum_entries-diff_sub$sum_exits
#head(diff_sub)


