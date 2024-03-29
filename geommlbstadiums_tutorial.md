Visualization with GeomMLBStadiums Tutorial
================
Luke Beasley and Chris Russo

The GeomMLBStadiums package was created by Ben Dilday and is available via <https://github.com/bdilday/GeomMLBStadiums>. We present ways to work with this package and Statcast data gathered from <https://baseballsavant.mlb.com/statcast_search>.

First, install the package and load it, along with dplyr for data manipulation and ggplot2 for plotting.

``` r
if(!require(devtools)){
  install.packages("devtools")
}
devtools::install_github("bdilday/GeomMLBStadiums")
```

``` r
library(GeomMLBStadiums)
library(ggplot2)
library(dplyr)
```

Next, load the data. We will use 2019 regular season data, but any subset of Statcast data will work.

``` r
load("pbp2019.rda")
```

Some data management is needed to prepare for plotting:

``` r
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
```

Now, we are ready to graph the spray charts. Analyses could be done with as many player data points as wanted, but the graph would be cluttered, so we will start with one player's home data. We split into home and away because we are going to look at stadiums separately. Each batter's playerID can be found on his MLB.com page. We will start with Pete Alonso (ID = 624413).

``` r
# select Pete Alonso batted balls
# separate home and away

alonso_home <- pbp2019 %>%
  filter(batter == 624413,
         home_team == "NYM",
         launch_speed > 0)

alonso_away <- pbp2019 %>%
  filter(batter == 624413,
         home_team != "NYM",
         launch_speed > 0)
```

To see Alonso's home spray chart, we use his home stadium by specifying "mets" as the only stadium id.

``` r
alonso_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_)) + 
  geom_spraychart(stadium_ids = "mets",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()
```

![](geommlbstadiums_tutorial_files/figure-markdown_github/unnamed-chunk-6-1.png)

For road data, we include all ballparks he has played in other than Citi Field, and facet on the team variable.

``` r
alonso_away %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_)) + 
  geom_spraychart(stadium_ids = unique(alonso_away$team),
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed() +
  facet_wrap(~team)
```

![](geommlbstadiums_tutorial_files/figure-markdown_github/unnamed-chunk-7-1.png)

Once the foundation of plotting the hit locations on the stadium has been laid, we can move on to a variety of interesting uses. A few examples we will walk through include labelling by batted ball type (bb\_type), comparing how different pitch types are scattered, analyzing how a certain player performs across different stadiums, and determining the effect of a home team's stadium. Finally, we will pose some questions that you can work on for yourself.

Next, consider 2018 NL MVP Christian Yelich (ID = 592885).

``` r
# select Christian Yelich batted balls home
yelich_home <- pbp2019 %>%
  filter(batter == 592885,
         home_team == "MIL",
         launch_speed > 0)
```

We will use yelich\_home just as before, but change the labelling (color) to bb\_type. From this chart, we can see any trends that emerge. For example, it appears Yelich hits line drives to all parts of the field, but tends to hit more ground balls to the right side of the field and more fly balls to the left side of the field.

``` r
yelich_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = bb_type )) + 
  geom_spraychart(stadium_ids = "brewers",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()
```

![](geommlbstadiums_tutorial_files/figure-markdown_github/unnamed-chunk-9-1.png)

We can run a similar analysis labelling on pitch types as below.

``` r
yelich_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = pitch_type )) + 
  geom_spraychart(stadium_ids = "brewers",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()
```

![](geommlbstadiums_tutorial_files/figure-markdown_github/unnamed-chunk-10-1.png)

However, we can also run this analysis labelling by bb\_type but faceting on pitch types to see if Yelich tends to do better against certain pitches.

``` r
yelich_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = bb_type )) + 
  geom_spraychart(stadium_ids = "brewers",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()+
  facet_wrap(~pitch_type)
```

![](geommlbstadiums_tutorial_files/figure-markdown_github/unnamed-chunk-11-1.png)

