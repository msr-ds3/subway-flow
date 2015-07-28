# Riva Tropp
# 7/27/2015
# Simple script to grab one chunk of data (all stations for one day at one four hour interval)

library(dplyr)
setwd("~/subway-flow/PrePres")
all_sub <- read.table("entries_exits_average.csv",header=TRUE, sep=",", # current turnstyle dataframe
                     quote = "\"", row.names = NULL, strip.white = TRUE, 
                     stringsAsFactors = FALSE) 
head(all_sub)

all_sub %>% group_by(entry_exits_period) %>% 
  summarise(sum_entries = sum(mean_hourly_entries), sum_exits = sum(mean_hourly_exits)) -> sums

sums %>% mutate(ratio = sum_entries/sum_exits) -> sums
sums$sum_exits <- NULL
sums$sum_entries <- NULL
new_sub <- merge(all_sub, sums, by = "entry_exits_period")



new_sub %>% mutate(scaled_exits = mean_hourly_exits * ratio) -> new_sub
new_sub %>% mutate(rounded_scaled_exits = as.integer(scaled_exits+.5)) -> new_sub2
new_sub2 %>% mutate(rounded_hourly_entries = as.integer(mean_hourly_entries+.5)) -> new_sub2

new_sub2 %>% group_by(entry_exits_period) %>% 
  summarise(sum_entries = sum(rounded_hourly_entries), sum_exits = sum(rounded_scaled_exits)) -> diff_sub

diff_sub$diff <- diff_sub$sum_entries-diff_sub$sum_exits
head(diff_sub)

diff_sub <- data.frame(diff_sub[,c(1,4)])

new_sub2 <- inner_join(new_sub2, diff_sub)

new_sub2[new_sub2$station_id == "127",]$rounded_hourly_entries = new_sub2$rounded_hourly_entries + new_sub2$diff

new_sub2 %>% mutate(new_rounded_hourly_entries = ifelse(station_id == "127", rounded_hourly_entries - diff, rounded_hourly_entries)) -> new_sub2
View(new_sub2)


head(new_sub2)
the_wanted <- data.frame(new_sub2[,c(1,3,4,10,13)])
names(the_wanted)[0:5] <- c("entry_exits_period", "station", "station_id", "exits", "entries")

latenight <- filter(the_wanted, entry_exits_period == "0:4")
morning <- filter(the_wanted, entry_exits_period == "4:8")
noon <- filter(the_wanted, entry_exits_period == "12:16")
evening <- filter(the_wanted, entry_exits_period == "16:20")
night <- filter(the_wanted, entry_exits_period == "20:0")

write.csv(latenight, "f_latenight.csv")
write.csv(morning, "f_morning.csv")
write.csv(noon, "f_noon.csv")
write.csv(evening, "f_evening.csv")
write.csv(night, "f_night.csv")

#Checking to make sure it's 0:

new_sub2 %>% group_by(entry_exits_period) %>% 
  summarise(sum_entries = sum(new_rounded_hourly_entries), sum_exits = sum(rounded_scaled_exits)) -> diff_sub

diff_sub$diff <- diff_sub$sum_entries-diff_sub$sum_exits
head(diff_sub)
