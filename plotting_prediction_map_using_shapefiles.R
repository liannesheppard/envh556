library(rgdal)
library(sp)
library(downloader)

# Define URL for shapefile data library top-level folder

data_lib <- 'http://www.dot.ca.gov/hq/tsip/gis/datalibrary/zip'

# Get a shapefile for California state highways

url <- paste(data_lib, "highway/MAY2016_State_Highway_NHS.zip", sep = "/")
shpfile_dir <- "shapefiles"
shpfile_zip <- "MAY2016_State_Highway_NHS.zip"
shpfile <- "MAY2016_State_Highway_NHS"
if (!file.exists(shpfile_zip)) {
    download(url, dest = shpfile_zip, mode="wb")
}
unzip (shpfile_zip, exdir = shpfile_dir)

ca_hwy_shapefile <- readOGR(shpfile_dir, shpfile)
ca_hwy_shapefile_df <- fortify(ca_hwy_shapefile)

# Get map projection string

ca_hwy_proj <- proj4string(ca_hwy_shapefile)

# Get a shapefile for California urban areas

url <- paste(data_lib, "Boundaries/2010_adjusted_urban_area.zip", sep = "/")
shpfile_dir <- "shapefiles"
shpfile_zip <- "2010_adjusted_urban_area.zip"
shpfile <- "2010_adjusted_urban_area"
if (!file.exists(shpfile_zip)) {
    download(url, dest = shpfile_zip, mode="wb")
}
unzip (shpfile_zip, exdir = shpfile_dir)

ca_urb_areas_shapefile <- readOGR(file.path(shpfile_dir, shpfile), shpfile)

# Get map projection string

ca_urb_proj <- proj4string(ca_urb_areas_shapefile)

# Convert LA urban area shapefile data frame to a SpatialPolygon

ca_urb_sp <- ca_urb_areas_shapefile[
    grepl('^Los Angeles', ca_urb_areas_shapefile$NAME10), ]@polygons
ca_urb_sp <- SpatialPolygons(Srl = ca_urb_sp, proj4string = CRS(ca_urb_proj))

# Transform projection of urban areas SpatialPoints object if necessary

if (ca_hwy_proj != ca_urb_proj) {
    spTransform(ca_urb_sp, ca_hwy_proj)
}

# Convert LA urban area SpatialPoints object to a data frame for plotting

ca_urb_df <- fortify(ca_urb_sp)

# Convert highway shapefile data frame to a SpatialPointsDataFrame

ca_hwy_spdf <- ca_hwy_shapefile_df
coordinates(ca_hwy_spdf) <- ~ long + lat
proj4string(ca_hwy_spdf) <- CRS(ca_hwy_proj)

# Subset highways data frame to only include those points in LA for plotting

ca_hwy_spdf_subset <- ca_hwy_spdf[!is.na(over(ca_hwy_spdf, ca_urb_sp)), ]
ca_hwy_df <- as.data.frame(ca_hwy_spdf_subset)

# Plot the LA border (ca_urb_df), LA highways (ca_hwy_df), and predictions

ca_map <- ggplot() +
    geom_path(data = ca_urb_df, 
              aes(x = long, y = lat, group = group),
              color = 'black', size = 0.5) + 
    geom_path(data = ca_hwy_df, 
              aes(x = long, y = lat, group = group),
              color = 'blue', size = 0.4) + 
    stat_contour(aes(x = x, y = y, z = z, fill = ..level..), alpha = 0.05, 
                 data = test_grid_dens_expand, geom = "polygon", bins = 50) + 
    scale_fill_gradient(name = "NOx (ppb)", low = "yellow", high = "red", 
                        breaks = seq(0, 125, 25), limits = c(0, 125)) +  
    ggtitle("Map of Los Angeles \n with fall UK predictions overlaid") + 
    theme_void() + my_theme

map_projected <- ca_map + coord_map()

print(map_projected)
