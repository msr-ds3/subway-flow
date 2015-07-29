library(dplyr)
setwd("~/subway-flow")
#My Merge Table is read in.
n_names = read.table("./MergingData/readyformerge.txt",header=FALSE, sep=",", # current turnstyle dataframe
                     quote = "", row.names = NULL, strip.white = TRUE, 
                     stringsAsFactors = FALSE) 

#Formatting stuff
names(n_names)[0:5] <- c("Transformed Turnstile Name", "Distance", "stop_name", "Transformed Google Name", "STATION")
n_names <- rbind(n_names, c("168 St - Washington Hts", 0, "168 St - Washington Hts", "168 St-Broadway", toupper("168 St-Broadway")))
n_names <- rbind(n_names, c("Cathedral Pkwy", 0, "Cathedral Pkwy", "Cathedral Pkwy", toupper("110 St-Cathedrl")))
n_names <- rbind(n_names, c("Christopher St", 0, "Christopher St - Sheridan Sq", "Christopher St - Sheridan Sq", toupper("Christopher St"))) 
n_names <- rbind(n_names, c("New Utrecht Ave", 0, "62 St", "62 St", toupper("New Utrecht Ave")))
n_names <- rbind(n_names, c("E Tremont Ave", 0, "West Farms Sq - E Tremont Av", "West Farms Sq - E Tremont Av", toupper("E Tremont Ave")))
n_names <- rbind(n_names, c("110 St-CPN", 0, "Central Park North (110 St)", "Central Park North (110 St)", toupper("110 St-CPN")))
n_names <- rbind(n_names, c("Metropolitan Av", 0, "Middle Village - Metropolitan Av", "Middle Village - Metropolitan Av", "METROPOLITAN AV"))
n_names <- rbind(n_names, c("Bay Pky-22 Ave", 0, "Bay Pkwy", "Bay Pkwy", toupper("Bay Pky-22 Ave")))
n_names <- rbind(n_names, c("Myrtle Ave", 0, "Myrtle - Wyckoff Avs", "Myrtle - Wyckoff Avs", "MYRTLE AVE"))
n_names <- rbind(n_names, c("21 St", 0, "21 St - Queensbridge", "21 St - Queensbridge",  toupper("21 St")))
n_names <- rbind(n_names, c("Lexington Ave", 0, "Lexington Av/63 St", "Lexington Av/63 St",  toupper("Lexington Ave")))
n_names <- rbind(n_names, c("Sutphin Blvd", 0, "Sutphin Blvd - Archer Av - JFK Airport", "Sutphin Blvd - Archer Av - JFK Airport",  toupper("Sutphin Blvd")))
n_names <- rbind(n_names, c("Court St", 0, "Court St", "Court St",  toupper("Borough Hall/Ct")))
n_names <- rbind(n_names, c("Roosevelt Ave", 0, "Jackson Hts - Roosevelt Av", "Jackson Hts - Roosevelt Av", "ROOSEVELT AVE"))
n_names <- rbind(n_names, c("BROADWAY/LAFAY", 0, "Broadway-Lafayette St", "Broadway-Lafayette St", "BROADWAY/LAFAY"))
n_names <- rbind(n_names, c("5 Ave-Bryant Pk", 0, "5 Av", "5 Av",  toupper("5 Ave-Bryant Pk")))
n_names <- rbind(n_names, c("East 105 St", 0, "E 105 St", "E 105 St", toupper("East 105 St")))
n_names <- rbind(n_names, c("Bedford Park Bl", 0, "Bedford Park Blvd - Lehman College", "Bedford Park Blvd - Lehman College", toupper("Bedford Park Bl")))
n_names <- rbind(n_names, c("Sutter Ave", 0, "Sutter Av - Rutland Rd", "Sutter Av - Rutland Rd", toupper("Sutter Ave")))
n_names <- rbind(n_names, c("Union Sq - 14 St", 0, "Union Sq - 14 St", "14 ST-UNION SQ", "14 ST-UNION SQ"))
n_names <- rbind(n_names, c("Broadway", 0, "Broadway", "Broadway", "BROADWAY-31 ST"))


l_lines = read.table("./GoogleLineNames.csv",header=TRUE, sep=",", #Stop_ids
                     fill=TRUE,quote = "\"", row.names = NULL, strip.white = TRUE,
                     stringsAsFactors = FALSE) 
#More Formatting!

all_lines = subset(l_lines[,c(2,3,4,5,6)])
names(all_lines) <- c("station_id", "line_name", "stop_name", "lat", "long")


#Eiman's stuff is combined with the nametable
names_lines <- right_join(n_names, all_lines)
names_lines <- names_lines[,c(3,5,6,7,8)]
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


#save(all_ts, file = "allts")
#View(all_ts)
write.csv(all_ts, "allts.csv", quote = FALSE)
#NTS: scale, convert to integers, check how different, then adjust as needed.
