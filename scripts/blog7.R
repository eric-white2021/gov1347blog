## import libraries
library(tidyverse)
library(ggplot2)
library(usmap)
library(geofacet)
library(gridExtra)

## set working directory here
setwd("Downloads")



county <- read_csv("popvote_bycounty_2000-2016.csv")
covid_counties <- read_csv("covid_counties.csv")
polls <- read_csv("president_polls_1026.csv")
covid <- read.csv("state_covid_cases_deaths.csv")
pvstate <- read.csv("popvote_bystate_1948-2016.csv")
state_pop <- read.csv("state_pop.csv")
turnout <- read_csv("turnout_1980-2016.csv")

state_pop <- state_pop %>%
  mutate(state = state.abb[match(state,state.name)])

swing <- state.abb[match(c("Wisconsin", "Michigan", "Pennsylvania", "Arizona", "Florida", "Ohio", "Texas", "Iowa", "North Carolina", "Georgia", "Nevada"), state.name)]

county_voting <- county %>%
  arrange(state,county,year) %>%
  mutate(D_win_margin = D_win_margin / 100) %>%
  group_by(county, fips) %>%
  summarize(avg_margin = mean(D_win_margin))
  

covid_counties <- covid_counties %>%
  rename(fips = `FIPS County Code`)


df <- covid_counties %>%
  mutate(pct_covid = `Deaths involving COVID-19` / `Deaths from All Causes`) %>%
  rename(all_death = `Deaths from All Causes`, 
         covid_death = `Deaths involving COVID-19`,
         state = State) %>%
  select(fips, state, `County name`, covid_death, all_death, pct_covid)

# data frame for countywide voting and COVID
xxx <- df %>%
  left_join(county_voting) %>%
  mutate(D_pv2p = (1+avg_margin)/2) %>%
  select(fips, state, county, pct_covid, avg_margin, D_pv2p)


# create maps of arizona
az_cov <- plot_usmap(data = xxx, regions = "counties", values = "pct_covid", include="AZ") +
  scale_fill_gradient2(
    high = "red", 
    low = "white",
    breaks = c(0, .1, .2, .3, .4, .5), 
    limits = c(0, .5),
    name = "percent of deaths covid"
  ) +
  theme_void() + 
  labs(title = "Percentage of deaths due to COVID by county (AZ)") + 
  theme(plot.title = element_text(size=10))


az_margin <- plot_usmap(data = xxx, regions = "counties", values = "avg_margin", include="AZ") +
  scale_fill_gradient2(
    high = "dodgerblue2",
    mid = "white",
    low = "red",
    breaks = c(-1, -.75, -.5, -.25, 0, .25, .5, .75, 1), 
    limits = c(-1, 1),
    name = "average margin"
  ) +
  theme_void() + 
  labs(title = "Average voting patterns by county (AZ)") + 
  theme(plot.title = element_text(size=10))

grid.arrange(az_cov, az_margin, ncol=2)
  
# checks
length(xxx$D_pv2p[!is.na(xxx$D_pv2p)])
length(xxx$pct_covid[!is.na(xxx$D_pv2p)])

# regression
summary(lm(xxx$D_pv2p ~ xxx$pct_covid))

summary(glm(xxx$D_pv2p[!is.na(xxx$D_pv2p)] ~ xxx$pct_covid[!is.na(xxx$D_pv2p)], family = "binomial"))

dat <- data.frame(covid = xxx$pct_covid[!is.na(xxx$D_pv2p)], vote = xxx$D_pv2p[!is.na(xxx$D_pv2p)])
dat_s <- data.frame(s_covid = xxx$pct_covid[xxx$state == "MA"], s_vote = xxx$D_pv2p[xxx$state == "MA"])

ggplot(dat_s, aes(x=s_covid, y=s_vote)) + geom_point() + 
  stat_smooth(method="glm", method.args=list(family="binomial"), se=FALSE)

