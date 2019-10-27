devtools::install_github("bdilday/GeomMLBStadiums")
library(GeomMLBStadiums)
library(ggplot2)
library(dplyr)

load("pbp2019.rda")

# convert all null to NA
pbp2019[pbp2019 == "null"] <- NA

# order
pbp2019 <- pbp2019 %>%
  mutate(game_date = as.Date(game_date, "%m/%d/%Y")) %>%
  arrange(game_date, home_team, at_bat_number, pitch_number)

# add indicator for stadium
team_ids <- data.frame(team = unique(MLBStadiumsPathData$team)[-31],
                       abbr = c("LAA","HOU","OAK","TOR","ATL",
                                "MIL","STL","CHC","ARI","LAD",
                                "SF","CLE","SEA","MIA","NYM",
                                "WSH","BAL","SD","PHI","PIT",
                                "TEX","TB","BOS","CIN","COL",
                                "KC","DET","MIN","CWS","NYY"),
                       stringsAsFactors = F)

pbp2019 <- pbp2019 %>%
  left_join(team_ids, by = c("home_team" = "abbr"))

# convert variable types
pbp2019 <- pbp2019 %>%
  mutate(hc_x = as.numeric(hc_x),
         hc_y = as.numeric(hc_y),
         launch_speed = as.numeric(launch_speed))



# select Pete Alonso batted balls home/away
alonso_home <- pbp2019 %>%
  filter(batter == 624413,
         home_team == "NYM",
         launch_speed > 0)

alonso_away <- pbp2019 %>%
  filter(batter == 624413,
         home_team != "NYM",
         launch_speed > 0)

# plot
alonso_home %>% 
  ggplot(aes(x=hc_x, y=hc_y)) + 
  geom_spraychart() 

alonso_home %>% 
  ggplot(aes(x=hc_x, y=hc_y)) + 
  geom_spraychart() + 
  theme_void() + 
  coord_fixed()


alonso_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = events)) + 
  geom_spraychart(stadium_ids = "mets",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()

alonso_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = events)) + 
  geom_spraychart(stadium_ids = "mets",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()

alonso_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = events)) + 
  geom_spraychart(stadium_ids = "mets",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()


alonso_away %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = events)) + 
  geom_spraychart(stadium_ids = unique(alonso_away$team),
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed() +
  facet_wrap(~team)

### new lines
marlins_home <- pbp2019 %>%
  filter(team == 'marlins',
         home_team == "MIA",
         launch_speed > 0)

print(pbp2019)

marlins_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = events)) + 
  geom_spraychart(stadium_ids = "MIA",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed() +
  facet_wrap(~batter)

alonso_marlins <- pbp2019 %>%
  filter(batter == 624413,
         home_team == "MIA",
         launch_speed > 0)

alonso_marlins %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = bb_type )) + 
  geom_spraychart(stadium_ids = "marlins",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()
