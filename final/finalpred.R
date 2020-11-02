## import libraries
library(tidyverse)
library(ggplot2)
library(usmap)
library(geofacet)
library(gridExtra)
library(hash)

## set working directory here
setwd("Downloads")

polls_2016 <- read_csv("president_general_polls_2016.csv")
econ <- read_csv("econ.csv")
econ_local <- read_csv("local.csv")
demographics <- read_csv("demographic_1990-2018.csv")
pvstate <- read_csv("popvote_bystate_1948-2016.csv")


# hash map to convert grades into numbers
h <- hash()
h[c("A+", "A", "A-", "B+", "B", "B-")] <- c(1, .9, .85, .75, .7, .65)

# read in and manipulate poll data 2016; add in scoring in order to weigh polls later
x <- polls_2016 %>%
  filter(state != "U.S." & !is.na(grade) & grade%in%c("A+", "A", "A-", "B+", "B", "B-")) %>%
  mutate(size_score = sqrt(samplesize/600),
         daysout = as.numeric(as.Date("11/8/2016", format = "%m/%d/%Y")-as.Date(enddate, format = "%m/%d/%Y")),
         recent_score = (1/daysout)^.1) %>%
  arrange(state, daysout) %>%
  select(state, enddate, grade, samplesize, rawpoll_clinton, rawpoll_trump, size_score, daysout, recent_score)

# initialize grade_score column
x$grade_score <- rep(0,length(x$grade))

# fill grade_score column
for (i in 1:length(x$grade))
{
  x$grade_score[i] <- as.numeric(values(h[x$grade[i], USE.NAMES=FALSE]))
}

# update poll data with scores and weights for polls
x <- x %>%
  filter(daysout <= 40) %>%
  mutate(score = size_score*recent_score*grade_score) %>%
  group_by(state) %>%
  mutate(weight = score/sum(score))

# final data frame for 2016 polling with state by state weighted results
fin <- x %>%
  mutate(clinton_avg = weight * rawpoll_clinton,
         trump_avg = weight * rawpoll_trump) %>%
  group_by(state) %>%
  summarize(sum(clinton_avg), sum(trump_avg)) %>%
  rename(clinton=`sum(clinton_avg)`, trump=`sum(trump_avg)`) %>%
  mutate(margin = clinton - trump) %>%
  select(state, clinton, trump, margin)

# graph for polls only prediction
plot_usmap(data = fin, regions = "states", values = "margin") + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-52, -39, -26, -13, 0, 13, 26, 39, 52), 
    limits = c(-52, 52),
    name = "2016 margin"
  ) +
  theme_void() + 
  labs(title = "2016 Election Prediction (polls)")


# read in economic data
econ %>%
  filter(year %% 4 == 0 & quarter == 2) %>%
  rename(gdpg = GDP_growth_yr,
         UE = unemployment) %>%
  select(year, gdpg, UE)

# read in demographic data
demo <- demographics %>%
  filter(year %% 4 == 0) %>%
  mutate(state = state.name[match(state,state.abb)],
         white = White/100,
         black = Black/100,
         senior = age65/100) %>%
  arrange(state, year) %>%
  select(year, state, white, black, senior)

# read in historical voting data by state
pvstate <- pvstate %>%
  filter(year >= 1968) %>%
  arrange(state, year) %>%
  select(state, year, D_pv2p, R_pv2p)

# add in incumbent column for republicans and democrats
pvstate$Dinc <- rep(c(TRUE,FALSE,FALSE,TRUE,FALSE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE,TRUE),51)
pvstate$Rinc <- rep(c(FALSE,TRUE,TRUE,FALSE,TRUE,TRUE,TRUE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE),51)

# we only have some data starting in 1992 so must filter other data to match
state_voting <- pvstate %>% filter(year >= 1992)

# manipulate local data so it is easier to use
local <- econ_local %>%
  rename(state = `State and area`,
         year = Year,
         LFPR = LaborForce_prct, 
         UE = Unemployed_prce) %>%
  arrange(state, year, Month) %>%
  group_by(state, year) %>%
    summarize(avg_LFPR = mean(LFPR), avg_UE = mean(UE)) %>%
  filter(year %% 4 == 0 & year >= 1992 & year <= 2016 & state%in%c(state.name, "District of Columbia"))

# join fundamental data together
df <- local %>%
  left_join(demo) %>%
  left_join(state_voting)

