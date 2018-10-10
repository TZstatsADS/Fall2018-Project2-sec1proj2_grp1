library(tidyverse)
m <- c("01", "02", "03", "04", "05", "06", "07", "08", "09")

urls <- paste0("https://s3.amazonaws.com/tripdata/JC-2018",
               m, "-citibike-tripdata.csv.zip")

dList <- list()
j <- 1
for(i in urls){
  temp <- tempfile()
  download.file(i,temp)
  dList[[j]] <- read.csv(unz(temp, substr(i, 35, 65)))
  unlink(temp)
  j = j + 1
}

d <- do.call("rbind", dList) 

d$time <- as.POSIXct(paste0("2018-01-01 ", substr(d$starttime, 12, 16)))

d$hour = as.numeric(d$time) %% (24*60*60) / 3600
d$band = cut(d$hour, breaks=seq(0, 24), include.lowest=TRUE, 
             right=FALSE)

dByTime <- d %>% group_by(start.station.longitude, start.station.latitude, band) %>%
  dplyr::summarize(n = n())

dByTime$n <- dByTime$n/30*9


dByTime$lonBins = cut(dByTime$start.station.longitude, breaks=seq(min(dByTime$start.station.longitude), max(dByTime$start.station.longitude), length.out = 50), include.lowest=TRUE, right=FALSE)

dByTime$latBins = cut(dByTime$start.station.latitude, breaks=seq(min(dByTime$start.station.latitude), max(dByTime$start.station.latitude), length.out = 50), include.lowest=TRUE, right=FALSE)

intervals <- levels(d$band)

save(list = c("dByTime", "intervals"), file = "./output/historicalData.RData")
