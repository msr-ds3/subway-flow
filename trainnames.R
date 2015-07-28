# CURRENT
# Riva Tropp
# 07/27/2015

library(dplyr)
setwd("~/subway-flow")
#My Merge Table is read in.
n_names = read.table("./MergingData/readyformerge.txt",header=FALSE, sep=",", # current turnstyle dataframe
                       quote = "", row.names = NULL, strip.white = TRUE, 
                       stringsAsFactors = FALSE) 

#Formatting stuff
names(n_names)[0:5] <- c("Transformed Turnstile Name", "Distance", "stop_name", "Transformed Google Name", "STATION")
n_names <- data.frame(n_names[,c(3,5)])

#Eiman's Station names are read in:
l_lines = read.table("./NewGoogleLineNames.csv",header=TRUE, sep=",", #Stop_ids
                     fill=TRUE,quote = "", row.names = NULL, strip.white = TRUE,
                     stringsAsFactors = FALSE) 

#More Formatting!
all_lines <- as.data.frame(sapply(l_lines, function(x) gsub("\"", "", x)))
all_lines <- data.frame(all_lines[,c(2,3,4)])
names(all_lines) <- c("station_id", "line_name", "stop_name")

#Eiman's stuff is combined with the nametable
names_lines <- inner_join(n_names, all_lines)
names_lines <- data.frame(names_lines[,c(2,3,4)])

#Now we just have the station, E's ID, and the linenames.

#Loading in all TS Files.
data_dir <- "./MergingData/new_ts/"
txts <- Sys.glob(sprintf('%s/turnstile_1*.txt', data_dir))
ts_data <- data.frame()
txts <- txts[1]
for (txt in txts) {
  tmp <- read.table(txt, header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)
  ts_data <- rbind(ts_data, tmp)
}

#Joining TS Files with Eiman's Station Names
all_ts <- left_join(names_lines, ts_data, by = "STATION")

#Turn both linename fields to strings
all_ts$AEILMN <- sapply(all_ts$AEILMN, toString)
all_ts$line_name <- sapply(all_ts$line_name, toString)

#Sebastian's function to get intersection lengths.
overlap <- function(x,y) {length(intersect(strsplit(x, "")[[1]], strsplit(y, "")[[1]]))}

#Columns to get intersection, get min length of string
all_ts$intersect <- mapply(overlap, all_ts$AEILMN, all_ts$line_name)
all_ts$lenline <- sapply(all_ts$line_name, nchar)
all_ts$lenaiel <- sapply(all_ts$AEILMN, nchar)
all_ts$minline <- mapply(min, all_ts$lenaiel, all_ts$lenline)
all_ts$lenline <- NULL
all_ts$lenaiel <- NULL

#Test if the intersection is meaningful.
all_ts <- all_ts %>% mutate(matches = (intersect == minline))
all_ts$minline <- NULL
all_ts$intersect <- NULL

#Filter out nonmeaningful intersections (i.e, station names without shared lines).
all_ts <- all_ts %>% filter(matches == TRUE)
all_ts$matches <- NULL
View(all_ts)


#NTS: scale, convert to integers, check how different, then adjust as needed.


