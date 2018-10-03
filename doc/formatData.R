routes <- readOGR(dsn = "../data/nyc-bike-routes", layer = "nyc_bike_routes_20170707")
routes <- spTransform(routes, CRS("+proj=longlat +datum=WGS84 +no_defs"))
save(routes, file = "../output/bikeRoutes.RData")


# library(rmapshaper)
# 
# object.size(routes)
# simplified <- rmapshaper::ms_simplify(routes)
# object.size(simplified)
