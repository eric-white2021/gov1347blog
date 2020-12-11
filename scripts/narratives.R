library(tidyverse)
library(ggplot2)
library(usmap)
library(geofacet)
library(gridExtra)
library(hash)
library(quanteda)

setwd("Downloads")


pvstate <- read_csv("popvote_bystate_1948-2020.csv")
pvcounty <- read_csv("popvote_bycounty_2000-2016.csv")
pvcounty_2020 <- read_csv("popvote_bycounty_2020.csv")

pvstate_2020 <- pvstate %>% filter(year == 2020)
pvstate_2016 <- pvstate %>% filter(year == 2016)
pvcounty_2016 <- pvcounty %>% filter(year == 2016)
pvcounty_2020 <- pvcounty_2020%>%filter(FIPS != "fips")

pvstate_2020
pvstate_2016


swing <- c("AZ", "GA", "MI", "PA", "WI")

n_last <- 3
pvcounty_2020$state_num <- substr(pvcounty_2020$FIPS, 0, nchar(pvcounty_2020$FIPS) - n_last)

h <- hash(
  "1" = "AL",
  "2" = "AK",
  "4" = "AZ",
  "5" = "AR",
  "6" = "CA",
  "8" = "CO",
  "9" = "CT",
  "10" = "DE",
  "11" = "DC",
  "12" = "FL",
  "13" = "GA",
  "15" = "HI",
  "16" = "ID",
  "17" = "IL",
  "18" = "IN",
  "19" = "IA",
  "20" = "KS",
  "21" = "KY",
  "22" = "LA",
  "23" = "ME",
  "24" = "MD",
  "25" = "MA",
  "26" = "MI",
  "27" = "MN",
  "28" = "MS",
  "29" = "MO",
  "30" = "MT",
  "31" = "NE",
  "32" = "NV",
  "33" = "NH",
  "34" = "NJ",
  "35" = "NM",
  "36" = "NY",
  "37" = "NC",
  "38" = "ND",
  "39" = "OH",
  "40" = "OK",
  "41" = "OR",
  "42" = "PA",
  "44" = "RI",
  "45" = "SC",
  "46" = "SD",
  "47" = "TN",
  "48" = "TX",
  "49" = "UT",
  "50" = "VT",
  "51" = "VA",
  "53" = "WA",
  "54" = "WV",
  "55" = "WI",
  "56" = "WY"
)

pvcounty_2020$state <- pvcounty_2020$`Geographic Subtype`

for (i in 1:length(pvcounty_2020$state_num))
{
  pvcounty_2020$state[i] <- values(h[pvcounty_2020$state_num[i]], USE.NAMES=FALSE)
}

# pvcounty_2020$FIPS <- substr(pvcounty_2020$FIPS, nchar(pvcounty_2020$FIPS) - n_last + 1, nchar(pvcounty_2020$FIPS))


pvcounty_2020 <- pvcounty_2020 %>% 
  rename(county = `Geographic Name`, biden = `Joseph R. Biden Jr.`, trump = `Donald J. Trump`, votes = `Total Vote`, fips = FIPS) %>%
  mutate(D_pv2p = 100*as.numeric(biden)/(as.numeric(biden)+as.numeric(trump)), R_pv2p = 100*as.numeric(trump)/(as.numeric(biden)+as.numeric(trump)), margin = D_pv2p - R_pv2p) %>%
  select(state, county, FIPS, D_pv2p, R_pv2p, margin)


swing_county_2020 <- pvcounty_2020 %>% filter(state%in%swing)
swing_county_2016 <- pvcounty_2016 %>% filter(state_abb%in%swing)


az_2020 <- plot_usmap(data = swing_county_2020 %>% filter(state == swing[1]), regions = "counties", values = "margin", include=swing[1]) + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70), 
    limits = c(-70, 70),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "2020 Margin of Victory (Arizona)")

az_2016 <- plot_usmap(data = swing_county_2016 %>% filter(state_abb == swing[1]), regions = "counties", values = "D_win_margin", include=swing[1]) + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70), 
    limits = c(-70, 70),
    name = "2016 margin"
  ) +
  theme_void() + 
  labs(title = "2016 Margin of Victory (Arizona)")

grid.arrange(az_2020, az_2016, ncol=2)


ga_2020 <- plot_usmap(data = swing_county_2020 %>% filter(state == swing[2]), regions = "counties", values = "margin", include=swing[2]) + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-90, -80, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90), 
    limits = c(-90, 90),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "2020 Margin of Victory (Georgia)")

ga_2016 <- plot_usmap(data = swing_county_2016 %>% filter(state_abb == swing[2]), regions = "counties", values = "D_win_margin", include=swing[2]) + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-90, -80, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90), 
    limits = c(-90, 90),
    name = "2016 margin"
  ) +
  theme_void() + 
  labs(title = "2016 Margin of Victory (Georgia)")

grid.arrange(ga_2020, ga_2016, ncol=2)


