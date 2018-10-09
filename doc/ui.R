packages <- c("shiny", 
              "shinydashboard", 
              "leaflet", 
              "DT")

# Install and load packages only if needed
package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = T)) install.packages(x)
  if (! (x %in% (.packages() )))  library(x, character.only = T)
})




ui <- 
  dashboardPage(
    dashboardHeader(title = "City Bike Maps"),
    dashboardSidebar(
        sidebarMenu(
          menuItem("Maps",tabName = "tMaps",icon = icon("globe")),
                   
          menuItem("Data",
                   icon = icon("table"),
                   menuSubItem("live", tabName = "tLive"),
                   menuSubItem("stations",tabName = "tStations"),
                   menuSubItem("crime", tabName = "tCrime")),
          
          menuItem("Contact Us",tabName= "tContact",icon = icon("envelope")),
          
          menuItem("histogram",tabName= "histogram",icon = icon("envelope"))
        )
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName ="tMaps",
                # h2("City Bike Maps with Weather Rador"),
                # h4("Type in your location and destination."),
                tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                leafletOutput("map"), 
                
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                              width = 330, height = "auto",
                              # h3() is the title for the first map.
                              h3("Citi Bike Route"),
                              
                              textInput("start", "Your Starting Point", value = NA, width = NULL, placeholder = NULL),
                              
                              textInput("destination", "Your Destination", value = NA, width = NULL, placeholder = NULL),
                              
                              actionButton("submit","Submit",icon = icon("refresh"))
                              )
                ),
        
        tabItem(tabName = "tLive",
                # h4("Citybikenyc.com: "),
                # h4("https://www.citibikenyc.com/system-data"),
                # h4("FileURL: "),
                # h4("https://gbfs.citibikenyc.com/gbfs/en/station_status.json")
                fluidRow(column(12,DT::dataTableOutput("tableLive")))
                ),
       
         tabItem(tabName = "tStations",
                h4("Citybikenyc.com: "),
                h4("https://www.citibikenyc.com/system-data"),
                h4("FileURL: "),
                h4("https://gbfs.citibikenyc.com/gbfs/en/station_information.json")
        ),
       
         tabItem(tabName = "tCrime",
                fluidRow(column(12, DT::dataTableOutput("tableCrime")))
        ),
        
        tabItem("tContact",
                h2("Contact Us"),
                h4("We are group 1!"),
                h5("Gabriel Benedict: gb2661@columbia.edu"),
                h5("Hongyu Ji: hj2475@columbia.edu"),
                h5("Yunfan Li: yl3838@columbia.edu"),
                h5("Di Lu: dl3152@columbia.edu"),
                h5("Amon Tokoro: at3250@columbia.edu")),
        
        tabItem("histogram", rglwidgetOutput("histplot"))
                
        
      )
    )
  )