Next, let's see how Mike Trout (ID = 545361) hits across different stadiums. We could look across all 29 other stadiums, but for ease of viewing we will examine the other teams in the AL West (Astros, Athletics, Rangers, Mariners).

``` r
# select Mike Trout batted balls against division rivals
trout_away_division <- pbp2019 %>%
  filter(batter == 545361,
         home_team == c("HOU","OAK","TEX","SEA"),
         launch_speed > 0)
```

Now we will plot Trout's batting against each of these rivals at their respective stadiums. We can go back to look at batted ball event if we'd like, but for now we will keep labelling by batted ball type.

``` r
trout_away_division %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = bb_type )) + 
  geom_spraychart(stadium_ids = c("astros", "athletics", "rangers", "mariners"),
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()+
  facet_wrap(~team)
```

![](geommlbstadiums_tutorial_files/figure-markdown_github/unnamed-chunk-13-1.png)

A big storyline in baseball this year was the homerun race between the New York Yankees and the Minnesota Twins. However, most fans would acknowledge that Yankees stadium is notorious for having short fences. Therefore, we wanted to compare the Yankees home spray chart against the Minnesota Twins ballpark to see how many home runs they would have lost. Additionally, we can compare the Twins home data to Yankee stadium to see how many home runs they would have gained.

``` r
yankees_home <- pbp2019 %>%
  filter(home_team == "NYY",
         launch_speed > 0)
```

Showing Yankees data at their own stadium (reality):

``` r
yankees_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = events )) + 
  geom_spraychart(stadium_ids = "yankees",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()
```

![](geommlbstadiums_tutorial_files/figure-markdown_github/unnamed-chunk-15-1.png)

Now showing yankees\_home data as if they played at the Twins ballpark.

``` r
yankees_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = events )) + 
  geom_spraychart(stadium_ids = "twins",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()
```

![](geommlbstadiums_tutorial_files/figure-markdown_github/unnamed-chunk-16-1.png)

Interestingly, it appears that the Yankees may have, in fact, had more homeruns if they playerd at the Twins home ball park. After researching each ballparks dimensions, the Twins do have a shorter field in left-center, center, and right-center. However, the Yankees have a much shorter field down each line. Now we will look at the Twins home data and compare to Yankees field.

``` r
twins_home <- pbp2019 %>%
  filter(home_team == "MIN",
         launch_speed > 0)
```

``` r
twins_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = events )) + 
  geom_spraychart(stadium_ids = "twins",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()
```

![](geommlbstadiums_tutorial_files/figure-markdown_github/unnamed-chunk-18-1.png)

One interesting observation is that many balls that appear to be far enough to be home runs are not, therefore it seems the Twins stadium has some high wall that makes true distance needed to hit a home run longer than it appears in these graphs. This observation also affects our previous analysis of Yankees homeruns at the Twins home stadium. Now showing twins\_home data as if they played at the Yankees ballpark.

``` r
twins_home %>% mlbam_xy_transformation() %>%  
  ggplot(aes(x=hc_x_, y=hc_y_, color = events )) + 
  geom_spraychart(stadium_ids = "yankees",
                  stadium_transform_coords = TRUE, 
                  stadium_segments = "all") + 
  theme_void() + 
  coord_fixed()
```

![](geommlbstadiums_tutorial_files/figure-markdown_github/unnamed-chunk-19-1.png)

Overall, it would be hard to confidently conclude that the home stadiums would have changed each team's total home run mark, but this package allows for an intriguing starting point for answering this question.

Some potential questions we will leave up to the reader for exercises:

-   Choose your favorite player and analyze the difference between his home and away spray charts depending on stadium.

-   Choose your favorite team and determine which players utilized all parts of the field most effectively.

-   Determine if certain positions (i.e. shortstops vs first basemen) tend to spray the ball to different parts of the field.

-   Analyze what spraycharts look like against a particular pitcher.

-   Be creative with your own questions and use the package to draw insightful observations.