# 2016 data to test model
df_x2016 <- df %>% filter(year != 2016 & state != "District of Columbia")
df_2016 <- df %>% filter(year == 2016 & state != "District of Columbia")

# states we have data for
states <- unique(df$state[df$state!="District of Columbia"])

# initialize arrays to be filled
dpred <- c()
dlower <- c()
dupper <- c()
rpred <- c()
rlower <- c()
rupper <- c()

# fill arrays with predictions and confidence interval
for (i in 1:length(states))
{
  dreg <- as.numeric(predict(object=lm(D_pv2p ~ white + black + senior + avg_UE, df_x2016 %>% filter(state == states[i])), newdata=df_2016 %>% filter(state == states[i]), interval="confidence", level = 0.8))
  dpred <- append(dpred,dreg[1])
  dlower <- append(dlower,dreg[2])
  dupper <- append(dupper,dreg[3])
  rreg <- as.numeric(predict(object=lm(R_pv2p ~ white + black + senior + avg_UE, df_x2016 %>% filter(state == states[i])), newdata=df_2016 %>% filter(state == states[i]), interval="confidence", level = 0.8))
  rpred <- append(rpred,rreg[1])
  rlower <- append(rlower,rreg[2])
  rupper <- append(rupper,rreg[3])
}

# predicted result from regression by state
result <- data.frame(state = states, dpred, dlower, dupper, rpred, rlower, rupper)
result <- result %>%
  mutate(diff = dpred - rpred)

# plot just fundamentals result
plot_usmap(data = result, regions = "states", values = "diff") + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-75, -50, -25, 0, 25, 50, 75), 
    limits = c(-75, 75),
    name = "2016 margin"
  ) +
  theme_void() + 
  labs(title = "2016 Election Prediction (fundamentals)")

# fundamentals data frame with final results for predictions/win margin
fund <- result %>% select(state, dpred, rpred, diff)

# combine fundamentals with polling 2016; weigh 97.5% toward polling
comb <- fund %>%
  left_join(fin) %>%
  mutate(democrat = .975*clinton + .025*dpred,
         republican = .975*trump + .025*rpred,
         res = democrat - republican) %>%
  select(state, democrat, republican, res)

# plot polls + fundamentals final model
plot_usmap(data = comb, regions = "states", values = "res") + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-40, -30, -20, -10, 0, 10, 20, 30, 40), 
    limits = c(-40, 40),
    name = "2016 margin"
  ) +
  theme_void() + 
  labs(title = "2016 Election Prediction (polls+fundamentals)")


##############################

# read in data for 2020
polls_2020 <- read_csv("president_polls_Nov1.csv")
demographics_2020 <- read.csv("demog_2020.csv")
econ_2020 <- read.csv("econ_2020.csv")


# 2020 polling data
polls <- polls_2020 %>%
  filter(!is.na(state) & !is.na(fte_grade) & fte_grade%in%c("A+", "A", "A-", "A/B", "B+", "B", "B-", "B/C") & answer%in%c("Biden", "Trump")) %>%
  mutate(size_score = sqrt(sample_size/600),
         daysout = as.numeric(as.Date("11/3/20", format = "%m/%d/%Y")-as.Date(end_date, format = "%m/%d/%Y")),
         recent_score = (1/daysout)^.1) %>%
  arrange(state, daysout) %>%
  select(state, question_id, poll_id, end_date, daysout, fte_grade, sample_size, answer, pct, size_score, recent_score)

# hash for converting poll grades
g <- hash()
g[c(c("A+", "A", "A-", "A/B", "B+", "B", "B-", "B/C"))] <- c(1, .9, .85, .8, .75, .7, .65, .6)

# initialize grade score column
polls$grade_score <- rep(0,length(polls$fte_grade))

# fill grade score column
for (i in 1:length(polls$fte_grade))
{
  polls$grade_score[i] <- as.numeric(values(g[polls$fte_grade[i], USE.NAMES=FALSE]))
}

# update polls df with scores and weights
polls <- polls %>%
  filter(daysout <= 40) %>%
  mutate(score = size_score*recent_score*grade_score) %>%
  group_by(state,answer) %>%
  mutate(weight = score/sum(score))

# filter by Biden only
biden_polls <- polls %>%
  filter(answer == "Biden") %>%
  mutate(biden_avg = weight * pct) %>%
  group_by(state) %>%
  summarize(sum(biden_avg)) %>%
  rename(biden=`sum(biden_avg)`) %>%
  select(state, biden)

