library(sf)
library(stars)
library(ggpubr)

glac_sf <- st_read("./data/glacier.shp")
harr_projstr <- "+proj=lcc +lon_0=83.0 +lat_0=32.0 +lat_1=32.0 +lat_2=38.0 +datum=WGS84 +no_defs"

## T2
t2_amjjas_2008 <- read_stars("~/Dropbox/Data/summer/harr/output/t2_2008_amjjas.nc")
st_crs(t2_amjjas_2008) <- harr_projstr
names(t2_amjjas_2008) <- "t2_amjjas_2008"

t2_amjjas_2018 <- read_stars("~/Dropbox/Data/summer/harr/output/t2_2018_amjjas.nc")
st_crs(t2_amjjas_2018) <- harr_projstr
names(t2_amjjas_2018) <- "t2_amjjas_2018"

t2_amjjas_delta <- t2_amjjas_2018 - t2_amjjas_2008
names(t2_amjjas_delta) <- "t2_amjjas_delta"

t2_amjjas_trend <- read_stars("~/Dropbox/Data/summer/harr/output/t2_b_amjjas.nc")
st_crs(t2_amjjas_trend) <- harr_projstr
names(t2_amjjas_trend) <- "t2_amjjas_trend"

## PRCP
prcp_ann_2008 <- read_stars("~/Dropbox/Data/summer/harr/output/prcp_2008_ann.nc")
st_crs(prcp_ann_2008) <- harr_projstr
names(prcp_ann_2008) <- "prcp_ann_2008"

prcp_ann_2018 <- read_stars("~/Dropbox/Data/summer/harr/output/prcp_2018_ann.nc")
st_crs(prcp_ann_2018) <- harr_projstr
names(prcp_ann_2018) <- "prcp_ann_2018"

prcp_seas_2008 <- read_stars("~/Dropbox/Data/summer/harr/output/prcp_2008_seas.nc")
st_crs(prcp_seas_2008) <- harr_projstr
names(prcp_seas_2008) <- "prcp_seas_2008"

prcp_seas_2018 <- read_stars("~/Dropbox/Data/summer/harr/output/prcp_2018_seas.nc")
st_crs(prcp_seas_2018) <- harr_projstr
names(prcp_seas_2018) <- "prcp_seas_2018"

prcp_ann_delta <- prcp_ann_2018 - prcp_ann_2008
names(prcp_ann_delta) <- "prcp_ann_delta"

prcp_seas_delta <- prcp_seas_2018 - prcp_seas_2008
names(prcp_seas_delta) <- "prcp_seas_delta"

## Make 
glac_sf2 <- st_transform(glac_sf, st_crs(t2_amjjas_2008))

## T2
glac_sf$t2_w_08 <- 
  as.vector(st_extract(t2_amjjas_2008, glac_sf2)$t2_amjjas_2008)
glac_sf$t2_w_18 <- 
  as.vector(st_extract(t2_amjjas_2018, glac_sf2)$t2_amjjas_2018)
glac_sf$t2_w_d <- 
  as.vector(st_extract(t2_amjjas_delta, glac_sf2)$t2_amjjas_delta)
glac_sf$t2_w_b <- 
  as.vector(st_extract(t2_amjjas_trend, glac_sf2)$t2_amjjas_trend)

## PRCP
glac_sf$ppt_a_08 <- 
  as.vector(st_extract(prcp_ann_2008, glac_sf2)$prcp_ann_2008)
glac_sf$ppt_a_18 <- 
  as.vector(st_extract(prcp_ann_2018, glac_sf2)$prcp_ann_2018)
glac_sf$ppt_s_08 <- 
  as.vector(st_extract(prcp_seas_2008, glac_sf2)$prcp_seas_2008)
glac_sf$ppt_s_18 <- 
  as.vector(st_extract(prcp_seas_2018, glac_sf2)$prcp_seas_2018)
glac_sf$ppt_a_d <- 
  as.vector(st_extract(prcp_ann_delta, glac_sf2)$prcp_ann_delta)
glac_sf$ppt_s_d <- 
  as.vector(st_extract(prcp_seas_delta, glac_sf2)$prcp_seas_delta)

## summary
summary(glac_sf)

st_write(glac_sf, "./data/glacier_clim.shp", append = FALSE)

## Quick map check
library(tmap)

tm_shape(t2_amjjas_2008) +
  tm_raster() +
  tm_shape(glac_sf2) +
  tm_symbols("mb_mwea")

tm_shape(prcp_ann_2008) +
  tm_raster(style = "quantile") +
  tm_shape(glac_sf2) +
  tm_symbols("mb_mwea")
