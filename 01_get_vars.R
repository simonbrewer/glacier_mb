library(sf)
library(raster)

glac_sf <- st_read("../data/glacier.shp")

t2m <- stack('../era5/t2m_2001_2020.nc', varname = 't2m')
glac_t2m <- extract(t2m, glac_sf)
glac_t2m <- glac_t2m - 273.15

tp <- stack('../era5/download.nc', varname = 'tp')
glac_tp <- extract(tp, glac_sf)
glac_tp <- glac_tp * 24*60*60

glac_sf$t2m_08 <- apply(glac_t2m[, 1:12], 1, mean)
glac_sf$t2m_18 <- apply(glac_t2m[, 13:24], 1, mean)
glac_sf$t2m_d <- glac_sf$t2m_18 - glac_sf$t2m_08

glac_sf$tp_08 <- apply(glac_tp[, 1:12], 1, mean)
glac_sf$tp_18 <- apply(glac_tp[, 13:24], 1, mean)
glac_sf$tp_d <- glac_sf$tp_18 - glac_sf$tp_08

glac_sf$area_km2 <- glac_sf$area_m2 / 1e6

st_write(glac_sf, "../data/glacier_clim.shp", update = TRUE)

## Anomaly check
t2m_ann <- stackApply(t2m, rep(c(1,2), each = 12), mean)

t2m_anm <- raster(t2m_ann, 2) - raster(t2m_ann, 1)
plot(t2m_anm)


stop()
x <- stack("../era5/tmp.nc")

y1 <- c(t2m_ann[700, 1])
y2 <- c(x[700, 1])

plot(y1, y2)

yrs <- seq(1, 20)
summary(lm(y1 ~ yrs))
summary(lm(y2 ~ yrs))

bb <- raster("../era5/t2m_b.nc")

bb[700, 1]
t2m_ann <- stackApply(t2m, rep(seq(1,20), each = 12), mean)
