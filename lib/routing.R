library(mapsapi)
source("../lib/calculateDistance.R")

time_to_text = function(t){
  ret = ""
  h = t %/% 3600
  if (h > 0){
    ret = paste(ret, " ", h, " hour", sep = "")
    t = t %% 3600
  }
  m = t %/% 60
  if (m > 0){
    ret = paste(ret, " ", m, " min", sep = "")
  }
  return(paste(ret, " ", t %% 60, " sec", sep = ""))
}

routing <- function(map, strt, dstn, c, key="AIzaSyD1wa1olHRXPNPo7_6zEyZvU2xSZxGEMAM"){
  # Retrieve the coordinates of starting point and destination.
  pnt_doc = mp_geocode(addresses = c(strt, dstn), region = "New York, NY", key = key)
  pnt = mp_get_points(pnt_doc)
  strt_coor = as.vector(as(pnt$pnt[1], "Spatial")@coords)  # (lon, lat)
  dstn_coor = as.vector(as(pnt$pnt[2], "Spatial")@coords)  # (lon, lat)
  
  # Calculate the distance and get the closest available pickup & dropoff stations.
  pickup = calculateDistance(strt_coor[c(2, 1)], c = c, mode = "pickup")
  dropoff = calculateDistance(dstn_coor[c(2, 1)], c = c, mode = "dropoff")
  
  # Send Request to the server and retrieve the route.
  # Pickup route. Original xml doc.
  p_doc = mp_directions(
    origin = strt_coor,
    destination = pickup,
    mode = "walking",
    alternatives = FALSE,
    key = key
  )
  # sf object.
  p_r = mp_get_segments(p_doc)
  
  # Pickup to dropoff route.
  pd_doc = mp_directions(
    origin = pickup,
    destination = dropoff,
    mode = "bicycling",
    alternatives = TRUE,
    key = key
  )
  pd_r = mp_get_segments(pd_doc)
  
  # Dropoff to destination.
  d_doc = mp_directions(
    origin = dropoff,
    destination = dstn_coor,
    mode = "walking",
    alternatives = FALSE,
    key = key
  )
  d_r = mp_get_segments(d_doc)
  
  # Calculate time.
  time_bike = time_to_text(
    tapply(pd_r$duration_s, pd_r$alternative_id, sum)
    )
  time_walk = time_to_text(
    p_r$duration_s + d_r$duration_s
    )
  
  # Add route to the map.
  pal_pickup = colorFactor(palette = "Dark2", domain = p_r$alternative_id)
  pal_bicycling = colorFactor(palette = "Dark2", domain = pd_r$alternative_id)
  pal_dropoff = colorFactor(palette = "Dark2", domain = d_r$alternative_id)
  bicon = makeIcon(iconUrl = "../data/bicycle.svg", iconWidth = 30, iconHeight = 30)
  seIcons <- iconList(
    s = makeIcon("../data/start.svg", 30, 30),
    e = makeIcon("../data/end.svg", 30, 30)
  )
  map = map %>% 
    addPolylines(data = p_r, opacity = 1, weight = 5, 
                 color = ~pal_pickup(alternative_id), popup = ~instructions, dashArray = "9", group = "routing") %>%
    addPolylines(data = pd_r, opacity = 1, weight = 5, 
                 color = ~pal_bicycling(alternative_id), popup = ~instructions, group = "routing") %>%
    addPolylines(data = d_r, opacity = 1, weight = 5, 
                 color = ~pal_dropoff(alternative_id), popup = ~instructions, dashArray = "9", group = "routing") %>%
    addMarkers(data = pnt, popup = ~address_google, icon = ~seIcons[id], group = "routing") %>%
    addMarkers(lng = c(pickup[1], dropoff[1]), lat = c(pickup[2], dropoff[2]), 
               popup = c("Pickup your citibike here!", "Dropoff your citibike here!"), icon = bicon, group = "routing") %>%
    #addMarkers(data = pnt$pnt[2], 
    #  label = paste("Walking time:", time_walk,
    #                "Bicycling time:", time_bike),
    #  labelOptions = labelOptions(noHide = T, direction = "bottom"), group = "routing"
    #  )
    addPopups(data = pnt$pnt[2],
              popup = paste("Walking time:", time_walk,
                            "Bicycling time:", time_bike),
              options = popupOptions(noHide = TRUE, direction = "bottom"))
  return(map)
}