#polling data
polling <- polls %>%
  mutate(daysout = as.numeric(-1*as.numeric(as.Date(end_date, format = "%m/%d/%Y")-as.Date(election_date, format = "%m/%d/%Y")))) %>%
  mutate(state = state.abb[match(state,state.name)]) %>%
  filter(!is.na(state) & answer == "Biden" | answer == "Trump") %>%
  filter(daysout <= 286 & fte_grade%in%c("A/B", "A+", "A", "B+", "B")) %>%
  arrange(state) %>%
  group_by(question_id, poll_id,state, fte_grade, daysout) %>%
  mutate(pv2p = pct/sum(pct)) %>%
  filter(pv2p != 1 & pv2p != 0) %>%
  select(question_id, poll_id, state, fte_grade, daysout, answer, pct, pv2p)

# change date to date format
covid$submission_date <- as.Date(covid$submission_date, format = "%m/%d/%Y")

# covid data by state
covid_states <- covid %>%
  mutate(days = as.numeric(as.Date("11/03/2020", format = "%m/%d/%Y")-submission_date)) %>%
  select(state, days, tot_cases, tot_death) %>%
  arrange(state)

# recent polling data for Trump
total_polling <- polling %>%
  filter(answer == "Trump" & daysout <= 40 & state%in%state.abb) %>%
  group_by(state) %>%
  summarize(result = mean(pv2p))

# most recent covid stats, per capita data
total_covid <- covid_states %>% 
  filter(days == 9 & state%in%state.abb) %>%
  left_join(state_pop) %>%
  mutate(cases = tot_cases / population,
         death = tot_death / population) %>%
  select(state, cases, death)

# 2016 voting
total_2016 <- pvstate %>% 
  mutate(state = state.abb[match(state,state.name)]) %>%
  filter(year == 2016 & state%in%state.abb) %>%
  select(state, R_pv2p, D_pv2p)

# combine data frames, get difference between 2016 and 2020 for Trump
total_df <- total_covid %>%
  left_join(total_2016) %>%
  left_join(total_polling) %>%
  mutate(diff = result - R_pv2p/100)

# get under/over performance for Trump over the average difference between 2020 and 2016
total_df <- total_df %>%
  filter(!is.na(diff)) %>%
  mutate(excess = diff - mean(total_df$diff)) %>%
  select(state, cases, death, result, R_pv2p, diff, excess)

# filter for swing states
swing_df <- total_df %>%filter(state%in%swing)

# graph for cases
case_graph <- ggplot(total_df, aes(x=cases, y=excess, 
           label=state)) + 
  geom_text(size=2.5) + 
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Trump change in performance vs COVID cases per capita") + 
  ylab("Trump performance relative to 2016, normalized") +
  xlab("Current cases by state") +
  theme_bw() + 
  theme(plot.title = element_text(size=7))

# graph for deaths
death_graph <- ggplot(total_df, aes(x=death, y=excess, 
                  label=state)) + 
  geom_text(size=2.5) + 
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Trump change in performance vs COVID deaths per capita") + 
  ylab("Trump performance relative to 2016, normalized") +
  xlab("Current deaths by state") +
  theme_bw() + 
  theme(plot.title = element_text(size=7))

grid.arrange(case_graph, death_graph, ncol=2)


# graph for cases swing states
swing_case_graph <- ggplot(swing_df, aes(x=cases, y=excess, 
                                   label=state)) + 
  geom_text(size=2.5) + 
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Trump change in performance vs COVID cases per capita") + 
  ylab("Trump performance relative to 2016, normalized") +
  xlab("Current cases by state") +
  theme_bw() + 
  theme(plot.title = element_text(size=7))

# graph for deaths swing states
swing_death_graph <- ggplot(swing_df, aes(x=death, y=excess, 
                                    label=state)) + 
  geom_text(size=2.5) + 
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Trump change in performance vs COVID deaths per capita") + 
  ylab("Trump performance relative to 2016, normalized") +
  xlab("Current deaths by state") +
  theme_bw() + 
  theme(plot.title = element_text(size=7))

grid.arrange(swing_case_graph, swing_death_graph, ncol=2)





# turnout
turnout <- turnout %>%
  filter(year %% 4 == 0) %>%
  mutate(pct = turnout/VEP)

