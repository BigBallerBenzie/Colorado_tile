library(rayshader)
library(ggplot2)
library(scico)
library(raster)
library(sp)
library(extrafont)
library(rgdal)
library(elevatr)
usa.states <- readOGR(dsn = "cb_2018_us_state_500k.shp")
Colorado <- usa.states[usa.states$NAME == "Colorado", ]

localtif <- get_elev_raster(locations  = Colorado, z = 6, clip = "locations") #Higher Z values = higher res = more tiles

#reduce resolition of raster to makle tiles bigger, play with as needed
localtif_reduced <- aggregate(localtif, fact=10)

#convert to df
df <- as.data.frame(as(localtif_reduced, "SpatialPixelsDataFrame"))
colnames(df) <- c("value", "x","y")

df <- df[which(df$value > 0),]

#plot W/ cool colors from @thomasp85 scico library
p<-ggplot() +
  geom_raster(data=df, aes(x=x, y=y, fill=sqrt(value)), alpha=0.7) +
  scale_fill_scico(palette = 'tokyo', direction = 1, name= "Elevation (meters)\n", labels=scales::comma) +
  coord_quickmap()+
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.background = element_blank(), #element_rect(fill = 'white', colour = 'white'),
        legend.key.width = unit(1.5, "cm"), 
        legend.key.height = unit(.4, "cm"), 
        legend.text = element_blank(), 
        legend.title = element_blank(), 
        line = element_blank(),
        axis.line.x = element_blank(),
        axis.line.y = element_blank(),
        legend.position = "none") 
#take a look
p

#3d plot 
plot_gg(p, width = 4, height = 4, multicore = TRUE, scale = 100, shadow_intensity = 1,
        zoom = 0.4, theta = 5, phi = 30, windowsize = c(2560,1440),  background = "white")
save_3dprint("Colorado.stl", maxwidth = 250, unit = "mm")

render_camera(fov = 60, theta = 0, zoom = 0.50, phi = 40)
#high quality
render_highquality('Colorado_print.png', lightintensity = 650, lightdirection = 0, lightaltitude=65, lightsize = 500)
cat('tweet it to the #rstats $rayshader community')

