library(dplyr)
setwd("~/subway-flow")
#My Merge Table is read in.
n_names = read.table("./MergingData/readyformerge.txt",header=FALSE, sep=",", # current turnstyle dataframe
                     quote = "", row.names = NULL, strip.white = TRUE, 
                     stringsAsFactors = FALSE) 

#Formatting stuff
names(n_names)[0:5] <- c("Transformed Turnstile Name", "Distance", "stop_name", "Transformed Google Name", "STATION")

n_names <- rbind(n_names, c("Metropolitan Av", 0, "Middle Village - Metropolitan Av", "Middle Village - Metropolitan Av", "Metropolitan Av"))
n_names <- rbind(n_names, c("Bay Pky-22 Ave", 0, "Bay Pkwy", "Bay Pkwy", "Bay Pky-22 Ave"))
n_names <- rbind(n_names, c("Myrtle Ave", "Myrtle - Wyckoff Avs", "Myrtle - Wyckoff Avs", "Myrtle Ave"))
n_names <- rbind(n_names, c("21 St", "21 St - Queensbridge", "21 St - Queensbridge", "21 St"))
n_names <- rbind(n_names, c("Lexington Ave", "Lexington Av/63 St", "Lexington Av/63 St", "Lexington Ave"))
n_names <- rbind(n_names, c("Sutphin Blvd", "Sutphin Blvd - Archer Av - JFK Airport", "Sutphin Blvd - Archer Av - JFK Airport", "Sutphin Blvd"))
n_names <- rbind(n_names, c("Borough Hall/Ct", "Court St", "Court St", "Borough Hall/Ct"))
n_names <- rbind(n_names, c("Roosevelt Ave", "Jackson Hts - Roosevelt Av", "Jackson Hts - Roosevelt Av", "Roosevelt Ave"))
n_names <- rbind(n_names, c("Broadway/Lafay", "Broadway-Lafayette St", "Broadway-Lafayette St", "Broadway/Lafay"))
n_names <- rbind(n_names, c("5 Ave-Bryant Pk", "5 Av", "5 Av", "5 Ave-Bryant Pk"))
n_names <- rbind(n_names, c("East 105 St", "E 105 St", "E 105 St", "East 105 St"))
n_names <- rbind(n_names, c("Bedford Park Bl", "Bedford Park Blvd - Lehman College", "Bedford Park Blvd - Lehman College", "Bedford Park Bl"))
n_names <- rbind(n_names, c("Sutter Ave", "Sutter Av - Rutland Rd", "Sutter Av - Rutland Rd", "Sutter Ave"))
n_names <- rbind(n_names, c("110 St-CPN", "Central Park North (110 St)", "Central Park North (110 St)", "110 St-CPN"))
n_names <- rbind(n_names, c("E Tremont Ave", "West Farms Sq - E Tremont Av", "West Farms Sq - E Tremont Av", "E Tremont Ave"))
n_names <- rbind(n_names, c("New Utrecht Ave", "62 St", "62 St", "New Utrecht Ave"))
n_names <- rbind(n_names, c("Christopher St", "Christopher St - Sheridan Sq", "Christopher St - Sheridan Sq", "Christopher St")) 
n_names <- rbind(n_names, c("110 St-Cathedrl", "Cathedral Pkwy", "Cathedral Pkwy", "110 St-Cathedrl"))
n_names <- rbind(n_names, c("168 St - Washington Hts", "168 St-Broadway", "168 St-Broadway", "168 St - Washington Hts"))

l_lines = read.table("./NewGoogleLineNames.csv",header=TRUE, sep=",", #Stop_ids
                     fill=TRUE,quote = "\"", row.names = NULL, strip.white = TRUE,
                     stringsAsFactors = FALSE) 

#More Formatting!
all_lines = subset(l_lines[,c(2,3,4)])
names(all_lines) <- c("station_id", "line_name", "stop_name")

#Eiman's stuff is combined with the nametable
names_lines <- right_join(n_names, all_lines)
names_lines <- data.frame(names_lines[, c(5,6,7)])

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


