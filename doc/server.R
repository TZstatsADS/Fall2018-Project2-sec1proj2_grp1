packages <- c("shiny", 
              "rjson", 
              "leaflet", 
              "rgdal", 
              "chron", 
              "leaflet.extras",
              "htmltools",
              "htmlwidgets")

source("../lib/dataFormat.R")
source("../lib/routing.R")

# Install and load packages only if needed
package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = T)) install.packages(x)
  if (! (x %in% (.packages() )))  library(x, character.only = T)
})

## Data Import

live <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_status.json")
stations <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_information.json")
load("../output/bikeRoutes.RData")

crime <- read.csv("../data/NYPD.csv")

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

# stations
l <- length(stations$data$stations)
s <- data.frame(lat = rep(NA, l), lng = rep(NA, l))
for(i in 1:l){
  s$lat[i] <- stations$data$stations[i][[1]]$lat
  s$lng[i] <- stations$data$stations[i][[1]]$lon
  s$available[i] <- live$data$stations[i][[1]]$num_bikes_available
  s$capacity <- stations$data$stations[i][[1]]$capacity
}
# Convert the dataframe to list of 3 dataframes representing the 
# station with bikes, docks and all.
c <- dataFormat(s)

# ##  Create cuts:
# x_c <- cut(s$lat, 60)
# y_c <- cut(s$lng, 60)
# 
# ##  Calculate joint counts at cut levels:
# z <- table(x_c, y_c)
# 
# library(plot3D)
# 
# hist3D(z = as.matrix(s))

# street felonies in Manhattan
crime.m <- subset(crime, crime$BORO_NM=="MANHATTAN")
crime.m.f <- subset(crime.m, crime.m$LAW_CAT_CD=="FELONY")
crime.m.f$date <- as.Date(crime.m.f$CMPLNT_FR_DT, format = "%m/%d/%Y")
# Only 2018 
# cd<- subset(crime.m.f, date> "2017-12-31" & date < "2018-12-05")
# Only street crime
c.street <- subset(crime.m.f, crime.m.f$PREM_TYP_DESC=="STREET")

crime.m.f$date <- as.Date(crime.m.f$CMPLNT_FR_DT, format = "%m/%d/%Y")
c.street$time <- as.POSIXct(as.character(c.street$CMPLNT_FR_TM), format = "%H:%M")
c.street$time <- chron(times. = as.character(c.street$CMPLNT_FR_TM))
c.street$t <- c.street$time
c.street$t <- as.character(c.street$t)
c.street$t[c.street$time > "6:00:00" & c.street$time <"12:00:00"] <- "morning"
c.street$t[c.street$time >= "12:00:00" & c.street$time <"18:00:00"] <- "afternoon"
c.street$t[c.street$time >= "18:00:00" & c.street$time <"23:59:59"] <- "evening"
c.street$t[c.street$time >= "0:00:00" & c.street$time <="6:00:00"] <- "night"

c1 <- subset(c.street, c.street$t=="morning")
c2 <- subset(c.street, c.street$t=="afternoon")
c3 <- subset(c.street, c.street$t=="evening")
c4 <- subset(c.street, c.street$t=="night")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  output$map <- renderLeaflet({

    s %>% 
      leaflet() %>%
      addProviderTiles(providers$Stamen.Toner) %>%
      addMarkers(icon=~markers[s$available + 1],
                 clusterOptions = markerClusterOptions(),
                 group = "station info"
                 ) %>%
      addPolygons(data=routes, weight=1, col = 'green', 
                  smoothFactor = 1000, group = "bike routes",
                  opacity = 1, noClip = T) %>%
      # addWMSTiles(
      #   "http://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0r.cgi",
      #   layers = "nexrad-n0r-900913",
      #   options = WMSTileOptions(format = "image/png", transparent = TRUE),
      #   attribution = "Weather data ?? 2012 IEM Nexrad",
      #   group = "rain radar"
      #   # make it transparanet
      # )%>%
      addLayersControl(
        baseGroups = c("crimes - morning", "crimes - afternoon","crimes - evening",'crimes - night'),
        overlayGroups = c("bike routes", "station info", "routing"
                          # , "rain radar"
                          ),
        options = layersControlOptions(collapsed = FALSE)) %>%
      addWebGLHeatmap(data = c1, lng = ~Longitude, lat = ~Latitude, 
                      size = 700, opacity = 0.6, group = "crimes - morning") %>%
      addWebGLHeatmap(data = c2, lng = ~Longitude, lat = ~Latitude, 
                      size = 700, opacity = 0.6, group = "crimes - afternoon") %>%
      addWebGLHeatmap(data = c3, lng = ~Longitude, lat = ~Latitude, 
                      size = 700, opacity = 0.6, group = "crimes - evening") %>%
      addWebGLHeatmap(data = c4, lng = ~Longitude, lat = ~Latitude, 
                      size = 700, opacity = 0.6, group = "crimes - night") %>%
      hideGroup(c("bike routes", "crimes - morning", "crimes - afternoon","crimes - evening",'crimes - night'
                  # , "rain radar"
                  ))

  })

  observeEvent(input$submit, {
    leafletProxy("map") %>% 
      #clearMarkers() %>%
      clearGroup("routing") %>%
      routing(strt = input$start, dstn = input$destination, c = c)
  })
  
  output$tableLive <- DT::renderDataTable({live})
  
  output$tableStations <- DT::renderDataTable({stations})
  
  #output$tableLive <- DT::renderDataTable({s})
  
  output$tableCrime <- DT::renderDataTable({crime})
  
})