# 2016 turnout
turnout_2016 <- turnout %>% filter(year == 2016 & state != "United States" & state != "District of Columbia") 


# voting & turnout dataframe
voting_turnout <- turnout %>%
  filter(state != "United States") %>%
  left_join(pvstate) %>%
  filter(year >= 1980) %>%
  mutate(D_pv2p = D_pv2p / 100, 
         R_pv2p = R_pv2p / 100) 
select(state, year, pct, R_pv2p, D_pv2p)

# swing states
swing_state = c("Wisconsin", "Michigan", "Pennsylvania", "Arizona", "Florida", "Ohio", "Texas", "Iowa", "North Carolina", "Georgia", "Nevada")



# get Z-score for covid cases per capita by state
swing_z <- total_covid %>%
  filter(state%in%swing) %>%
  mutate(z = (cases - mean(total_covid$cases))/sd(total_covid$cases)) %>%
  select(state, z)

# create linear relationship between z scores in swing states; best swing state z score discounted by 1x, worse swing state z score discounted by .85x
m = -.15/(max(swing_z$z)-min(swing_z$z))
b = 1-min(swing_z$z)*m

# add discoutn factors to df
swing_z <- swing_z %>%
  mutate(c = m*z+b)




# simulate turnout from VEP in each state
turnout_WI_2020 <- sort(rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing_state[1]]),sd = sd(turnout$pct[turnout$state == swing_state[1]])))
turnout_MI_2020 <- sort(rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing_state[2]]),sd = sd(turnout$pct[turnout$state == swing_state[2]])))
turnout_PA_2020 <- sort(rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing_state[3]]),sd = sd(turnout$pct[turnout$state == swing_state[3]])))
turnout_AZ_2020 <- sort(rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing_state[4]]),sd = sd(turnout$pct[turnout$state == swing_state[4]])))
turnout_FL_2020 <- sort(rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing_state[5]]),sd = sd(turnout$pct[turnout$state == swing_state[5]])))
turnout_OH_2020 <- sort(rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing_state[6]]),sd = sd(turnout$pct[turnout$state == swing_state[6]])))
turnout_TX_2020 <- sort(rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing_state[7]]),sd = sd(turnout$pct[turnout$state == swing_state[7]])))
turnout_IA_2020 <- sort(rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing_state[8]]),sd = sd(turnout$pct[turnout$state == swing_state[8]])))
turnout_NC_2020 <- sort(rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing_state[9]]),sd = sd(turnout$pct[turnout$state == swing_state[9]])))
turnout_GA_2020 <- sort(rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing_state[10]]),sd = sd(turnout$pct[turnout$state == swing_state[10]])))
turnout_NV_2020 <- sort(rnorm(n = 100, mean = mean(turnout$pct[turnout$state == swing_state[11]]),sd = sd(turnout$pct[turnout$state == swing_state[11]])))

# create vector of turnout
turnout_vec = c(turnout_WI_2020, turnout_MI_2020, turnout_PA_2020, turnout_AZ_2020, turnout_FL_2020, turnout_OH_2020, turnout_TX_2020, turnout_IA_2020, turnout_NC_2020, turnout_GA_2020, turnout_NV_2020)

