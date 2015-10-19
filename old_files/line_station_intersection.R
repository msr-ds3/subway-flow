# Script to check how many stations have same name, and list of lines that intersect (but are not identical).
# Sebastien Lahaie
# 7/24/2015

# read in data
setwd("~subway-flow/")
data <- read.delim('GoogleLineNames.csv', header=TRUE, sep=',')

# remove unnecessary first column
data <- data[,2:4]

# form all possible pairs of rows
data.join <- merge(data, data, by=NULL)

# only keep row with same station name for both stations
data.join <- subset(data.join, google_station.x == google_station.y)

# only keep those whose line names differ
data.join <- subset(data.join, line_name.x != line_name.y)

# function to compute by how many lines intersect
overlap <- function(x,y) {length(intersect(strsplit(x, "")[[1]], strsplit(y, "")[[1]]))}

# add column with intersection value))
data.join$line_name.x <- as.character(data.join$line_name.x)
data.join$line_name.y <- as.character(data.join$line_name.y)
data.join$over <- with(data.join, overlap(line_name.x, line_name.y))

# check how many times we get an intersection
tmp <- subset(data.join, over > 0)
nrow(tmp)
