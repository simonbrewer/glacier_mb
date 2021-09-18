library(dplyr)
library(sf)
library(spdep)
library(INLA)

## Create INLA graph

dat_sf <- st_read("./data/glacier.shp")
# dat_sf <- dat_sf[sample(1:nrow(dat_sf), 5000), ]

dat <- dat_sf %>%
  st_drop_geometry() 
# %>%
#   sample_n(nrow(dat_sf))

# crds <- st_coordinates(dat)
coords <- cbind(dat$east / 1000,
             dat$north / 1000)

system.time(nb_gabriel <- gabrielneigh(coords))
nb <- graph2nb(nb_gabriel, sym = TRUE)

# system.time(nb_knn <- col.knn <- knearneigh(coords, k=4))
# nb <- knn2nb(col.knn, sym = TRUE)

nb2INLA("map.adj", nb)