# discount some fraction (25%) of the turnout by the discount factor based on COVID
weighted_turnout_WI_2020 <- c(swing_z$c[swing_z$state == swing[1]]*head(turnout_vec[1:100], 25), tail(turnout_vec[1:100], 75))
weighted_turnout_MI_2020 <- c(swing_z$c[swing_z$state == swing[2]]*head(turnout_vec[101:200], 25), tail(turnout_vec[101:200], 75))
weighted_turnout_PA_2020 <- c(swing_z$c[swing_z$state == swing[3]]*head(turnout_vec[201:300], 25), tail(turnout_vec[201:300], 75))
weighted_turnout_AZ_2020 <- c(swing_z$c[swing_z$state == swing[4]]*head(turnout_vec[301:400], 25), tail(turnout_vec[301:400], 75))
weighted_turnout_FL_2020 <- c(swing_z$c[swing_z$state == swing[5]]*head(turnout_vec[401:500], 25), tail(turnout_vec[401:500], 75))
weighted_turnout_OH_2020 <- c(swing_z$c[swing_z$state == swing[6]]*head(turnout_vec[501:600], 25), tail(turnout_vec[501:600], 75))
weighted_turnout_TX_2020 <- c(swing_z$c[swing_z$state == swing[7]]*head(turnout_vec[601:700], 25), tail(turnout_vec[601:700], 75))
weighted_turnout_IA_2020 <- c(swing_z$c[swing_z$state == swing[8]]*head(turnout_vec[701:800], 25), tail(turnout_vec[701:800], 75))
weighted_turnout_NC_2020 <- c(swing_z$c[swing_z$state == swing[9]]*head(turnout_vec[801:900], 25), tail(turnout_vec[801:900], 75))
weighted_turnout_GA_2020 <- c(swing_z$c[swing_z$state == swing[10]]*head(turnout_vec[901:1000], 25), tail(turnout_vec[901:1000], 75))
weighted_turnout_NV_2020 <- c(swing_z$c[swing_z$state == swing[11]]*head(turnout_vec[1001:1100], 25), tail(turnout_vec[1001:1100], 75))

# simulate polling
Dpoll_WI_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing_state[1]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing_state[1]]))
Dpoll_MI_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing_state[2]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing_state[2]]))
Dpoll_PA_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing_state[3]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing_state[3]]))
Dpoll_AZ_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing_state[4]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing_state[4]]))
Dpoll_FL_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing_state[5]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing_state[5]]))
Dpoll_OH_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing_state[6]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing_state[6]]))
Dpoll_TX_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing_state[7]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing_state[7]]))
Dpoll_IA_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing_state[8]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing_state[8]]))
Dpoll_NC_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing_state[9]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing_state[9]]))
Dpoll_GA_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing_state[10]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing_state[10]]))
Dpoll_NV_2020 <- rnorm(n = 100, mean = mean(voting_turnout$D_pv2p[voting_turnout$state == swing_state[11]]),sd = sd(voting_turnout$D_pv2p[voting_turnout$state == swing_state[11]]))

# polling data
polling <- polls %>%
  mutate(daysout = as.numeric(-1*as.numeric(as.Date(end_date, format = "%m/%d/%Y")-as.Date(election_date, format = "%m/%d/%Y")))) %>%
  filter(!is.na(state) & answer == "Biden" | answer == "Trump") %>%
  filter(daysout <= 40 & fte_grade%in%c("A/B", "A+", "A", "B+", "B")) %>%
  arrange(state) %>%
  select(state, daysout, fte_grade, answer, pct)

# Biden polling data
biden_polling <- polling %>%
  filter(answer == "Biden") %>%
  group_by(state) %>%
  summarize(avg_polling = mean(pct)) %>%
  select(state, avg_polling)





# model for each state w/ binary dependent variable (did Democrat win?)
WI_glm <- glm(as.integer(Dpoll_WI_2020 > .5) ~ weighted_turnout_WI_2020, family = binomial)
MI_glm <- glm(as.integer(Dpoll_MI_2020 > .5) ~ weighted_turnout_MI_2020, family = binomial)
PA_glm <- glm(as.integer(Dpoll_PA_2020 > .5) ~ weighted_turnout_PA_2020, family = binomial)
AZ_glm <- glm(as.integer(Dpoll_AZ_2020 > .5) ~ weighted_turnout_AZ_2020, family = binomial)
FL_glm <- glm(as.integer(Dpoll_FL_2020 > .5) ~ weighted_turnout_FL_2020, family = binomial)
OH_glm <- glm(as.integer(Dpoll_OH_2020 > .5) ~ weighted_turnout_OH_2020, family = binomial)
TX_glm <- glm(as.integer(Dpoll_TX_2020 > .5) ~ weighted_turnout_TX_2020, family = binomial)
IA_glm <- glm(as.integer(Dpoll_IA_2020 > .5) ~ weighted_turnout_IA_2020, family = binomial)
NC_glm <- glm(as.integer(Dpoll_NC_2020 > .5) ~ weighted_turnout_NC_2020, family = binomial)
GA_glm <- glm(as.integer(Dpoll_GA_2020 > .5) ~ weighted_turnout_GA_2020, family = binomial)
NV_glm <- glm(as.integer(Dpoll_NV_2020 > .5) ~ weighted_turnout_NV_2020, family = binomial)



