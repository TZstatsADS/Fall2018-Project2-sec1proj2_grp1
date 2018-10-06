library(shiny)
library(shinydashboard)
library(leaflet)
library(DT)

ui <- dashboardPage(
  dashboardHeader(title = "City Bike Maps"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Maps",tabName = "tMaps"),
               
      menuItem("Data",
               menuSubItem("live", tabName = "tLive"),
               menuSubItem("stations",tabName = "tStations"),
               menuSubItem("crime", tabName = "tCrime")),
      menuItem("Contact Us",tabName= "tContact")
    
    )
  ),
  dashboardBody(
    tabItems(
      tabItem("tMaps",
              h2("City Bike Maps with Weather Rador"),
              h4("Type in your location and destination."),
              leafletOutput("map")),
      tabItem(tabName = "tLive",
              h3("URL: https://gbfs.citibikenyc.com/gbfs/en/station_status.json")
              ),
      tabItem(tabName = "tStations",
              h3("URL: https://gbfs.citibikenyc.com/gbfs/en/station_information.json")
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
              h5("Amon Tokoro: at3250@columbia.edu"))
    )
  )
)