mi_2020 <- plot_usmap(data = swing_county_2020 %>% filter(state == swing[3]), regions = "counties", values = "margin", include=swing[3]) + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70), 
    limits = c(-70, 70),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "2020 Margin of Victory (Michigan)")

mi_2016 <- plot_usmap(data = swing_county_2016 %>% filter(state_abb == swing[3]), regions = "counties", values = "D_win_margin", include=swing[3]) + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70), 
    limits = c(-70, 70),
    name = "2016 margin"
  ) +
  theme_void() + 
  labs(title = "2016 Margin of Victory (Michigan)")

grid.arrange(mi_2020, mi_2016, ncol=2)


pa_2020 <- plot_usmap(data = swing_county_2020 %>% filter(state == swing[4]), regions = "counties", values = "margin", include=swing[4]) + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-80, -60, -40, -20, 0, 20, 40, 60, 80), 
    limits = c(-80, 80),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "2020 Margin of Victory (Pennsylvania)")


pa_2016 <- plot_usmap(data = swing_county_2016 %>% filter(state_abb == swing[4]), regions = "counties", values = "D_win_margin", include=swing[4]) + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-80, -60, -40, -20, 0, 20, 40, 60, 80), 
    limits = c(-80, 80),
    name = "2016 margin"
  ) +
  theme_void() + 
  labs(title = "2016 Margin of Victory (Pennsylvania)")

grid.arrange(pa_2020, pa_2016, ncol=2)


wi_2020 <- plot_usmap(data = swing_county_2020 %>% filter(state == swing[5]), regions = "counties", values = "margin", include=swing[5]) + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70), 
    limits = c(-70, 70),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "2020 Margin of Victory (Wisconsin)")


wi_2016 <- plot_usmap(data = swing_county_2016 %>% filter(state_abb == swing[5]), regions = "counties", values = "D_win_margin", include=swing[5]) + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70), 
    limits = c(-70, 70),
    name = "2016 margin"
  ) +
  theme_void() + 
  labs(title = "2016 Margin of Victory (Wisconsin)")

grid.arrange(wi_2020, wi_2016, ncol=2)




counties <- c("Maricopa", "Fulton", "DeKalb", "Wayne", "Philadelphia", "Allegheny", "Milwaukee")

urbancounty_2020 <- pvcounty_2020 %>% filter(county%in%counties & state%in%swing) %>% mutate(fips = as.numeric(fips))
urbancounty_2016 <- pvcounty_2016 %>% filter(county%in%counties & state_abb%in%swing)




joined_urban <- urbancounty_2020 %>% 
  left_join(urbancounty_2016, by=c("fips"="fips")) %>%
  mutate(diff = margin - D_win_margin) %>%
  select(state.x, county.x, fips, margin, D_win_margin, diff)


mean(joined_urban$diff[c(T,T,T,F,T,T,F,T,F,T)])

joined_all <- pvcounty_2020 %>% 
  mutate(fips = as.numeric(fips)) %>%
  left_join(pvcounty_2016, by=c("fips"="fips")) %>%
  mutate(diff = margin - D_win_margin) %>%
  select(state.x, county.x, fips, margin, D_win_margin, diff)

state_avg <- pvcounty_2020 %>% 
  mutate(fips = as.numeric(fips)) %>%
  left_join(pvcounty_2016, by=c("fips"="fips")) %>%
  mutate(diff = margin - D_win_margin) %>%
  group_by(state.x) %>%
  summarize(mean(diff))

state_avg$state.x[state_avg$state.x%in%swing]
state_avg$`mean(diff)`[state_avg$state.x%in%swing]
joined_urban %>% select(state.x, county.x, diff)

mean(joined_all$diff[!is.na(joined_all$diff)])

az_flipped <- joined_all %>% filter(state.x == swing[1] & (margin / D_win_margin) < 0) %>% select(fips)
pvcounty %>% filter(year == 2012 & state_abb == swing[1] & D_win_margin>0 & fips%in%mi_flipped$fips) %>% select(county)

ga_flipped <- joined_all %>% filter(state.x == swing[2] & (margin / D_win_margin) < 0) %>% select(fips)
pvcounty %>% filter(year == 2012 & state_abb == swing[2] & D_win_margin>0 & fips%in%ga_flipped$fips) %>% select(county)

mi_flipped <- joined_all %>% filter(state.x == swing[3] & (margin / D_win_margin) < 0) %>% select(fips)
pvcounty %>% filter(year == 2012 & state_abb == swing[3] & D_win_margin>0 & fips%in%mi_flipped$fips) %>% select(county)

pa_flipped <- joined_all %>% filter(state.x == swing[4] & (margin / D_win_margin) < 0) %>% select(fips)
pvcounty %>% filter(year == 2012 & state_abb == swing[4] & D_win_margin>0 & fips%in%pa_flipped$fips) %>% select(county)

wi_flipped <- joined_all %>% filter(state.x == swing[5] & (margin / D_win_margin) < 0) %>% select(fips)
pvcounty %>% filter(year == 2012 & state_abb == swing[5] & D_win_margin>0 & fips%in%wi_flipped$fips) %>% select(county)
