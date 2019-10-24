devtools::install_github("bdilday/GeomMLBStadiums")
library(GeomMLBStadiums)
library(ggplot2)
library(dplyr)

load("pbp2019.rda")

df <- pbp2019[1:100,] %>%
  filter(as.numeric(launch_speed) > 0)

df$hc_x <- as.numeric(df$hc_x)
df$hc_y <- as.numeric(df$hc_y)

df %>% 
  ggplot(aes(x=hc_x, y=hc_y)) + 
  geom_spraychart() 

df %>% 
  ggplot(aes(x=hc_x, y=hc_y)) + 
  geom_spraychart() + 
  theme_void() + 
  coord_fixed()

df %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x, y=hc_y)) + 
  geom_spraychart(stadium_ids = "mets",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()


df %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = des)) + 
  geom_spraychart(stadium_ids = "mets",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()

