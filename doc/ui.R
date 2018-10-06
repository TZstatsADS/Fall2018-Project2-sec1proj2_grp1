library(shiny)
library(shinydashboard)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(
  dashboardPage(
    dashboardHeader(title = "City Bike Maps"),
    dashboardSidebar(
      sidebarMenu(
  
        menuItem("Maps", tabName = "tMaps",
                 menuItem("City Bike Map", tabName = "tCity"),
                 menuItem("Crime Map", tabName = "tCrime")),
        
        menuItem("Data", tabName = "tData"),
       
        menuItem("Contact us", tabName = "tContact")
      )
    ),
    dashboardBody(
      
      tabItem(tabName = "tCity",
              h2("City Bike Station and routing Maps with weather rador"),

              h4("Type in your location and destination."),

              leafletOutput("map")
              ),

      # tabItem(tabName = "tCrime",
      #         h2("Crime Maps"),
      #         
      #         h3(""),
      #         
      #         h4("Show you areas where crime occurs."),)
      # 
      # 
      # 
      # tabItem(tabName = "tContact",
      #                        
      #                        h2("Contact Us"),
      #                        
      #                        h3( "We are Group 1!"),
      #                        
      #                        h5("Gabriel Benedict: gb2661@columbia.edu"),
      #                        h5("Hongyu Ji: hj2475@columbia.edu"),
      #                        h5("Yunfan Li: yl3838@columbia.edu"),
      #                        h5("Di Lu: dl3152@columbia.edu"),
      #                        h5("Amon Tokoro: at3250@columbia.edu")
      #                        
      #                ),
      
      tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
      #leafletOutput("map")
      leafletOutput("map2")
    )
  )
)

