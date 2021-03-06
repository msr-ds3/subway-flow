library(dplyr)
library(scales)
library(locfit)

setwd("~/subway/data")
stops <- read.table('differentstopids.txt',header=TRUE, 
                         sep=",",fill=TRUE,quote = "",row.names = NULL,
                         stringsAsFactors = FALSE) 
head(stops)
#Split the two columns (to and from) into 2 dfs
from <- as.data.frame(stops$from_stop_id)
to <- as.data.frame(stops$to_stop_id)
time <- stops$min_transfer_time

#Take the stop ids and names from my version of stops.txt (made with cursedcolumn.awk)
csvs <- Sys.glob(sprintf('reducedstops.txt', data_dir))
stop_ids <- data.frame()
for (csv in csvs) {
  tmp <- read.table(csv, header=T, sep=',', na.strings='\\N')
  stop_ids <- rbind(stop_ids, tmp)
}

#Get rid of trailing letters in the stops.txt dataframe
stop_ids$stop_id <- (gsub("[A-Z]$", "", just_ids$stop_id, ignore.case = T))

#Change both to have 'stop_id' as the name of the first column.

stop_ids %>% group_by(stop_id) 

#Join the stops with the names and remove the duplicates
names(from)[1] <- "from_stop_id"
names(stop_ids)[1] <- "from_stop_id"
from_info <- left_join(from, stop_ids)

#Join the stops with the names and remove the duplicates
names(to)[1] <- "to_stop_id"
names(stop_ids)[1] <- "to_stop_id"
to_info <- left_join(to, stop_ids)

names(time)[1] <- "min_transfer_time"

#Re-join the to and from columns for transfers, now with names incorporated.
joined_info <- cbind(from_info, to_info)
head(joined_info)
joined_info <- joined_info[!duplicated(joined_info),]
joined_info <- cbind(joined_info, time)

head(joined_info)
#Saves
save(joined_info, file=sprintf('%s/transferids.RData', data_dir))
write.csv(joined_info, file = "transferids.csv")

View(joined_info)