# filter by Trump only
trump_polls <- polls %>%
  filter(answer == "Trump") %>%
  mutate(trump_avg = weight * pct) %>%
  group_by(state) %>%
  summarize(sum(trump_avg)) %>%
  rename(trump=`sum(trump_avg)`) %>%
  select(state, trump)

# combine results back again to get win margin
result_2020 <- biden_polls %>%
  left_join(trump_polls) %>%
  mutate(margin = round(biden - trump, 5))


# states that were not in data
missed <- state.name[!state.name%in%result_2020$state]

# total precition for all states
pred_2020 <- rbind(result_2020, 
                   data.frame(state = missed, 
                              biden = pvstate$D_pv2p[pvstate$state%in%missed & pvstate$year == 2016], 
                              trump = pvstate$R_pv2p[pvstate$state%in%missed & pvstate$year == 2016], 
                              margin = pvstate$D_pv2p[pvstate$state%in%missed & pvstate$year == 2016] - pvstate$R_pv2p[pvstate$state%in%missed & pvstate$year == 2016])) %>% 
  arrange(state)


# 2020 polls only model result
plot_usmap(data = pred_2020, regions = "states", values = "margin") + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-52, -39, -26, -13, 0, 13, 26, 39, 52), 
    limits = c(-52, 52),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "2020 Election Prediction (polls)")

# economic data for 2020
local_2020 <- econ_local %>%
  rename(state = `State and area`,
         year = Year,
         LFPR = LaborForce_prct, 
         UE = Unemployed_prce) %>%
  arrange(state, year, Month) %>%
  group_by(state, year) %>%
  summarize(avg_LFPR = mean(LFPR), avg_UE = mean(UE)) %>%
  filter(year %% 4 == 0 & year >= 1992 & year <= 2016 & state%in%c(state.name, "District of Columbia"))

# demographic data for 2020 
# https://www.bls.gov/web/laus/laumstrk.htm
# https://www.census.gov/quickfacts/DC
# https://www.prb.org/which-us-states-are-the-oldest/
# https://worldpopulationreview.com/states/states-by-race
demo_2020 <- demographics_2020 %>%
  rename(state = State,
         white=WhitePerc,
         black=BlackPerc,
         senior=SeniorsPerc) %>%
  mutate(year = 2020) %>%
  select(year, state, white, black, senior)



# join economic and demographic data
df_2020 <- econ_2020 %>%
  left_join(demo_2020) %>%
  rename()

# 2020 data set for prediction
df_x2020 <- df %>% filter(state != "District of Columbia")

# initialize empty arrays for confidence interval
dpred_2020 <- c()
dlower_2020 <- c()
dupper_2020 <- c()
rpred_2020 <- c()
rlower_2020 <- c()
rupper_2020 <- c()

# fill empty arrays
for (i in 1:length(states))
{
  dreg_2020 <- as.numeric(predict(object=lm(D_pv2p ~ white + black + senior + avg_UE, df_x2020 %>% filter(state == states[i])), newdata=df_2020 %>% filter(state == states[i]), interval="confidence", level = 0.8))
  dpred_2020 <- append(dpred_2020,dreg_2020[1])
  dlower_2020 <- append(dlower_2020,dreg_2020[2])
  dupper_2020 <- append(dupper_2020,dreg_2020[3])
  rreg_2020 <- as.numeric(predict(object=lm(R_pv2p ~ white + black + senior + avg_UE, df_x2020 %>% filter(state == states[i])), newdata=df_2016 %>% filter(state == states[i]), interval="confidence", level = 0.8))
  rpred_2020 <- append(rpred_2020,rreg_2020[1])
  rlower_2020 <- append(rlower_2020,rreg_2020[2])
  rupper_2020 <- append(rupper_2020,rreg_2020[3])
}

# results dataframe from regression
res_2020 <- data.frame(state = states, dpred_2020, dlower_2020, dupper_2020, rpred_2020, rlower_2020, rupper_2020)
res_2020 <- res_2020 %>%
  mutate(diff_2020 = dpred_2020 - rpred_2020)

# 2020 fundamentals only (not good)
plot_usmap(data = res_2020, regions = "states", values = "diff_2020") + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-400, -200, 0, 200, 400), 
    limits = c(-400, 400),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "2020 Election Prediction (fundamentals)")

# choose relevant variables from fundamentals
fund_2020 <- res_2020 %>% select(state, dpred_2020, rpred_2020, diff_2020)

