0##############################################################################
# * It seems as if they've added more remote control units in the current data
##############################################################################

########################################
# load libraries
########################################
library(dplyr)
library(gdata)

# set path to working directory
setwd("~/Desktop/ds3-2015/subway")

# set the data directory
data_dir <- '.'

########################################
# load and clean Subway-Turnstile data
########################################

# load remote booth station
rbData = read.xls("Remote-Booth-Station.xls") 

# load week ending 03/31/2012 turnstile data
oldTsData <- read.table("turnstile_100505.txt", sep=",",fill=TRUE,quote = "",
                        row.names = NULL,stringsAsFactors = FALSE) 
names(oldTsData) <- c("C.A","UNIT","SCP","DATE1","TIME1","DESC1","ENTRIES1","EXITS1",
                      "DATE2","TIME2","DESC2","ENTRIES2","EXITS2","DATE3","TIME3",
                      "DESC3","ENTRIES3","EXITS3","DATE4","TIME4","DESC4","ENTRIES4",
                      "EXITS4","DATE5","TIME5","DESC5","ENTRIES5","EXITS5","DATE6",
                      "TIME6","DESC6","ENTRIES6","EXITS6","DATE7","TIME7","DESC7",
                      "ENTRIES7","EXITS7","DATE8","TIME8","DESC8","ENTRIES8","EXITS8")

# load current data
currentTsData = read.table("turnstile_150711.txt",header=TRUE, sep=",",fill=TRUE,quote = "",
                           row.names = NULL, stringsAsFactors = FALSE) 
# compare number of turnstyles
# * Note currentTsData is missing R002, R065, and R068 D*=
# * Note oldTsData is missing R459, R325, R120, R468, R469
select(oldTsData, UNIT) %>% arrange(UNIT) %>% unique() 
select(currentTsData, UNIT) %>% arrange(UNIT) %>% unique() 
a <- select(oldTsData, UNIT) %>% unique()
b <- select(currentTsData, UNIT) %>% unique()

# Look at what turnstiles have been added/removed
setdiff(a,b)
setdiff(b,a)

# I realized individual turnstiles are unique to stations
# and can be used to find station name for old data
select(oldTsData, C.A) %>% arrange(C.A) %>% unique() 
select(currentTsData, C.A) %>% arrange(C.A) %>% unique() 

# look at unique booths and stations
boothStations <- select(rbData, Booth, Station) %>% 
  unique() 

# create new df matching booths of oldTsData wtih station name
temp <- data.frame()

for(i in oldTsData$C.A){
  for(j in boothStations$Booth){
    if(i == j){
      
    }
  }
}

# find non-unique remote units (units at more than a single location)
# we want the same remote units with different stations

# find difference in entries
# plot graphs
