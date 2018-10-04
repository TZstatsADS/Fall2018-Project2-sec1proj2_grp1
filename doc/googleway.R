
## using split view
library(shinydashboard)
library(googleway)
ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(),
  dashboardBody(
    box(width = 6,
        google_mapOutput(outputId = "map")
    ),
    box(width = 6,
        google_mapOutput(outputId = "pano")
    )
  ) )
server <- function(input, output) {
  set_key(key)
  output$map <- renderGoogle_map({
    res <- google_directions(origin = "Flinders Street Station, Melbourne",
                             destination = "MCG, Melbourne",
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


<<<<<<< HEAD
=======
## required time
>>>>>>> 61cdf671b2f0b53a8df53bf4329e66e550797b9c
google_distance(origin = "Columbia University, New York",
                  destination = "Time Square, New York",
                  mode = "bicycling")
