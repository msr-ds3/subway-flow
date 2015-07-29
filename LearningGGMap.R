library(ggmap)
library(ggplot2)

data <- read.csv("GoogleLineNames.csv")


#murder <- subset(crime, offense == "murder")

qmplot(stop_lon, stop_lat, data = data, color = as.factor(line_name), size = I(3), darken = .25)

ggmap(candle, zoom = 4)

newmap <- get_map(location = 'Manhattan', zoom = 12)

mapPoints <- ggmap(newmap)
head(mapPoints)
plot(newmap, zoom 14)

head(data)