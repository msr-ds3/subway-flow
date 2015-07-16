#Setworking Directory
setwd("~/Desktop")


#Loading required libraries
library(dplyr)
library(ggplot2)
library(reshape)
library(scales)



########################################
# load and clean turnstile data
########################################
#week of 6/27/15 to 7/3/15
mydata = read.table("turnstile_150704.txt",header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)

#week of 7/4/15 to 7/8/15
mydata2 = read.table("turnstile_150711.txt",header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)

data_dir <- '.'
# load each month of the trip data into one big data frame
txts <- Sys.glob(sprintf('%s/*.txt', data_dir))
subwaydata <- data.frame()
for (txt in txts) {
  tmp <- read.table(txt, header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)
  subwaydata <- rbind(subwaydata, tmp)
}


##
#complete_df<- cbind(subwaydata,df,df2)
#mutate(subwaydata, "no. of entries"  = data.frame(diff(subwaydata$ENTRIES)))
#merge(subwaydata,df,df2)



#arranging by date 
#dfarr<-arrange(mydata,desc(as.factor(DATE)))
#dfarr2<-arrange(mydata2,desc(as.factor(DATE)))


#Creating dataframe with num_entries and num_exits

df<-arrange(mydata,desc(as.factor(DATE))) %>%
  group_by(SCP,C.A, UNIT,STATION) %>%
  mutate(num_enteries = ENTRIES -lag(ENTRIES),
         num_exits = EXITS -lag(EXITS))

#GIO<-dfarr %>%
# group_by(as.factor(SCP)) %>%
#  mutate(num_enteries = c(0,diff(ENTRIES)))

#############################
#PLOTS
#############################
# plot no. entries vs. date
#qplot(day_of_week, num_entries, data=df,
 #     geom_histogram(),
  #  color = station,
    #  main="No. Entries vs. Dates",
   #   xlab="Dates", ylab="No. Entries")

# plot no. exits vs. date
#qplot(day_of_week, num_exits, data=df,
 #     geom_histogram(),
  #    color = station,
   #   main="No. Exits vs. Dates",
    #  xlab="Dates", ylab="No. Exits")

# seperate graphs by days of the week
# plot no. exits vs. date


# No. entries vs. time
#qplot(data = df, x = time, y = num_entries, color = as.factor(day_of_week))

#qplot(data = df, x = time, y = num_exits, color = as.factor(day_of_week))

#qplot(data = df, x = day_of_week, y = num_entries, color = as.factor(station))

#qplot(df, num_entries, )


# No. Entries vs. Time for each day of week
#ggplot(data=df, aes(x=TIME,y=num_enteries))+
  #facet_wrap(~ TIME))+
  #geom_line()

# total entries per day of week
#ggplot(data=df, aes(x=day_of_week,y=num_entries))+
 # geom_line()

# total exits per day of week
#ggplot(data=df, aes(x=day_of_week,y=num_exits))+
 # geom_line()


####