# create ensemble model with 97.5% polls
comb_2020 <- fund_2020 %>%
  left_join(pred_2020) %>%
  mutate(democrat = .975*biden + .025*dpred_2020,
         republican = .975*trump + .025*rpred_2020,
         final_2020 = democrat - republican) %>%
  select(state, democrat, republican, final_2020)

# finals model plotted
plot_usmap(data = comb_2020, regions = "states", values = "final_2020") + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "white",
    low = "red",
    breaks = c(-90, -60, -30, 0, 30, 60, 90), 
    limits = c(-90, 90),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "2020 Election Prediction (polls+fundamentals)")


# electoral college votes
comb_2020$electoral <- c(9, 3, 11, 6, 55, 9, 7, 3, 29, 16, 4, 4, 20, 11, 6, 6, 8, 
                         8, 4, 10, 11, 16, 10, 6, 10, 3, 5, 6, 4, 14, 5, 29, 15, 
                         3, 18, 7, 7, 20, 4, 9, 3, 11, 38, 6, 3, 13, 12, 5, 10, 3)
# whether or not Democrat won
comb_2020$Dwin <- as.numeric(comb_2020$final_2020 >= 0)

# get electoral vote totals
sum(comb_2020$electoral[comb_2020$final_2020 >= 0])

# plots whether democrat won
plot_usmap(data = comb_2020, regions = "states", values = "Dwin") + 
  scale_fill_gradient2(
    high = "dodgerblue2", 
    mid = "red",
    breaks = c(0, 1), 
    limits = c(0,1),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "2020 State by State Election Prediction (polls+fundamentals)")


# create dataframe for standard deviation of polls
stdev_polling <- polls_2020 %>%
  filter(!is.na(state) & !is.na(fte_grade) & fte_grade%in%c("A+", "A", "A-", "A/B", "B+", "B", "B-", "B/C") & answer%in%c("Biden", "Trump")) %>%
  mutate(daysout = as.numeric(as.Date("11/3/20", format = "%m/%d/%Y")-as.Date(end_date, format = "%m/%d/%Y"))) %>%
  arrange(state, daysout) %>%
  filter(daysout <= 100) %>%
  group_by(state, answer) %>%
  summarize(stdev = sd(pct)) %>%
  select(state, answer, stdev)


#split into Biden/Trump
biden_stdev <- stdev_polling %>%
  filter(answer == "Biden") %>%
  left_join(biden_polls)

trump_stdev <- stdev_polling %>%
  filter(answer == "Trump") %>%
  left_join(trump_polls)


# fill missing values based on similarl states or past results
biden_stdev$biden[biden_stdev$state == "Delaware"] <- as.numeric(pvstate %>% filter(pvstate$state%in%biden_stdev$state[is.na(biden_stdev$biden)] & year == 2016 & state == "Delaware") %>% select(D_pv2p))
biden_stdev$biden[biden_stdev$state == "Idaho"] <- as.numeric(pvstate %>% filter(pvstate$state%in%biden_stdev$state[is.na(biden_stdev$biden)] & year == 2016 & state == "Idaho") %>% select(D_pv2p))
biden_stdev$biden[biden_stdev$state == "Vermont"] <- as.numeric(pvstate %>% filter(pvstate$state%in%biden_stdev$state[is.na(biden_stdev$biden)] & year == 2016 & state == "Vermont") %>% select(D_pv2p))
trump_stdev$trump[trump_stdev$state == "Delaware"] <- as.numeric(pvstate %>% filter(pvstate$state%in%trump_stdev$state[is.na(trump_stdev$trump)] & year == 2016 & state == "Delaware") %>% select(R_pv2p))
trump_stdev$trump[trump_stdev$state == "Idaho"] <- as.numeric(pvstate %>% filter(pvstate$state%in%trump_stdev$state[is.na(trump_stdev$trump)] & year == 2016 & state == "Idaho") %>% select(R_pv2p))
trump_stdev$trump[trump_stdev$state == "Vermont"] <- as.numeric(pvstate %>% filter(pvstate$state%in%trump_stdev$state[is.na(trump_stdev$trump)] & year == 2016 & state == "Vermont") %>% select(R_pv2p))

biden_polls$state[abs(biden_polls$biden-biden_polls$biden[biden_polls$state=="Connecticut"]) <= 0.0344]
biden_stdev$stdev[biden_stdev$state == "Connecticut"] <- biden_stdev$stdev[biden_stdev$state == "Wisconsin"]
trump_stdev$stdev[trump_stdev$state == "Connecticut"] <- trump_stdev$stdev[trump_stdev$state == "Wisconsin"]

