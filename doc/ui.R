ui <- 
  dashboardPage(skin = "black",
    dashboardHeader(title = "Citi Bike Maps"),
    dashboardSidebar(
        sidebarMenu(
          menuItem("Maps",tabName = "tMaps",icon = icon("globe")),

          menuItem("Usage Skyline",tabName= "histogram",icon = icon("stats", lib = "glyphicon")),
                             
          menuItem("Data",
                   icon = icon("table"),
                   menuSubItem("live stations", tabName = "tLive"),
                   # menuSubItem("stations",tabName = "tStations"),
                   menuSubItem("crime 2018", tabName = "tCrime")),
          
          menuItem("About",tabName= "tAbout",icon = icon("envelope"))
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
                              draggable = TRUE, cursor = "move", top = "auto", left = "auto", right = 20, bottom = 20,
                              width = 380, height = 280,
                              wellPanel(
                                 h3("Citi Bike Route"),
                                
                                 textInput("start", "Your Starting Point", value = NA, width = NULL, placeholder = NULL),
                                 
                                 textInput("destination", "Your Destination", value = NA, width = NULL, placeholder = NULL),
                                 
                                 actionButton("go","Go!",icon = icon("refresh"))
                              )
                              )
                ),
        
        tabItem(tabName = "tLive",
                h4("Citybikenyc.com: "),
                h4("https://www.citibikenyc.com/system-data"),
                h4("FileURL: "),
                h4("https://gbfs.citibikenyc.com/gbfs/en/station_status.json"),
                fluidRow(column(12,DT::dataTableOutput("tableLive")))
                ),
       
        #  tabItem(tabName = "tStations",
        #         h4("Citybikenyc.com: "),
        #         h4("https://www.citibikenyc.com/system-data"),
        #         h4("FileURL: "),
        #         h4("https://gbfs.citibikenyc.com/gbfs/en/station_information.json")
        # ),
       
         tabItem(tabName = "tCrime",
                fluidRow(column(12, DT::dataTableOutput("tableCrime")))
        ),
        
        tabItem("tAbout",
                h2("About Our App"),
                 img(src="group.jpg",height='600',width='430'),
                h4("Our web app aims at optimizing decision making with regards to the usage of Citi Bike in New York.
                   First, a routing utility is available, that allows users to enter their current location and a destination
                   and be guided as to where to walk to the closest Citi Bike non-empty station and where to drop off at the
                   non-full station closest to destination. Additionally, bike station availability, bike routes, the rain radar,
                   the 3-D histogram representing the frequency of bike usage and the heat map corrspoinding with crime rate on the
                   streets are available to allow users to further refine the routing."),
                h5("  "),
                h2("Contact Us"),
                h4("We are group 1!"),
                h5("Gabriel Benedict: gb2661@columbia.edu"),
                h5("Hongyu Ji: hj2475@columbia.edu"),
                h5("Yunfan Li: yl3838@columbia.edu"),
                h5("Di Lu: dl3152@columbia.edu"),
                h5("Amon Tokoro: at3250@columbia.edu")),
        
        tabItem("histogram", 
                h2("Frequency of bike usage for an average day in 2018"),
                sidebarLayout(
                  
                  sidebarPanel(
                    sliderInput("bins",
                                "day time",
                                min = 1,
                                max = 24,
                                value = 12)
                  ),
                  
                  # Show a plot of the generated distribution
                  mainPanel(width = 12,
                    h3(textOutput("Frequency of bike usage for an average day in 2018")),
                    tags$style(type = "text/css", "#histplot {height: calc(100vh - 80px) !important;}"),
                    rglwidgetOutput("histplot")
                  )
                )
                )
                
        
      )
    ),
    useShinyalert()
  )

