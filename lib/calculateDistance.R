source("dataFormat.R")

calculateDistance <- function(coordinates, mode){
  # This function calculates the distances from one location to all citi bike stations 
  # and returns the nearest citi bike station coordinate
  #
  # Input: coordinates of "current" or "destination" location
  #        mode: "pick up" or "drop off"
  # Output: coordinate of the nearest bike station
  c <- dataFormat() # read live stations info
  if(mode == "pickup"){
    dist <- rowSums((((c$nonzero-t(replicate(nrow(c$nonzero),coordinates)))*100))^2)
    nearest_station <- c$nonzero[which.min(dist),]
  }
  if(mode == "dropoff"){
    dist <- rowSums(((c$nonfull-t(replicate(nrow(c$nonfull),coordinates)))*100)^2)
    nearest_station <- c$nonfull[which.min(dist),]
  }
  return(nearest_station[c(2, 1)])  # (lon, lat)
}