biden_polls$state[abs(biden_polls$biden-biden_polls$biden[biden_polls$state=="Illinois"]) <= 0.0344]
biden_stdev$stdev[biden_stdev$state == "Illinois"] <- biden_stdev$stdev[biden_stdev$state == "Maine"]
trump_stdev$stdev[trump_stdev$state == "Illinois"] <- trump_stdev$stdev[trump_stdev$state == "Maine"]

biden_polls$state[abs(biden_polls$biden-biden_polls$biden[biden_polls$state=="South Dakota"]) <= .8]
biden_stdev$stdev[biden_stdev$state == "South Dakota"] <- biden_stdev$stdev[biden_stdev$state == "Utah"]
trump_stdev$stdev[trump_stdev$state == "South Dakota"] <- trump_stdev$stdev[trump_stdev$state == "Utah"]

biden_polls$state[abs(biden_polls$biden-biden_polls$biden[biden_polls$state=="West Virginia"]) <= .8]
biden_stdev$stdev[biden_stdev$state == "West Virginia"] <- biden_stdev$stdev[biden_stdev$state == "Kentucky"]
trump_stdev$stdev[trump_stdev$state == "West Virginia"] <- trump_stdev$stdev[trump_stdev$state == "Kentucky"]

biden_stdev$state[abs(biden_stdev$biden-biden_stdev$biden[biden_stdev$state=="Delaware"]) <= .1]
biden_stdev$stdev[biden_stdev$state == "Delaware"] <- biden_stdev$stdev[biden_stdev$state == "Oregon"]
trump_stdev$stdev[trump_stdev$state == "Delaware"] <- trump_stdev$stdev[trump_stdev$state == "Oregon"]

biden_stdev$state[abs(biden_stdev$biden-biden_stdev$biden[biden_stdev$state=="Idaho"]) <= 2]
biden_stdev$stdev[biden_stdev$state == "Idaho"] <- biden_stdev$stdev[biden_stdev$state == "Arkansas"]
trump_stdev$stdev[trump_stdev$state == "Idaho"] <- trump_stdev$stdev[trump_stdev$state == "Arkansas"]

biden_stdev$state[abs(biden_stdev$biden-biden_stdev$biden[biden_stdev$state=="Vermont"]) <= 2]
biden_stdev$stdev[biden_stdev$state == "Vermont"] <- biden_stdev$stdev[biden_stdev$state == "Massachusetts"]
trump_stdev$stdev[trump_stdev$state == "Vermont"] <- trump_stdev$stdev[trump_stdev$state == "Massachusetts"]

# 2 party popular vote share
pv2p <- result_2020 %>%
  mutate(D_pv2p = 100 * biden / (biden + trump),
         R_pv2p = 100 * trump / (biden + trump),
         difference = D_pv2p - R_pv2p)

# Biden confidence interval 95%
biden_interval <- biden_stdev %>%
  mutate(D_low = biden-2*stdev, D_high = biden+2*stdev)

# Trump confidence interval 95%
trump_interval <- trump_stdev %>%
  mutate(R_low = trump-2*stdev, R_high = trump+2*stdev)

# states missed and their margins
missed_margin <- pvstate$D_pv2p[pvstate$year == 2016 & pvstate$state%in%c("Nebraska", "Rhode Island", "Tennessee", "Wyoming")] - pvstate$R_pv2p[pvstate$year == 2016 & pvstate$state%in%c("Nebraska", "Rhode Island", "Tennessee", "Wyoming")]


# best and case scenarios for each
scenarios <- data.frame(state = biden_interval$state, biden_most = biden_interval$D_high, biden_least = biden_interval$D_low,  biden_best = biden_interval$D_high - trump_interval$R_low, trump_most = trump_interval$R_high, trump_least = trump_interval$R_low, trump_best = biden_interval$D_low - trump_interval$R_high)
scenarios <- rbind(scenarios, data.frame(state = c("Nebraska", "Rhode Island", "Tennessee", "Wyoming"), 
                                         biden_most = pvstate$D_pv2p[pvstate$year == 2016 & pvstate$state%in%c("Nebraska", "Rhode Island", "Tennessee", "Wyoming")] + 3, 
                                         biden_least = pvstate$D_pv2p[pvstate$year == 2016 & pvstate$state%in%c("Nebraska", "Rhode Island", "Tennessee", "Wyoming")] - 3,
                                         biden_best = missed_margin + 6, 
                                         trump_most = pvstate$R_pv2p[pvstate$year == 2016 & pvstate$state%in%c("Nebraska", "Rhode Island", "Tennessee", "Wyoming")] + 3, 
                                         trump_least = pvstate$R_pv2p[pvstate$year == 2016 & pvstate$state%in%c("Nebraska", "Rhode Island", "Tennessee", "Wyoming")] - 3,
                                         trump_best = missed_margin-6))

