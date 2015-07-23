library(dplyr)
n_names = read.table("./MergingData/readyformerge.txt",header=FALSE, sep=",", # current turnstyle dataframe
                       quote = "", row.names = NULL, strip.white = TRUE, 
                       stringsAsFactors = FALSE) 

names(n_names)[0:5] <- c("Transformed Turnstile Name", "Distance", "stop_name", "Transformed Google Name", "STATION")

n_names <- data.frame(n_names[,c(3,5)])

l_lines = read.table("./MergingData/s_gtfs_names.csv",header=TRUE, sep=",", #Stop_ids
                     fill=TRUE,quote = "", row.names = NULL, strip.white = TRUE,
                     stringsAsFactors = FALSE) 
all_lines <- as.data.frame(sapply(l_lines, function(x) gsub("\"", "", x)))

all_lines <- data.frame(all_lines[,c(2,3,4)])
names(all_lines) <- c("station_id", "line_name", "stop_name")

names_lines <- left_join(n_names, all_lines)
names_lines <- data.frame(names_lines[,c(2,3,4)])

ts_data = read.table("./MergingData/turnstile_150711.txt",header=TRUE, sep=",", #Stop_ids
                       fill=TRUE,quote = "", row.names = NULL, 
                       stringsAsFactors = FALSE) 

station_names <- inner_join(ts_data, names_lines, by = c("STATION", "LINENAME" = "line_name"))
View(station_names)

