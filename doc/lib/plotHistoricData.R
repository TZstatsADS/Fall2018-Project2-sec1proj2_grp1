library(tidyverse)
library(plot3Drgl)
library(rgl)
library(rgdal)

load("output/historicalData.RData")


dPlot <- subset(dByTime, band == "[0,1)")

dPlotPlot <- dPlot %>% group_by(lonBins, latBins) %>% dplyr::summarize(sum(n))

plotMatrix <- spread(dPlotPlot, key = latBins, value = `sum(n)`, fill = 0)
plotMatrix <- as.data.frame(plotMatrix)
rownames(plotMatrix) <- plotMatrix$lonBins
plotMatrix <- plotMatrix[,-1]
plotMatrix <- as.matrix(plotMatrix)

hist3D(z = plotMatrix)
plotrgl()