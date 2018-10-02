#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(
  
  dashboardPage(
    dashboardHeader(),
    dashboardSidebar(),
    dashboardBody(
      tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
      leafletOutput("map")
    )
  )
#   
#   
#   fluidPage(
#   
#   # Application title
#   titlePanel("NY city bikes"),
#   
#   # # Sidebar with a slider input for number of bins 
#   # sidebarLayout(
#   #   sidebarPanel(
#   #      sliderInput("bins",
#   #                  "Number of bins:",
#   #                  min = 1,
#   #                  max = 50,
#   #                  value = 30)
#   #   ),
#   #   
#   #   # Show a plot of the generated distribution
#   mainPanel(
#     tags$style(type = "text/css", 
#                "#map {position: absolute;
# width: 100%;
# height: 100%;
# overflow: hidden !important;}"),
#     # js <- '$("#map").height($(window).height()).width($(window).width()); map.invalidateSize();',
#     # div(tags$head(tags$script(HTML(js)))),
#     leafletOutput("map")
#     )
#   )
)
# )
