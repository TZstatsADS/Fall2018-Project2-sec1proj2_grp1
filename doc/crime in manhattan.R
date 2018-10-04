crime <- read.csv("~/Desktop/ADS/NYPD.csv")
# Only in Manhattan
crime.m <- subset(crime, crime$BORO_NM=="MANHATTAN")
# Only Felony Crime
crime.m.f <- subset(crime.m, crime.m$LAW_CAT_CD=="FELONY")

library(leaflet)
leaflet(crime.m.f) %>%
  addTiles() %>%
  addCircleMarkers(lng = ~Longitude, lat = ~Latitude, radius = 0.1)

crime.m.f$date <- as.Date(crime.m.f$CMPLNT_FR_DT, format = "%m/%d/%Y")
cc<- subset(crime.m.f, date> "2016-12-31" & date < "2018-12-05")

# Only 2018 
cd<- subset(crime.m.f, date> "2017-12-31" & date < "2018-12-05")

leaflet(cd) %>%
  addTiles() %>%
  addCircleMarkers(lng = ~Longitude, lat = ~Latitude, radius = 0.1)

# Only street crime
c.street <- subset(crime.m.f, crime.m.f$PREM_TYP_DESC=="STREET")

leaflet(c.street) %>%
  addTiles() %>%
  addCircleMarkers(lng = ~Longitude, lat = ~Latitude, radius = 0.1)

crime.m.f$date <- as.Date(crime.m.f$CMPLNT_FR_DT, format = "%m/%d/%Y")
c.street$time <- as.POSIXct(as.character(c.street$CMPLNT_FR_TM), format = "%H:%M")
library(chron)
c.street$time <- chron(times. = as.character(c.street$CMPLNT_FR_TM))

c.street$t <- c.street$time

c.street$t <- as.character(c.street$t)

c.street$t[c.street$time > "6:00:00" & c.street$time <"12:00:00"] <- "morning"
c.street$t[c.street$time >= "12:00:00" & c.street$time <"18:00:00"] <- "afternoon"
c.street$t[c.street$time >= "18:00:00" & c.street$time <"23:59:59"] <- "evening"
c.street$t[c.street$time >= "0:00:00" & c.street$time <="6:00:00"] <- "night"

table(c.street$t)

leaflet(c.street) %>%
  addTiles() %>%
  addLayersControl(overlayGroups = c("Quakes", "Outline"))%>%
  addCircleMarkers(lng = ~Longitude, lat = ~Latitude, radius = 0.1)


c1 <- subset(c.street, c.street$t=="morning")
c2 <- subset(c.street, c.street$t=="afternoon")
c3 <- subset(c.street, c.street$t=="evening")
c4 <- subset(c.street, c.street$t=="night")

leaflet() %>%
  addTiles() %>%
  addLayersControl(overlayGroups = c("morning", "afternoon","evening",'night' ))%>%
  addCircleMarkers(data = c1, lng = ~Longitude, col ="red", lat = ~Latitude, radius = 0.1, group = "morning") %>%
  addCircleMarkers(data = c2, lng = ~Longitude, col = "green",lat = ~Latitude, radius = 0.1, group = "afternoon") %>%
  addCircleMarkers(data = c3, lng = ~Longitude, col = "yellow", lat = ~Latitude, radius = 0.1, group = "evening") %>%
  addCircleMarkers(data = c4, lng = ~Longitude, lat = ~Latitude, radius = 0.1, group = "night")

