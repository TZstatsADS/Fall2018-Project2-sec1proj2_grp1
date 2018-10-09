dataFormat <- function(s){
  # This function obtains live citi bike stations info and returns coordinates of available 
  # citi bike stations
  #
  # Input: live station data
  # Output: coordinate matrix of all stations 
  #         coordinate matrix of all stations with bikes
  #         coordinate matrix of all stations with available parking space
  
  ## Data handling
<<<<<<< HEAD
  l <- length(stations$data$stations)
  for(i in 1:l){
=======
  for(i in 1:nrow(s)){
>>>>>>> 7c948f69113931f2f94de817271e14617f2c3bb6
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