# add two-party vote to scenarios df
scenarios <- scenarios %>%
  mutate(D_pv2p_best = 100 * biden_most / (biden_most+trump_least),
         R_pv2p_best = 100 * trump_most / (biden_least+trump_most),
         biden_wins = as.numeric(D_pv2p_best >= 50),
         trump_wins = as.numeric(R_pv2p_best >= 50))

# add electoral votes to scenarios df
scenarios$electoral <- c(9, 3, 11, 6, 55, 9, 7, 3, 29, 16, 4, 4, 20, 11, 6, 6, 8, 
                         8, 4, 0, 0, 10, 11, 16, 10, 6, 10, 3, 5, 0, 6, 4, 14, 5, 29, 15, 
                         3, 18, 7, 7, 20, 4, 9, 3, 11, 38, 6, 3, 13, 12, 5, 10, 3)

# get electoral votes; doesn't add to 538 because DC not included/assumed to Biden
sum(scenarios$biden_wins*scenarios$electoral)
sum((1-scenarios$biden_wins)*scenarios$electoral)
sum(scenarios$trump_wins*scenarios$electoral)
sum((1-scenarios$trump_wins)*scenarios$electoral)

# plot trump best case state by state
trump_best_case <- plot_usmap(data = scenarios, regions = "states", values = "trump_wins") + 
  scale_fill_gradient2(
    high = "red",
    mid = "dodgerblue2", 
    breaks = c(0, 1), 
    limits = c(0,1),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "Best case for Trump")

# plot biden best case state by state
biden_best_case <- plot_usmap(data = scenarios, regions = "states", values = "biden_wins") + 
  scale_fill_gradient2(
    high = "dodgerblue1", 
    mid = "red",
    breaks = c(0, 1), 
    limits = c(0,1),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "Best case for Biden")

# plot together
grid.arrange(trump_best_case, biden_best_case, ncol=2)

# states there was no data for, assumed to be 2016
lost_states <- c("Delaware", "Idaho", "Nebraska", "Rhode Island", "Tennessee", "Vermont", "Wyoming")
vals <- as.numeric(unlist(pvstate %>% filter(year == 2016 & state%in%lost_states) %>% mutate(difference = D_pv2p - R_pv2p) %>%select(difference)))

# pv2p data frame with all states accounted for 
pv2p_2020 <- rbind(data.frame(state=pv2p$state, difference=pv2p$difference), data.frame(state = lost_states, difference = vals))

# plot of pv2p vote margins in each state 2020 prediction
plot_usmap(data = pv2p_2020, regions = "states", values = "difference") + 
  scale_fill_gradient2(
    high = "dodgerblue1", 
    mid = "white",
    low = "red",
    breaks = c(-60, -40, -20, 0, 20, 40, 60), 
    limits = c(-60,60),
    name = "2020 margin"
  ) +
  theme_void() + 
  labs(title = "Two-party popular vote share prediction (2020)")


# biden and trump win probabilities; calculated based on vote share not pv2p so will not add to 100
# mainly used for intuition
probwin_biden <- c()
for (state in biden_stdev$state) {
  probwin_biden <- append(probwin_biden,mean((rnorm(100, biden_stdev$biden[biden_stdev$state == state], biden_stdev$stdev[biden_stdev$state == state]))>50))
}

probwin_biden[probwin_biden < .5 & probwin_biden > .05]
biden_stdev$state[probwin_biden < .5 & probwin_biden > .05]

probwin_trump <- c()
for (state in trump_stdev$state) {
  probwin_trump <- append(probwin_trump,mean((rnorm(100, trump_stdev$trump[trump_stdev$state == state], trump_stdev$stdev[trump_stdev$state == state]))>50))
}

probwin_trump[probwin_trump < .5 & probwin_trump > .05]
trump_stdev$state[probwin_trump < .5 & probwin_trump > .05]
