library(tidyverse)
library(plot3Drgl)
library(rgl)
library(rgdal)

load("historicalData.RData")

d$time <- as.POSIXct(paste0("2018-01-01 ", substr(d$starttime, 12, 16)))

hist(d$time, breaks = "hours")

cut(d$time, breaks = 24)

d$hour = as.numeric(d$time) %% (24*60*60) / 3600
d$band = cut(d$hour, breaks=seq(0, 24), include.lowest=TRUE, 
                    right=FALSE)

dByTime <- d %>% group_by(start.station.longitude, start.station.latitude, band) %>%
  dplyr::summarize(n = n())

dPlot <- subset(dByTime, band == "[0,1)")

dPlot$`n()` <-   dPlot$`n()`/(30*9)


dPlot$lonBins = cut(dPlot$start.station.longitude, breaks=seq(min(dPlot$start.station.longitude), max(dPlot$start.station.longitude), length.out = 50), include.lowest=TRUE, right=FALSE)

dPlot$latBins = cut(dPlot$start.station.latitude, breaks=seq(min(dPlot$start.station.latitude), max(dPlot$start.station.latitude), length.out = 50), include.lowest=TRUE, right=FALSE)

dPlotPlot <- dPlot %>% group_by(lonBins, latBins) %>% dplyr::summarize(sum(n))

plotMatrix <- spread(dPlotPlot, key = latBins, value = `sum(n)`, fill = 0)
plotMatrix <- as.data.frame(plotMatrix)
rownames(plotMatrix) <- plotMatrix$lonBins
plotMatrix <- plotMatrix[,-1]
plotMatrix <- as.matrix(plotMatrix)




hist3D_fancy(dPlot$start.station.longitude, dPlot$start.station.latitude, dPlot$`n()`,  breaks = 20)


hist3D(z = plotMatrix)
plotrgl()