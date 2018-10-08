library(shiny)
library(rjson)
#library(leaflet)
#library(here)
#library(rgdal)
library(dplyr)
library(googleway)
#library(RgoogleMaps)

## Data Import

live <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_status.json")
stations <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_information.json")
#load("../output/bikeRoutes.RData")

## data handling

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

# User Input: current location and destination. current, destination
current <- "Columbia University, New York"  # set for illustration
destination <- "Time Square, New York"

# Create pairs of lattitude and longitute for all bike stations
#pairs_all <- mapply(c, s$lat, s$lng, SIMPLIFY = FALSE)
pairs_all <- cbind(s$lat, s$lng)
#pairs_nonzero <- mapply(c, s_nonzero$lat, s_nonzero$lng, SIMPLIFY = FALSE)
pairs_nonzero <- cbind(s_nonzero$lat, s_nonzero$lng)
#pairs_nonfull <- mapply(c, s_nonfull$lat, s_nonfull$lng, SIMPLIFY = FALSE)
pairs_nonfull <- cbind(s_nonfull$lat, s_nonfull$lng)


## Obtain the nearest citi bike station

#current_to_stations <- data.frame()
duration_value_list1 <- c()
duration_value_list2 <- c()

#lapply(pairs[1:10], google_distance, destination = destination, mode = "bicycling")
#getElement(lapply(pairs[1:10], google_distance, destination = destination, mode = "bicycling"), rows)



# nearest pick up bike station from current 
for(i in 1:nrow(s)){
  d1 <- google_distance(origin = current,
                       destination = pairs_nonzero[[i]],
                       mode = "walk")$rows$elements[[1]][1,2]
  duration_value_list1 <- c(duration_value_list1,d1[1,2])
}
nearest_s1 <- which.min(duration_value_list1)


# nearest drop off bike station to destination
for(i in 1:nrow(s)){
  d2 <- google_distance(origin = pairs_all[[i]],
                       destination = destination,
                       mode = "walk")$rows$elements[[1]][1,2]
  duration_value_list2 <- c(duration_value_list2, d2[1,2])
  }
nearest_s2 <- which.min(duration_value_list2)




# route from current to nearest station
r1 <- google_directions(origin = current,
                         destination = pairs_nonzero[[nearest_s1]],
                         mode = "walk")
df_route1 <- data.frame(polyline = r1$routes$overview_polyline$points)
df_route1$lat <- current[1,1]
duration1 <- google_distance(origin = current,
                             destination = pairs_nonzero[[nearest_s1]],
                             mode = "walk")$rows$elements[[1]][1,2][1,1]

# route from start station to end station
r2 <- google_directions(origin = pairs_nonzero[[nearest_s1]],
                         destination = pairs_all[[nearest_s2]],
                         mode = "bicycling")
df_route2 <- data.frame(polyline = r2$routes$overview_polyline$points)
duration2 <- google_distance(origin = pairs_nonzero[[nearest_s1]],
                             destination = pairs_all[[nearest_s2]],
                             mode = "bicycling")$rows$elements[[1]][1,2][1,1]

# route from end station to final destination
r3 <- google_directions(origin = pairs_all[[nearest_s2]],
                        destination = destination,
                        mode = "walk")
df_route3 <- data.frame(polyline = r3$routes$overview_polyline$points)
duration3 <- google_distance(origin = pairs_all[[nearest_s2]],
                             destination = destination,
                             mode = "bicycling")$rows$elements[[1]][1,2][1,1]
#df_route3%>%leaflet()



# Plot map and biking route
google_map(location = current,
           zoom = 10) %>%
  add_polylines(data = df_route1, 
                polyline = "polyline", 
                stroke_colour = "#FF33D6",
                stroke_weight = 7) %>%
  add_polylines(data = df_route2, 
               polyline = "polyline",
               stroke_weight = 7) %>%
  add_polylines(data = df_route3, 
                polyline = "polyline", 
                stroke_colour = "#FF33D6",
                stroke_weight = 7) %>%
  add_traffic()
  add_bicycling()

  #add_markers(data = df_route1,lat = as.character(pairs_all[[nearest_s2]][1]), lon = as.character(pairs_all[[nearest_s2]][2]), marker_icon = pics[2]) 
  #TextOnStaticMap(lat = pairs_nonzero[[nearest_s1]][1], lon = pairs_nonzero[[nearest_s1]][2], labels = duration1, TrueProj = TRUE, FUN = text, add = FALSE)
  
cat("From current location to the nearest citi bike station would take", duration1,".")
cat("Biking would last", duration2, ".")
cat("From the drop off point to the final destination would take", duration3, ".")





############################################################################################3
library(shiny)
library(googleway)
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      textInput("text", label = h2("Current Location"))
      # fluidRow(column(3, verbatimTextOutput("value")))
    ),
    mainPanel(
      google_mapOutput("map")
    )
  )
  )



