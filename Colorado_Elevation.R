options(rgl.useNULL = FALSE)
library(ggplot2)
library(whitebox)
library(rayshader)
library(rayrender)
library(raster)
library(spatstat)
library(spatstat.utils)
library(suncalc)
library(sp)
library(lubridate)
library(rgdal)
memory.limit(size = 10000000)

usa.states <- readOGR(dsn = "cb_2018_us_state_500k.shp")
Colorado <- usa.states[usa.states$NAME == "Colorado", ]

localtif <- get_elev_raster(locations  = Colorado, z = 6, clip = "locations") #Higher Z values = higher res = more tiles


jezero_mat = raster_to_matrix(localtif)

jezero_mat[1:10,1:10]

jezero_mat %>%
  sphere_shade(texture = "desert") %>%
  add_shadow(ray_shade(jezero_mat, sunaltitude = 3, zscale = 33, lambert = FALSE), max_darken = 0.5) %>%
  add_shadow(lamb_shade(jezero_mat, sunaltitude = 3, zscale = 33), max_darken = 0.7) %>%
  #add_shadow(max_darken = 0.1) 
  
plot_3d(jezero_mat, zscale = 30, windowsize = c(2560,1440), background = "grey30", shadowcolor = "grey5")
save_3dprint("Colorado.stl", maxwidth = 250, unit = "mm")
render_camera(fov = 10, theta = 20, zoom = 0.60, phi = 40)

render_scalebar(limits=c(0, 5, 10),label_unit = "km",position = "W", y=50,
                scale_length = c(0.33,1))
render_compass(position = "E")
render_snapshot(clear=FALSE)
render_movie(filename = "jezero_landing.mp4", type = "orbit",
             phi = 40,theta = 0,frames = 1440, fps = 60)

phivechalf = 30 + 60 * 1/(1 + exp(seq(-7, 20, length.out = 180)/2))
phivecfull = c(rep("88.2", 30), phivechalf, rev(phivechalf))
thetavec = c(rep("0", 30), 0 + 60 * sin(seq(0,359,length.out = 360) * pi/180))
zoomvec = 0.25 + 0.4 * 1/(1 + exp(seq(-5, 20, length.out = 180)))
zoomvecfull = c(rep("0.65", 30),zoomvec, rev(zoomvec))

rayshader::render_movie(filename="MP4c",
                        type='custom',
                        frames = 390,
                        phi = phivecfull, 
                        zoom = zoomvecfull, 
                        theta = thetavec
)

render_highquality()