## import libraries
library(tidyverse)
library(ggplot2)
library(usmap)

## set working directory here
setwd("Downloads")

## read csv data
popvote <- read_csv("popvote_1948-2016.csv")
pvstate <- read_csv("popvote_bystate_1948-2016.csv")


## creates data frame for the 2-party popular vote margin in each state in the 2016 election. 
## Positive values indicate Republican-held states; negative values indicate Democratic-held states
pv_margins_map_2016 <- pvstate %>%
  filter(year == 2016) %>%
  mutate(win_margin = (R_pv2p-D_pv2p))

# creates a map with the state abbreviations on it indicating the popular vote margins in each state
plot_usmap(data = pv_margins_map_2016, regions = "states", values = "win_margin", labels = TRUE) +
  scale_fill_gradient2(
    high = "red", 
    #mid = "purple",
    mid = "white",
    low = "blue", 
    breaks = c(-60,-45,-30,-15,0,15,30,45,60), 
    limits = c(-60,60),
    name = "win margin"
  ) +
  theme_void() + 
  labs(title = "Win Margin By State, 2016 US Presidential Election")


## creates data frame for the 2-party popular vote margin in each state for each election since 1980
## the conventions for displaying the data from the last map hold into this as well
pv_margins_map_all <- pvstate %>%
  filter(year >= 1980) %>%
  mutate(win_margin = R_pv2p - D_pv2p)

## creates maps for each election year with the color gradient representing the margin of victory
plot_usmap(data = pv_margins_map_all, regions = "states", values = "win_margin") +
  facet_wrap(facets = year ~.) + ## specify a grid by year
  scale_fill_gradient2(
    high = "red", 
    mid = "white",
    low = "blue", 
    breaks = c(-60,-45,-30,-15,0,15,30,45,60), 
    limits = c(-60,60),
    name = "Popular vote margin by election (pp)"
  ) +
  theme_void() + 
  labs(title = "Win Margin By State for each US Presidential Election")


## create new data frame based on the election over election partisan change, based on the formula 
## (R_pv2p_y - R_pv2p_{y-4}), which is the Republican 2-party popular vote share in year "y" minus the
## Republican 2-party popular vote share in year "y-4", for every election since 1980.
## use pivot_wider/pivot_longer to change shape of data frame and make it easier to use
## https://stackoverflow.com/questions/9617348/reshape-three-column-data-frame-to-matrix-long-to-wide-format
swing_state_diff <- pvstate %>%
  filter(year >= 1980) %>%
  select(state, year, R_pv2p) %>%
  pivot_wider(names_from = year, values_from = R_pv2p) %>%
  mutate(`2012->2016` = (`2016` - `2012`),
         `2008->2012` = (`2012` - `2008`),
         `2004->2008` = (`2008` - `2004`),
         `2000->2004` = (`2004` - `2000`),
         `1996->2000` = (`2000` - `1996`),
         `1992->1996` = (`1996` - `1992`),
         `1988->1992` = (`1992` - `1988`),
         `1984->1988` = (`1988` - `1984`),
         `1980->1984` = (`1984` - `1980`)) %>%
  select(state, `1980->1984`, `1984->1988`, `1988->1992`, `1992->1996`, `1996->2000`, `2000->2004`, `2004->2008`, `2008->2012`, `2012->2016`) %>%
  pivot_longer(cols = c(`1980->1984`, `1984->1988`, `1988->1992`, `1992->1996`, `1996->2000`, `2000->2004`, `2004->2008`, `2008->2012`, `2012->2016`),
               names_to = "year",
               values_to = "diff")

## plot the changes for every state for each election; blue colors mean swing toward Democrat; red means swing toward Republican
plot_usmap(data = swing_state_diff, regions = "states", values = "diff") +
  facet_wrap(facets = year ~.) + 
  scale_fill_gradient2(
    high = "red", 
    mid = "white",
    low = "blue", 
    breaks = c(-20,-15,-10,-5,0,5,10,15,20), 
    limits = c(-20,20),
    name = "Election over election partisan change (pp)"
  ) +
  theme_void() +
  theme(strip.text = element_text(size = 12),
        aspect.ratio=1) + 
  theme(plot.title = element_text(face="bold"))
