library(sf)
library(raster)
library(ggpubr)

glac_sf <- st_read("./data/glacier.shp")

t2m <- stack('~/Dropbox/Data/summer/era5/t2m_2001_2020_amjjas.nc', varname = 't2m')
glac_t2m <- extract(t2m, glac_sf)
glac_t2m <- glac_t2m - 273.15

tp <- stack('~/Dropbox/Data/summer/era5/tp_2001_2020_ann.nc', varname = 'tp')
glac_tp <- extract(tp, glac_sf)
glac_tp <- glac_tp * 24*60*60

glac_sf$t2m_08 <- apply(glac_t2m[, 6:10], 1, mean)
glac_sf$t2m_18 <- apply(glac_t2m[, 16:20], 1, mean)
glac_sf$t2m_d <- glac_sf$t2m_18 - glac_sf$t2m_08

glac_sf$tp_08 <- apply(glac_tp[, 6:10], 1, mean)
glac_sf$tp_18 <- apply(glac_tp[, 16:20], 1, mean)
glac_sf$tp_d <- glac_sf$tp_18 - glac_sf$tp_08

## Summer precip
tpjja <- stack('~/Dropbox/Data/summer/era5/tp_2001_2020_jja.nc', varname = 'tp')
glac_tpjja <- extract(tpjja, glac_sf)
glac_tpjja <- glac_tpjja * 24*60*60
glac_sf$tpjja_08 <- apply(glac_tpjja[, 6:10], 1, mean)
glac_sf$tpjja_18 <- apply(glac_tpjja[, 16:20], 1, mean)

## Seasonality
glac_sf$tpseas_08 <- glac_sf$tpjja_08 / glac_sf$tp_08
glac_sf$tpseas_18 <- glac_sf$tpjja_18 / glac_sf$tp_18
glac_sf$tpseas_d <- glac_sf$tpseas_18 - glac_sf$tpseas_08

seas_df <- data.frame(tp_seas = c(glac_sf$tpseas_08, glac_sf$tpseas_18),
                      time = rep(c("2008", "2018"), each = nrow(glac_sf)))

h1 <- gghistogram(seas_df, x = "tp_seas", facet.by = "time")
ggsave("tp_seas.pdf", h1)

glac_sf$area_km2 <- glac_sf$area_m2 / 1e6

st_write(glac_sf, "./data/glacier_clim.shp", append = FALSE)

glac_sf$z_aspct_sin <- sin(glac_sf$z_aspct * pi / 180)
glac_sf$z_aspct_cos <- cos(glac_sf$z_aspct * pi / 180)
glac_sf$z_aspct_dev <- (abs(glac_sf$z_aspct - 180) * -1) + 180

cor(glac_sf$z_aspct_dev, glac_sf$mb_mwea)


## Time series plots
tmp <- crop(t2m, st_bbox(glac_sf))
t2m_ts <- data.frame(t2m = as.numeric(cellStats(tmp, mean)), 
                     year = 2001:2020)

tmp <- crop(tp, st_bbox(glac_sf))
tp_ts <- data.frame(tp = as.numeric(cellStats(tmp, mean)), 
                     year = 2001:2020)
library(ggpubr)
p1 <- ggline(t2m_ts, x = "year", y = "t2m",
             main = "2m Air Temperature (AMJJAS)", ylab = "K") +
  geom_smooth(method = "lm", se = FALSE)
p2 <- ggline(tp_ts, x = "year", y = "tp",
             main = "Total precipitation", ylab = "kg m-2 s-1") +
  geom_smooth(method = "lm", se = FALSE)

ggsave("era5_2001_2020.pdf", ggarrange(p1, p2, nrow = 2))
