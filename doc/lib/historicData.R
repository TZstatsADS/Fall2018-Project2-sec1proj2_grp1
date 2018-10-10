
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

save(d, file = "../output/historicalData.RData")