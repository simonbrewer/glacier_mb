library(dplyr)
library(sf)
library(spdep)
library(INLA)

## Create INLA graph

dat_sf <- st_read("./data/glacier_clim.shp")
# dat_sf <- dat_sf[sample(1:nrow(dat_sf), 5000), ]

dat <- dat_sf %>%
  st_drop_geometry() %>% 
  dplyr::select(mb_mwea, area_km2, z_min, z_med, z_max, z_aspct, z_slope,
                east, north, tau,
                t2m_18, t2m_d, tp_18, tp_d, tpseas_18, tpseas_d) 
# %>%
#   sample_n(95086)

# crds <- st_coordinates(dat)
coords <- cbind(dat$east / 1000,
             dat$north / 1000)

system.time(nb_gabriel <- gabrielneigh(coords))
nb <- graph2nb(nb_gabriel, sym = TRUE)

# system.time(nb_knn <- col.knn <- knearneigh(coords, k=4))
# nb <- knn2nb(col.knn, sym = TRUE)

nb2INLA("map.adj", nb)

