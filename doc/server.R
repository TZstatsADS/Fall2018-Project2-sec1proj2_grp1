#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(rjson)
library(leaflet)
library(here)

live <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_status.json")
stations <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_information.json")

## markers

# http://www.mapito.net/map-marker-icons.html
pics <- list.files(path="../figs/numbers/mapiconscollection",pattern="*.png", full.names=T, recursive=FALSE)

begin <- as.numeric(as.matrix(gregexpr("_", pics)))
endd <- as.numeric(as.matrix(gregexpr("\\.[^\\.]*$", pics)))
picsNumber <- as.numeric(substring(pics, begin + 1, endd - 1))

pics <- pics[order(picsNumber)]

markers <- lapply(pics,  function(x) makeIcon(x))
class(markers) <- "leaflet_icon_set"


## data handling

l <- length(stations$data$stations)

s <- data.frame(lat = rep(NA, l), lng <- rep(NA, l))
for(i in 1:l){
  s$lat[i] <- stations$data$stations[i][[1]]$lat
  s$lng[i] <- stations$data$stations[i][[1]]$lon
  s$available[i] <- live$data$stations[i][[1]]$num_bikes_available
}

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  output$map <- renderLeaflet({

    s %>% 
      leaflet() %>%
      addTiles() %>%
      addMarkers(icon=~markers[s$available + 1]
                 # , clusterOptions = markerClusterOptions()
                 )

  })
})