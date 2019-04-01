library(sp)

proj_str <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

spdf_test_grid <- SpatialPointsDataFrame(
    coords = test_grid[, c("longitude", "latitude")], data = test_grid, 
    proj4string = CRS(proj_str))

la_county <-  map_data("county") %>% 
    filter(region == 'california', subregion == 'los angeles')

spla <- SpatialPoints(coords = la_county[, c("long", "lat")], 
                      proj4string = CRS(proj_str))

spdf_test_grid_in_la <- spdf_test_grid[!is.na(over(spdf_test_grid, spla)), ]
test_grid_in_la <- as.data.frame( spdf_test_grid_in_la)
