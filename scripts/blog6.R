## import libraries
library(tidyverse)
library(ggplot2)
library(usmap)
library(geofacet)
library(gridExtra)

## set working directory here
setwd("Downloads")

counties_pa <- read_csv("counties_pa_2010.csv")
pa_election_2012 <- read_csv("pa_election_2012.csv")
pa_election_2016 <- read_csv("pa_election_2016.csv")
turnout <- read_csv("turnout_1980-2016.csv")
pvstate <- read_csv("popvote_bystate_1948-2016.csv")
polls_2020_538 <- read_csv("president_polls.csv")

pa_election_2012$CountyName[pa_election_2012$CountyName == "McKEAN"] = "MCKEAN"
pa_election_2016$CountyName[pa_election_2016$CountyName == "McKEAN"] = "MCKEAN"

pa_2012 <- pa_election_2012 %>%
  mutate(D_pv2p = Dem / (Dem + Rep),
         R_pv2p = Rep / (Dem + Rep),
         margin = D_pv2p - R_pv2p) %>%
  select(CountyName, D_pv2p, R_pv2p, margin)

pa_2016 <- pa_election_2016 %>%
  mutate(D_pv2p = Dem / (Dem + Rep),
         R_pv2p = Rep / (Dem + Rep),
         margin = D_pv2p - R_pv2p) %>%
  select(CountyName, D_pv2p, R_pv2p, margin)

counties_pa <- counties_pa %>% 
  rename(
    fips = `State & County FIPS Code`, 
    CountyName = `Geographic Area`, 
    population = `Total Population`) %>%
  mutate(
    white = `White Alone` / population, 
    black = `Black or African American Alone` / population,
    asian = `Asian Alone` / population, 
    hispanic = `Hispanic or Latino` / population,
    CountyName = toupper(CountyName)) %>%
  select(fips, CountyName, population, white, black, asian, hispanic)


pa_2012$CountyName[pa_2012$CountyName == "Grand Total"] = "PENNSYLVANIA"
pa_2016$CountyName[pa_2016$CountyName == "Grand Total"] = "PENNSYLVANIA"


election_2012 <- counties_pa %>%
  left_join(pa_2012) %>%
  select(fips, CountyName, D_pv2p, R_pv2p, margin, population, white, black, asian, hispanic)

election_2016 <- counties_pa %>%
  left_join(pa_2016) %>%
  select(fips, CountyName, D_pv2p, R_pv2p, margin, population, white, black, asian, hispanic)

max(election_2012$margin[!is.na(election_2012$margin)])

result_2016 <- plot_usmap(data = election_2016, regions = "counties", values = "margin", include = "PA") +
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-.75,-.5,-.25, 0, .25, .5, .75), 
    limits = c(-.75,.75),
    name = "win margin"
  ) +
  theme_void() + 
  labs(title = "Win Margin, 2016 PA Presidential Election")


fit_2016_b <- lm(margin ~ black, data=election_2016)
fit_2016_w <- lm(margin ~ white, data=election_2016)
fit_2012_b <- lm(margin ~ black, data=election_2012)
fit_2012_w <- lm(margin ~ white, data=election_2012)
summary(fit_2016_b)
summary(fit_2012_w)

fit_2016 <- lm(margin ~ black + white + hispanic + asian, data=election_2016)
fit_2012 <- lm(margin ~ black + white + hispanic + asian, data=election_2012)

summary(fit_2016_w)


df <- data.frame(fips = election_2016$fips, pred_2012_b = fit_2012_b$fitted.values, pred_2012_w = fit_2012_w$fitted.values, 
                 pred_2016_b = fit_2016_b$fitted.values, pred_2016_w = fit_2016_w$fitted.values,
                 pred_2012 = fit_2012$fitted.values, pred_2016 = fit_2016$fitted.values,
                 resid_2012_b = fit_2012_b$residuals, resid_2012_w = fit_2012_w$residuals, 
                 resid_2016_b = fit_2016_b$residuals, resid_2016_w = fit_2016_w$residuals,
                 resid_2012 = fit_2012$residuals, resid_2016 = fit_2016$residuals)

pred_2016 <- plot_usmap(data = df, regions = "counties", values = "pred_2016", include = "PA") +
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-1. -.75,-.5,-.25, 0, .25, .5, .75, 1), 
    limits = c(-1,1),
    name = "win margin"
  ) +
  theme_void() + 
  labs(title = "Predicted Win Margin, 2016 PA Presidential Election")

max(df$pred_2016)

resid_2016 <- plot_usmap(data = df, regions = "counties", values = "resid_2016", include = "PA") +
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-.32, -.24, -.16, -.08, 0, .08, .16, .24, .32), 
    limits = c(-.32,.32),
    name = "differential"
  ) +
  theme_void() + 
  labs(title = "Predicted vs. Real Win Margin, 2016 PA Presidential Election", 
       caption = "Darker blue = model disproportionately favors Dems; darker red = model disproportionately favors GOP")

turnout <- turnout %>%
  filter(year %% 4 == 0) %>%
  mutate(pct = turnout/VEP)



turnout_2016 <- turnout %>% filter(year == 2016 & state != "United States" & state != "District of Columbia") 

max(turnout_2016$pct)


voting_turnout <- turnout %>%
  filter(state != "United States") %>%
  left_join(pvstate) %>%
  filter(year >= 1980) %>%
  mutate(D_pv2p = D_pv2p / 100, 
         R_pv2p = R_pv2p / 100) 
  select(state, year, pct, R_pv2p, D_pv2p)

voting_turnout$D_pv2p[voting_turnout$state == swing[1]]


swing = c("Wisconsin", "Michigan", "Pennsylvania", "Arizona", "Florida", "Ohio", "Texas", "Iowa", "North Carolina", "Georgia")

