dataFormat <- function(){
  # This function obtains live citi bike stations info and returns coordinates of available 
  # citi bike stations
  #
  # Input: none
  # Output: coordinate matrix of all stations 
  #         coordinate matrix of all stations with bikes
  #         coordinate matrix of all stations with available parking space
  library(rjson)
  
  ## Data Import
  live <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_status.json")
  stations <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_information.json")

  ## Data handling
  l <- length(stations$data$stations)
  s <- data.frame(lat = rep(NA, l), lng <- rep(NA, l))
  for(i in 1:l){
    s$lat[i] <- stations$data$stations[i][[1]]$lat
    s$lng[i] <- stations$data$stations[i][[1]]$lon
    s$available[i] <- live$data$stations[i][[1]]$num_bikes_available
    s$capacity[i] <- stations$data$stations[i][[1]]$capacity
  }
  
  # Remove 0 bikes stations
  s_nonzero <- s[-c(which(s$available==0)),]
  
  # Remove full bike stations
  s_nonfull <- s[-c(which(s$available == s$capacity)),]
  
  # Create pairs of lattitude and longitute for all bike stations
  pairs_all <- cbind(s$lat, s$lng)
  pairs_nonzero <- cbind(s_nonzero$lat, s_nonzero$lng)
  pairs_nonfull <- cbind(s_nonfull$lat, s_nonfull$lng)
  
  return(list(all = pairs_all, nonzero = pairs_nonzero, nonfull = pairs_nonfull))
}
