## Needs updating to sf
set.seed(42)
library(sp)
library(rgdal)
library(dplyr)

crds <- read.csv("./data/HMA_glacier_mass-balance_090221.csv", 
                 na.strings = "nan")

crds <- crds %>%
  sample_n(nrow(crds))

x <- crds$x
y <- crds$y

coordinates(crds) <- ~x+y
proj4string(crds) <- CRS("+proj=aea +lat_1=25 +lat_2=47 +lat_0=36 +lon_0=85 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")

crds_wgs <- spTransform(crds, CRS("+init=epsg:4326"))
plot(crds_wgs)

crds_wgs$east <- x
crds_wgs$north <- y

writeOGR(crds_wgs, "./data/glacier.shp", 
         layer = "glacier", 
         driver = "ESRI Shapefile",
         overwrite_layer = TRUE)