# probability of a single vote in each state
prob_Dvote_WI_2020 <- as.numeric(predict(WI_glm, newdata = data.frame(avg = runif(100,0,(avg_poll=biden_polling$avg_polling[biden_polling$state==swing_state[1]]))), type="response")[1])
prob_Dvote_MI_2020 <- as.numeric(predict(MI_glm, newdata = data.frame(avg = runif(100,0,(avg_poll=biden_polling$avg_polling[biden_polling$state==swing_state[2]]))), type="response")[1])
prob_Dvote_PA_2020 <- as.numeric(predict(PA_glm, newdata = data.frame(avg = runif(100,0,(avg_poll=biden_polling$avg_polling[biden_polling$state==swing_state[3]]))), type="response")[1])
prob_Dvote_AZ_2020 <- as.numeric(predict(AZ_glm, newdata = data.frame(avg = runif(100,0,(avg_poll=biden_polling$avg_polling[biden_polling$state==swing_state[4]]))), type="response")[1])
prob_Dvote_FL_2020 <- as.numeric(predict(FL_glm, newdata = data.frame(avg = runif(100,0,(avg_poll=biden_polling$avg_polling[biden_polling$state==swing_state[5]]))), type="response")[1])
prob_Dvote_OH_2020 <- as.numeric(predict(OH_glm, newdata = data.frame(avg = runif(100,0,(avg_poll=biden_polling$avg_polling[biden_polling$state==swing_state[6]]))), type="response")[1])
prob_Dvote_TX_2020 <- as.numeric(predict(TX_glm, newdata = data.frame(avg = runif(100,0,(avg_poll=biden_polling$avg_polling[biden_polling$state==swing_state[7]]))), type="response")[1])
prob_Dvote_IA_2020 <- as.numeric(predict(IA_glm, newdata = data.frame(avg = runif(100,0,(avg_poll=biden_polling$avg_polling[biden_polling$state==swing_state[8]]))), type="response")[1])
prob_Dvote_NC_2020 <- as.numeric(predict(NC_glm, newdata = data.frame(avg = runif(100,0,(avg_poll=biden_polling$avg_polling[biden_polling$state==swing_state[9]]))), type="response")[1])
prob_Dvote_GA_2020 <- as.numeric(predict(GA_glm, newdata = data.frame(avg = runif(100,0,(avg_poll=biden_polling$avg_polling[biden_polling$state==swing_state[10]]))), type="response")[1])
prob_Dvote_NV_2020 <- as.numeric(predict(NV_glm, newdata = data.frame(avg = runif(100,0,(avg_poll=biden_polling$avg_polling[biden_polling$state==swing_state[11]]))), type="response")[1])

# dataframe for vote probability
votes <- data.frame(state = swing, result = c(prob_Dvote_WI_2020, prob_Dvote_MI_2020, prob_Dvote_PA_2020, prob_Dvote_AZ_2020, prob_Dvote_FL_2020, prob_Dvote_OH_2020, prob_Dvote_TX_2020, prob_Dvote_IA_2020, prob_Dvote_NC_2020, prob_Dvote_GA_2020, prob_Dvote_NV_2020))

# Democrat wins if vote is greater than 50% threshold
votes$Dwin = as.numeric(votes$result >= .5)


# plot swing state results
plot_usmap(data = votes, regions = "state", values = "Dwin", include = swing) +
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "red",
    breaks = c(0, 1), 
    limits = c(0,1),
    name = "winner"
  ) +
  theme_void() + 
  labs(title = "Swing State Election prediction")

