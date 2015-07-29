library(ggmap)
library(ggplot2)

data <- read.csv("GoogleLineNames.csv")
murder <- subset(crime, offense == "murder")

qmplot(lon, lat, data = murder, color = I('white'), size = I(3), darken = .25)

ggmap(candle, zoom = 4)

newmap <- get_map(location = 'Manhattan', zoom = 12)

ggmap(newmap)

head(mapPoints)
plot(newmap, zoom = 14)