# simulate many turnouts
turnout_WI_2020 <- rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing[1]]),sd = sd(turnout$pct[turnout$state == swing[1]]))
turnout_MI_2020 <- rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing[2]]),sd = sd(turnout$pct[turnout$state == swing[2]]))
turnout_PA_2020 <- rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing[3]]),sd = sd(turnout$pct[turnout$state == swing[3]]))
turnout_AZ_2020 <- rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing[4]]),sd = sd(turnout$pct[turnout$state == swing[4]]))
turnout_FL_2020 <- rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing[5]]),sd = sd(turnout$pct[turnout$state == swing[5]]))
turnout_OH_2020 <- rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing[6]]),sd = sd(turnout$pct[turnout$state == swing[6]]))
turnout_TX_2020 <- rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing[7]]),sd = sd(turnout$pct[turnout$state == swing[7]]))
turnout_IA_2020 <- rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing[8]]),sd = sd(turnout$pct[turnout$state == swing[8]]))
turnout_NC_2020 <- rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing[9]]),sd = sd(turnout$pct[turnout$state == swing[9]]))
turnout_GA_2020 <- rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing[10]]),sd = sd(turnout$pct[turnout$state == swing[10]]))

# simulate many elections
Dpoll_WI_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing[1]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing[1]]))
Dpoll_MI_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing[2]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing[2]]))
Dpoll_PA_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing[3]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing[3]]))
Dpoll_AZ_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing[4]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing[4]]))
Dpoll_FL_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing[5]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing[5]]))
Dpoll_OH_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing[6]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing[6]]))
Dpoll_TX_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing[7]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing[7]]))
Dpoll_IA_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing[8]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing[8]]))
Dpoll_NC_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing[9]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing[9]]))
Dpoll_GA_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing[10]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing[10]]))


polling <- polls_2020_538 %>%
  mutate(daysout = as.numeric(-1*as.numeric(as.Date(end_date, format = "%m/%d/%Y")-as.Date(election_date, format = "%m/%d/%Y")))) %>%
  filter(!is.na(state) & answer == "Biden" | answer == "Trump") %>%
  filter(daysout <= 40 & fte_grade%in%c("A/B", "A+", "A", "B+", "B")) %>%
  arrange(state) %>%
  select(state, daysout, fte_grade, answer, pct)

biden_polling <- polling %>%
  filter(answer == "Biden") %>%
  group_by(state) %>%
  summarize(avg_polling = mean(pct)) %>%
  select(state, avg_polling)


# model for each state
WI_glm <- glm(turnout_WI_2020 ~ Dpoll_WI_2020, family = binomial)
MI_glm <- glm(turnout_MI_2020 ~ Dpoll_MI_2020, family = binomial)
PA_glm <- glm(turnout_PA_2020 ~ Dpoll_PA_2020, family = binomial)
AZ_glm <- glm(turnout_AZ_2020 ~ Dpoll_AZ_2020, family = binomial)
FL_glm <- glm(turnout_FL_2020 ~ Dpoll_FL_2020, family = binomial)
OH_glm <- glm(turnout_OH_2020 ~ Dpoll_OH_2020, family = binomial)
TX_glm <- glm(turnout_TX_2020 ~ Dpoll_TX_2020, family = binomial)
IA_glm <- glm(turnout_IA_2020 ~ Dpoll_IA_2020, family = binomial)
NC_glm <- glm(turnout_NC_2020 ~ Dpoll_NC_2020, family = binomial)
GA_glm <- glm(turnout_GA_2020 ~ Dpoll_GA_2020, family = binomial)



# probability of a single vote in each state
prob_Dvote_WI_2020 <- predict(WI_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[biden_polling$state==swing[1]]), type="response")[[1]]
prob_Dvote_MI_2020 <- predict(MI_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[biden_polling$state==swing[2]]), type="response")[[1]]
prob_Dvote_PA_2020 <- predict(PA_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[biden_polling$state==swing[3]]), type="response")[[1]]
prob_Dvote_AZ_2020 <- predict(AZ_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[biden_polling$state==swing[4]]), type="response")[[1]]
prob_Dvote_FL_2020 <- predict(FL_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[biden_polling$state==swing[5]]), type="response")[[1]]
prob_Dvote_OH_2020 <- predict(OH_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[biden_polling$state==swing[6]]), type="response")[[1]]
prob_Dvote_TX_2020 <- predict(TX_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[biden_polling$state==swing[7]]), type="response")[[1]]
prob_Dvote_IA_2020 <- predict(IA_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[biden_polling$state==swing[8]]), type="response")[[1]]
prob_Dvote_NC_2020 <- predict(NC_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[biden_polling$state==swing[9]]), type="response")[[1]]
prob_Dvote_GA_2020 <- predict(GA_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[biden_polling$state==swing[10]]), type="response")[[1]]


votes <- data.frame(state = swing, result = c(prob_Dvote_WI_2020, prob_Dvote_MI_2020, prob_Dvote_PA_2020, prob_Dvote_AZ_2020, prob_Dvote_FL_2020, prob_Dvote_OH_2020, prob_Dvote_TX_2020, prob_Dvote_IA_2020, prob_Dvote_NC_2020, prob_Dvote_GA_2020))

votes$Dwin = as.numeric(votes$result >= .5)

votes$Dwin


plot_usmap(data = votes, regions = "state", values = "Dwin", include = state.abb[match(swing,state.name)]) +
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "red",
    breaks = c(0, 1), 
    limits = c(0,1),
    name = "differential"
  ) +
  theme_void() + 
  labs(title = "Swing State Election prediction")



