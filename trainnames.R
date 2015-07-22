library(dplyr)
n_names = read.table("./MergingData/readyformerge.txt",header=FALSE, sep=",", # current turnstyle dataframe
                       quote = "", row.names = NULL, 
                       stringsAsFactors = FALSE) 

names(n_names)[0:5] <- c("Transformed Turnstile Name", "Distance", "stop_name", "Transformed Google Name", "STATION")

View(n_names)

stops = read.table("./MergingData/stops_no_direction.txt",header=TRUE, sep=",", # current turnstyle dataframe
                     quote = "", row.names = NULL, 
                     stringsAsFactors = FALSE) 
View(stops)
names_stops <- left_join(n_names, stops, by = c("stop_name"))
View(names_stops)

names_stops <- names_stops[!duplicated(names_stops),]

ts_data = read.table("./MergingData/turnstile_150711.txt",header=TRUE, sep=",", # current turnstyle dataframe
                       fill=TRUE,quote = "", row.names = NULL, 
                       stringsAsFactors = FALSE) 
View(ts_data)
station_names <- left_join(ts_data, names_stops)
View(station_names)

#inshort <- station_names %>% group_by(STATION, `Original Google Name`,`Transformed Google Name`) %>% summarize()
#View(inshort)