server <- function(input, output, session){
  api_key <- "your_api_key"
  
  live <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_status.json")
  stations <- fromJSON(file = "https://gbfs.citibikenyc.com/gbfs/en/station_information.json")
  #load("../output/bikeRoutes.RData")
  
  
  ## data handling
  
  l <- length(stations$data$stations)
  
  s <- data.frame(lat = rep(NA, l), lng <- rep(NA, l))
  for(i in 1:l){
    s$lat[i] <- stations$data$stations[i][[1]]$lat
    s$lng[i] <- stations$data$stations[i][[1]]$lon
    s$available[i] <- live$data$stations[i][[1]]$num_bikes_available
  }
  
  # Remove 0 bikes stations
  s_nonzero <- s[-c(which(s$available==0)),]
  
  # User Input: current location and destination. current, destination
  current <- "Columbia University, New York"  # set for illustration
  destination <- "Time Square, New York"
  
  # Create pairs of lattitude and longitute for all bike stations
  pairs_all <- mapply(c, s$lat, s$lng, SIMPLIFY = FALSE)
  pairs_nonzero <- mapply(c, s_nonzero$lat, s_nonzero$lng, SIMPLIFY = FALSE)
  ## Obtain the nearest citi bike station
  
  #current_to_stations <- data.frame()
  #duration_list <- c()
  duration_value_list1 <- c()
  duration_value_list2 <- c()
  
  
  # nearest pick up bike station from current 
  for(i in 1:nrow(s)){
    d1 <- google_distance(origin = current,
                          destination = pairs_nonzero[[i]],
                          mode = "walk")$rows$elements[[1]][1,2]
    duration_value_list1 <- c(duration_value_list1,d1[1,2])
    #duration_value_list1 <- c(duration_value_list, d1[1,2])
  }
  nearest_s1 <- which.min(duration_value_list1)
  
  
  # nearest drop off bike station to destination
  for(i in 1:nrow(s)){
    d2 <- google_distance(origin = pairs_all[[i]],
                          destination = destination,
                          mode = "walk")$rows$elements[[1]][1,2]
    duration_value_list2 <- c(duration_value_list2, d2[1,2])
    #duration_value_list2 <- c()
  }
  nearest_s2 <- which.min(duration_value_list2)
  
  
  
  
  # route from current to nearest station
  r1 <- google_directions(origin = current,
                          destination = pairs_nonzero[[nearest_s1]],
                          mode = "walk")
  df_route1 <- data.frame(polyline = r1$routes$overview_polyline$points)
  df_route1$lat <- current[1,1]
  duration1 <- google_distance(origin = current,
                               destination = pairs_nonzero[[nearest_s1]],
                               mode = "walk")$rows$elements[[1]][1,2][1,1]
  
  # route from start station to end station
  r2 <- google_directions(origin = pairs_nonzero[[nearest_s1]],
                          destination = pairs_all[[nearest_s2]],
                          mode = "bicycling")
  df_route2 <- data.frame(polyline = r2$routes$overview_polyline$points)
  duration2 <- google_distance(origin = pairs_nonzero[[nearest_s1]],
                               destination = pairs_all[[nearest_s2]],
                               mode = "bicycling")$rows$elements[[1]][1,2][1,1]
  
  # route from end station to final destination
  r3 <- google_directions(origin = pairs_all[[nearest_s2]],
                          destination = destination,
                          mode = "walk")
  df_route3 <- data.frame(polyline = r3$routes$overview_polyline$points)
  duration3 <- google_distance(origin = pairs_all[[nearest_s2]],
                               destination = destination,
                               mode = "bicycling")$rows$elements[[1]][1,2][1,1]
  
  output$map <- renderGoogle_map({
    google_map(location = current,
               zoom = 10)%>%
      add_polylines(data = df_route1, 
                    polyline = "polyline", stroke_colour = "#FF33D6",stroke_weight = 7) %>%
      add_polylines(data = df_route2, 
                    polyline = "polyline",stroke_weight = 7) %>%
      add_polylines(data = df_route3, 
                    polyline = "polyline", stroke_colour = "#FF33D6",stroke_weight = 7) %>%
      add_markers(data = df_route1,lat = as.character(pairs_all[[nearest_s2]][1]), lon = as.character(pairs_all[[nearest_s2]][2]), marker_icon = pics[2]) 
  }) }
shinyApp(ui, server)









###############################################################################

## using split view
library(shinydashboard)
library(googleway)
ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(),
  dashboardBody(
    box(width = 6,
        google_mapOutput(outputId = "map")
    )#,
    #box(width = 6,
      #  google_mapOutput(outputId = "pano")
    )
  ) 

ui <-fluidPage(
  
  # Copy the line below to make a text input box
  textInput("text", label = h3(""), value = "Enter text..."),
  
  hr(),
  fluidRow(column(3, verbatimTextOutput("value")))
  
)



server <- function(input, output) {
  set_key(key)
  output$map <- renderGoogle_map({
    res <- google_directions(origin = "Columbia University, New York",
                             destination = "Time Square, New York",
                             mode = "bicycling")
    df_route <- data.frame(polyline = res$routes$overview_polyline$points)
    google_map(location = c(-37.817386, 144.967463),
               zoom = 10,
               split_view = "pano")%>%
      #add_bicycling()%>%
      add_polylines(data = df_route, 
                    polyline = "polyline"
                    #stroke_colour = "#FF33D6",
                    #stroke_weight = 7,
                    #stroke_opacity = 0.7,
                    #info_window = "New route",
                    #load_interval = 100
      )
    
    
    #google_map_directions(origin = "Melbourne Cricket Ground",
    #destination = "Flinders Street Station",
    #dir_action = "navigate")
    #google_directions(origin = "Flinders Street Station, Melbourne",
    #                 destination = "MCG, Melbourne",
    #               mode = "walking")
  }) }
shinyApp(ui, server)
## End(Not run)
















###############################################################################
