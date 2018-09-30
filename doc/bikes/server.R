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

live <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_status.json")
stations <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_information.json")

## data handling

l <- length(stations$data$stations)

stationsPos <- data.frame(lat = rep(NA, l), lng <- rep(NA, l))
for(i in 1:l){
  stationsPos$lat[i] <- stations$data$stations[i][[1]]$lat
  stationsPos$lng[i] <- stations$data$stations[i][[1]]$lon
}


# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  output$map <- renderLeaflet({
    nycIcon <- makeIcon(
      iconUrl = "http://main.tvgu1jdkm2wvqi.maxcdn-edge.com/wp-content/uploads/2016/SLH/mlb_primary/new_york_yankees_1915-1946.png",
      iconWidth = 20*215/230, iconHeight = 20,
      iconAnchorX = 20*215/230/2, iconAnchorY = 16
    )
    
    stationsPos %>% 
      leaflet() %>%
      addTiles() %>%
      addMarkers(icon = nycIcon)

  })
})