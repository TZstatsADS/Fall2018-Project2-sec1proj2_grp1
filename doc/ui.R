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
)
