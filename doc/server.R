library(shiny)
library(rjson)
library(leaflet)
library(here)
library(rgdal)

## Data Import

live <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_status.json")
stations <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_information.json")
load("../output/bikeRoutes.RData")

## markers

# http://www.mapito.net/map-marker-icons.html
pics <- list.files(path="../figs/numbers/mapiconscollection",pattern="*.png", full.names=T, recursive=FALSE)

begin <- as.numeric(as.matrix(gregexpr("_", pics)))
endd <- as.numeric(as.matrix(gregexpr("\\.[^\\.]*$", pics)))
picsNumber <- as.numeric(substring(pics, begin + 1, endd - 1))

pics <- pics[order(picsNumber)]

markers <- lapply(pics,  function(x) makeIcon(x, iconHeight = 3))
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
      addProviderTiles(providers$Stamen.Toner) %>%
      addMarkers(icon=~markers[s$available + 1]
                 , clusterOptions = markerClusterOptions()
                 ) %>% 
      addPolygons(data=routes,weight=3,col = 'green') %>%
      addWMSTiles(
        "http://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0r.cgi",
        layers = "nexrad-n0r-900913",
        options = WMSTileOptions(format = "image/png", transparent = TRUE),
        attribution = "Weather data ?? 2012 IEM Nexrad"
        # make it transparanet
      )


  })
})