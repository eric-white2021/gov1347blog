## import libraries
library(tidyverse)
library(ggplot2)
library(usmap)
library(geofacet)
library(gridExtra)

## set working directory here
setwd("Downloads")

## read csv data
ad_creative <- read_csv("ad_creative_2000-2012.csv")
ad_campaigns <- read_csv("ad_campaigns_2000-2012.csv")
ads_2020 <- read_csv("ads_2020.csv")
pvstate <- read_csv("popvote_bystate_1948-2016.csv")
polls_2020 <- read_csv("polls_2020.csv")
vep_df <- read_csv("vep_1980-2016.csv")
polls_2020_538 <- read_csv("president_polls.csv")
pollstate <- read_csv("pollavg_bystate_1968-2016.csv")


# get vote totals for each election
votes <- pvstate %>%
  mutate(state = state.abb[match(state,state.name)]) %>%
  filter(year >= 2000) %>%
  select(state, year, R_pv2p, D_pv2p)

# merge ad data with voting data
df <- ad_campaigns %>%
  filter(state %in% state.abb) %>%
  rename(year = cycle) %>%
  select(state, year, party, total_cost) %>%
  arrange(year, state) %>%
  group_by(year, state, party) %>%
  summarize(avg_cost = mean(total_cost)) %>%
  left_join(votes)

# create graphs for ad spending vs. vote share for both parties
D_2000 <- df %>%
  filter(year == 2000 & party == "democrat") %>%
  ggplot(aes(x=avg_cost, y=D_pv2p,
             label=state)) + 
  geom_text(size=1) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share by state vs. Campaign spending (2000)") + 
  xlab("Average spending by state") +
  ylab("Democratic two-party popular vote share") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.67), angle=0)) +
  theme(plot.title = element_text(size=4))

D_2004 <- df %>%
  filter(year == 2004 & party == "democrat") %>%
  ggplot(aes(x=avg_cost, y=D_pv2p,
             label=state)) + 
  geom_text(size=1) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share by state vs. Campaign spending (2004)") + 
  xlab("Average spending by state") +
  ylab("Democratic two-party popular vote share") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.67), angle=0)) +
  theme(plot.title = element_text(size=4))

D_2008 <- df %>%
  filter(year == 2008 & party == "democrat") %>%
  ggplot(aes(x=avg_cost, y=D_pv2p,
             label=state)) + 
  geom_text(size=1) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share by state vs. Campaign spending (2008)") + 
  xlab("Average spending by state") +
  ylab("Democratic two-party popular vote share") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.67), angle=0)) +
  theme(plot.title = element_text(size=4))

D_2012 <- df %>%
  filter(year == 2012 & party == "democrat") %>%
  ggplot(aes(x=avg_cost, y=D_pv2p,
             label=state)) + 
  geom_text(size=1) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share by state vs. Campaign spending (2012)") + 
  xlab("Average spending by state") +
  ylab("Democratic two-party popular vote share") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.67), angle=0)) +
  theme(plot.title = element_text(size=4))
  

R_2000 <- df %>%
  filter(year == 2000 & party == "republican") %>%
  ggplot(aes(x=avg_cost, y=R_pv2p,
             label=state)) + 
  geom_text(size=1) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share by state vs. Campaign spending (2000)") + 
  xlab("Average spending by state") +
  ylab("Republican two-party popular vote share") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.67), angle=0)) +
  theme(plot.title = element_text(size=4))

R_2004 <- df %>%
  filter(year == 2004 & party == "republican") %>%
  ggplot(aes(x=avg_cost, y=R_pv2p,
             label=state)) + 
  geom_text(size=1) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share by state vs. Campaign spending (2004)") + 
  xlab("Average spending by state") +
  ylab("Republican two-party popular vote share") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.67), angle=0)) +
  theme(plot.title = element_text(size=4))

R_2008 <- df %>%
  filter(year == 2008 & party == "republican") %>%
  ggplot(aes(x=avg_cost, y=R_pv2p,
             label=state)) + 
  geom_text(size=1) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share by state vs. Campaign spending (2008)") + 
  xlab("Average spending by state") +
  ylab("Republican two-party popular vote share") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.67), angle=0)) +
  theme(plot.title = element_text(size=4))

R_2012 <- df %>%
  filter(year == 2012 & party == "republican") %>%
  ggplot(aes(x=avg_cost, y=R_pv2p,
             label=state)) + 
  geom_text(size=1) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share by state vs. Campaign spending (2012)") + 
  xlab("Average spending by state") +
  ylab("Republican two-party popular vote share") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.67), angle=0)) +
  theme(plot.title = element_text(size=4))

# show graphs
grid.arrange(D_2000, D_2004, D_2008, D_2012, R_2000, R_2004, R_2008, R_2012, ncol=4)
  
# create linear models and average the results for each year; variance was not super high so average is a reasonable metric
fit_D_00 <- lm(df$D_pv2p[df$year == 2000 & df$party == "democrat"] ~ df$avg_cost[df$year == 2000 & df$party == "democrat"])
fit_D_04 <- lm(df$D_pv2p[df$year == 2004 & df$party == "democrat"] ~ df$avg_cost[df$year == 2004 & df$party == "democrat"])
fit_D_08 <- lm(df$D_pv2p[df$year == 2008 & df$party == "democrat"] ~ df$avg_cost[df$year == 2008 & df$party == "democrat"])
fit_D_12 <- lm(df$D_pv2p[df$year == 2012 & df$party == "democrat"] ~ df$avg_cost[df$year == 2012 & df$party == "democrat"])

arrD <- c(as.numeric(fit_D_00$coefficients), as.numeric(fit_D_04$coefficients), as.numeric(fit_D_08$coefficients), as.numeric(fit_D_12$coefficients))
b_D <- mean(arrD[c(1,3,5,7)])
m_D <- mean(arrD[c(2,4,6,8)])

fit_R_00 <- lm(df$R_pv2p[df$year == 2000 & df$party == "republican"] ~ df$avg_cost[df$year == 2000 & df$party == "republican"])
fit_R_04 <- lm(df$R_pv2p[df$year == 2004 & df$party == "republican"] ~ df$avg_cost[df$year == 2004 & df$party == "republican"])
fit_R_08 <- lm(df$R_pv2p[df$year == 2008 & df$party == "republican"] ~ df$avg_cost[df$year == 2008 & df$party == "republican"])
fit_R_12 <- lm(df$R_pv2p[df$year == 2012 & df$party == "republican"] ~ df$avg_cost[df$year == 2012 & df$party == "republican"])

arrR <- c(as.numeric(fit_R_00$coefficients), as.numeric(fit_R_04$coefficients), as.numeric(fit_R_08$coefficients), as.numeric(fit_R_12$coefficients))
b_R <- mean(arrR[c(1,3,5,7)])
m_R <- mean(arrR[c(2,4,6,8)])


# biden ad spending data
ads_biden <- ads_2020 %>%
  arrange(state) %>%
  group_by(state) %>%
  summarize(biden_spending = mean(total_cost*biden_airings/total_airings)) %>%
  select(state, biden_spending)

# predicted biden result for each state
ads_biden$pred_biden <- b_D + m_D*ads_biden$biden_spending

# trump ad spending data
ads_trump <- ads_2020 %>%
  arrange(state) %>%
  group_by(state) %>%
  summarize(trump_spending = mean(total_cost*trump_airings/total_airings)) %>%
  select(state, trump_spending)

# predicted trump result for each state
ads_trump$pred_trump <- b_R + m_R*ads_trump$trump_spending

# collect ad data into data frame
ads_total <- ads_biden %>%
  left_join(ads_trump) %>%
  mutate(state = state.name[match(state,state.abb)]) %>%
  arrange(state) %>%
  mutate(state = state.abb[match(state,state.name)]) %>%
  group_by(state) %>%
  mutate(biden_pv2p = pred_biden/(pred_biden+pred_trump)) %>%
  mutate(trump_pv2p = pred_trump/(pred_biden+pred_trump)) %>%
  mutate(biden_win = biden_pv2p > trump_pv2p) %>%
  select(state, biden_spending, trump_spending, pred_biden, pred_trump, biden_pv2p, trump_pv2p, biden_win)

# add in electoral college values
ads_total$state[is.na(ads_total$state)] = "DC"
ads_total$electoral = c(9, 3, 11, 6, 55, 9, 7, 29, 16, 4, 4, 20, 11, 6, 6, 8, 
                        8, 4, 10, 11, 16, 10, 6, 10, 3, 5, 6, 4, 5, 29, 15, 3, 
                        18, 7, 7, 20,9, 3, 11, 38, 6, 3, 13, 12, 5, 10, 3, 3)

# add back DE, NJ, RI, which are safe victories for Biden to get Biden delegates
biden_EC <- sum(ads_total$biden_win[!is.na(ads_total$biden_win)]*ads_total$electoral[!is.na(ads_total$biden_win)]) + 3 + 14 + 4
# Trump electoral delegates
trump_EC <- 538-biden_EC

# final ad data frame to use for plotting
ads_result <- ads_total %>%
  mutate(states = state.name[match(state,state.abb)]) %>%
  select(states, biden_win)

ads_result$biden_win[ads_result$states == "Kansas"] = FALSE

# plot Biden victory result
plot_usmap(data = ads_result, regions = "states", values = "biden_win") +
  scale_fill_manual(values = c("red", "dodgerblue2"), name = "won by Biden") + 
  theme_void() + 
  labs(title = "2020 Election Prediction based on ad spending")



# polling data from 538
voters <- pvstate %>%
  filter(year == 2016) %>%
  rename(VEP = total) %>%
  select(state, VEP)

polling <- polls_2020_538 %>%
  mutate(daysout = as.numeric(-1*as.numeric(as.Date(end_date, format = "%m/%d/%Y")-as.Date(election_date, format = "%m/%d/%Y")))) %>%
  filter(!is.na(state) & answer == "Biden" | answer == "Trump") %>%
  filter(daysout <= 40 & fte_grade%in%c("A/B", "A+", "A", "B+", "B")) %>%
  arrange(state) %>%
  left_join(voters) %>%
  mutate(total = pct*VEP) %>%
  select(state, daysout, fte_grade, answer, VEP, pct, total)
  
biden_polling <- polling %>%
  filter(answer == "Biden") %>%
  group_by(state) %>%
  summarize(avg_polling = mean(pct)) %>%
  select(state, avg_polling)

trump_polling <- polling %>%
  filter(answer == "Trump") %>%
  group_by(state) %>%
  summarize(avg_polling = mean(pct)) %>%
  select(state, avg_polling)






# probabilistic models for various swing states
swing = c("Wisconsin", "Michigan", "Pennsylvania", "Arizona", "Florida", "Ohio", "Texas", "Iowa", "North Carolina", "Georgia")

# VEP in each state
VEP_WI_2020 <- as.integer(vep_df$VEP[vep_df$state == swing[1] & vep_df$year == 2016])
VEP_MI_2020 <- as.integer(vep_df$VEP[vep_df$state == swing[2] & vep_df$year == 2016])
VEP_PA_2020 <- as.integer(vep_df$VEP[vep_df$state == swing[3] & vep_df$year == 2016])
VEP_AZ_2020 <- as.integer(vep_df$VEP[vep_df$state == swing[4] & vep_df$year == 2016])
VEP_FL_2020 <- as.integer(vep_df$VEP[vep_df$state == swing[5] & vep_df$year == 2016])
VEP_OH_2020 <- as.integer(vep_df$VEP[vep_df$state == swing[6] & vep_df$year == 2016])
VEP_TX_2020 <- as.integer(vep_df$VEP[vep_df$state == swing[7] & vep_df$year == 2016])
VEP_IA_2020 <- as.integer(vep_df$VEP[vep_df$state == swing[8] & vep_df$year == 2016])
VEP_NC_2020 <- as.integer(vep_df$VEP[vep_df$state == swing[9] & vep_df$year == 2016])
VEP_GA_2020 <- as.integer(vep_df$VEP[vep_df$state == swing[10] & vep_df$year == 2016])

# partisan voters in each state
WI_R <- poll_pvstate_vep %>% filter(state==swing[1], party=="republican")
WI_D <- poll_pvstate_vep %>% filter(state==swing[1], party=="democrat")
MI_R <- poll_pvstate_vep %>% filter(state==swing[2], party=="republican")
MI_D <- poll_pvstate_vep %>% filter(state==swing[2], party=="democrat")
PA_R <- poll_pvstate_vep %>% filter(state==swing[3], party=="republican")
PA_D <- poll_pvstate_vep %>% filter(state==swing[3], party=="democrat")
AZ_D <- poll_pvstate_vep %>% filter(state==swing[4], party=="democrat")
AZ_R <- poll_pvstate_vep %>% filter(state==swing[4], party=="republican")
FL_D <- poll_pvstate_vep %>% filter(state==swing[5], party=="democrat")
FL_R <- poll_pvstate_vep %>% filter(state==swing[5], party=="republican")
OH_D <- poll_pvstate_vep %>% filter(state==swing[6], party=="democrat")
OH_R <- poll_pvstate_vep %>% filter(state==swing[6], party=="republican")
TX_D <- poll_pvstate_vep %>% filter(state==swing[7], party=="democrat")
TX_R <- poll_pvstate_vep %>% filter(state==swing[7], party=="republican")
IA_D <- poll_pvstate_vep %>% filter(state==swing[8], party=="democrat")
IA_R <- poll_pvstate_vep %>% filter(state==swing[8], party=="republican")
NC_D <- poll_pvstate_vep %>% filter(state==swing[9], party=="democrat")
NC_R <- poll_pvstate_vep %>% filter(state==swing[9], party=="republican")
GA_D <- poll_pvstate_vep %>% filter(state==swing[10], party=="democrat")
GA_R <- poll_pvstate_vep %>% filter(state==swing[10], party=="republican")

# model for each state
WI_R_glm <- glm(cbind(R, VEP-R) ~ avg_poll, WI_R, family = binomial)
WI_D_glm <- glm(cbind(D, VEP-D) ~ avg_poll, WI_D, family = binomial)
MI_R_glm <- glm(cbind(R, VEP-R) ~ avg_poll, MI_R, family = binomial)
MI_D_glm <- glm(cbind(D, VEP-D) ~ avg_poll, MI_D, family = binomial)
PA_R_glm <- glm(cbind(R, VEP-R) ~ avg_poll, PA_R, family = binomial)
PA_D_glm <- glm(cbind(D, VEP-D) ~ avg_poll, PA_D, family = binomial)
AZ_R_glm <- glm(cbind(R, VEP-R) ~ avg_poll, AZ_R, family = binomial)
AZ_D_glm <- glm(cbind(D, VEP-D) ~ avg_poll, AZ_D, family = binomial)
FL_R_glm <- glm(cbind(R, VEP-R) ~ avg_poll, FL_R, family = binomial)
FL_D_glm <- glm(cbind(D, VEP-D) ~ avg_poll, FL_D, family = binomial)
OH_R_glm <- glm(cbind(R, VEP-R) ~ avg_poll, OH_R, family = binomial)
OH_D_glm <- glm(cbind(D, VEP-D) ~ avg_poll, OH_D, family = binomial)
TX_R_glm <- glm(cbind(R, VEP-R) ~ avg_poll, TX_R, family = binomial)
TX_D_glm <- glm(cbind(D, VEP-D) ~ avg_poll, TX_D, family = binomial)
IA_R_glm <- glm(cbind(R, VEP-R) ~ avg_poll, IA_R, family = binomial)
IA_D_glm <- glm(cbind(D, VEP-D) ~ avg_poll, IA_D, family = binomial)
NC_R_glm <- glm(cbind(R, VEP-R) ~ avg_poll, NC_R, family = binomial)
NC_D_glm <- glm(cbind(D, VEP-D) ~ avg_poll, NC_D, family = binomial)
GA_R_glm <- glm(cbind(R, VEP-R) ~ avg_poll, GA_R, family = binomial)
GA_D_glm <- glm(cbind(D, VEP-D) ~ avg_poll, GA_D, family = binomial)

# probability of a single vote in each state
prob_Rvote_WI_2020 <- predict(WI_R_glm, newdata = data.frame(avg_poll=trump_polling$avg_polling[trump_polling$state==swing[1]]), type="response")[[1]]
prob_Dvote_WI_2020 <- predict(WI_D_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[trump_polling$state==swing[1]]), type="response")[[1]]
prob_Rvote_MI_2020 <- predict(MI_R_glm, newdata = data.frame(avg_poll=trump_polling$avg_polling[trump_polling$state==swing[2]]), type="response")[[1]]
prob_Dvote_MI_2020 <- predict(MI_D_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[trump_polling$state==swing[2]]), type="response")[[1]]
prob_Rvote_PA_2020 <- predict(PA_R_glm, newdata = data.frame(avg_poll=trump_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Dvote_PA_2020 <- predict(PA_D_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Rvote_AZ_2020 <- predict(AZ_R_glm, newdata = data.frame(avg_poll=trump_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Dvote_AZ_2020 <- predict(AZ_D_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Rvote_FL_2020 <- predict(FL_R_glm, newdata = data.frame(avg_poll=trump_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Dvote_FL_2020 <- predict(FL_D_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Rvote_OH_2020 <- predict(OH_R_glm, newdata = data.frame(avg_poll=trump_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Dvote_OH_2020 <- predict(OH_D_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Rvote_TX_2020 <- predict(TX_R_glm, newdata = data.frame(avg_poll=trump_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Dvote_TX_2020 <- predict(TX_D_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Rvote_IA_2020 <- predict(IA_R_glm, newdata = data.frame(avg_poll=trump_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Dvote_IA_2020 <- predict(IA_D_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Rvote_NC_2020 <- predict(NC_R_glm, newdata = data.frame(avg_poll=trump_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Dvote_NC_2020 <- predict(NC_D_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Rvote_GA_2020 <- predict(GA_R_glm, newdata = data.frame(avg_poll=trump_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]
prob_Dvote_GA_2020 <- predict(GA_D_glm, newdata = data.frame(avg_poll=biden_polling$avg_polling[trump_polling$state==swing[3]]), type="response")[[1]]

# simulated vote totals
sim_Rvotes_WI_2020 <- rbinom(n = 100000, size = VEP_WI_2020, prob = prob_Rvote_WI_2020)
sim_Dvotes_WI_2020 <- rbinom(n = 100000, size = VEP_WI_2020, prob = prob_Dvote_WI_2020)
sim_Rvotes_MI_2020 <- rbinom(n = 100000, size = VEP_MI_2020, prob = prob_Rvote_MI_2020)
sim_Dvotes_MI_2020 <- rbinom(n = 100000, size = VEP_MI_2020, prob = prob_Dvote_MI_2020)
sim_Rvotes_PA_2020 <- rbinom(n = 100000, size = VEP_PA_2020, prob = prob_Rvote_PA_2020)
sim_Dvotes_PA_2020 <- rbinom(n = 100000, size = VEP_PA_2020, prob = prob_Dvote_PA_2020)
sim_Rvotes_AZ_2020 <- rbinom(n = 100000, size = VEP_AZ_2020, prob = prob_Rvote_AZ_2020)
sim_Dvotes_AZ_2020 <- rbinom(n = 100000, size = VEP_AZ_2020, prob = prob_Dvote_AZ_2020)
sim_Rvotes_FL_2020 <- rbinom(n = 100000, size = VEP_FL_2020, prob = prob_Rvote_FL_2020)
sim_Dvotes_FL_2020 <- rbinom(n = 100000, size = VEP_FL_2020, prob = prob_Dvote_FL_2020)
sim_Rvotes_OH_2020 <- rbinom(n = 100000, size = VEP_OH_2020, prob = prob_Rvote_OH_2020)
sim_Dvotes_OH_2020 <- rbinom(n = 100000, size = VEP_OH_2020, prob = prob_Dvote_OH_2020)
sim_Rvotes_TX_2020 <- rbinom(n = 100000, size = VEP_TX_2020, prob = prob_Rvote_TX_2020)
sim_Dvotes_TX_2020 <- rbinom(n = 100000, size = VEP_TX_2020, prob = prob_Dvote_TX_2020)
sim_Rvotes_IA_2020 <- rbinom(n = 100000, size = VEP_IA_2020, prob = prob_Rvote_IA_2020)
sim_Dvotes_IA_2020 <- rbinom(n = 100000, size = VEP_IA_2020, prob = prob_Dvote_IA_2020)
sim_Rvotes_NC_2020 <- rbinom(n = 100000, size = VEP_NC_2020, prob = prob_Rvote_NC_2020)
sim_Dvotes_NC_2020 <- rbinom(n = 100000, size = VEP_NC_2020, prob = prob_Dvote_NC_2020)
sim_Rvotes_GA_2020 <- rbinom(n = 100000, size = VEP_GA_2020, prob = prob_Rvote_GA_2020)
sim_Dvotes_GA_2020 <- rbinom(n = 100000, size = VEP_GA_2020, prob = prob_Dvote_GA_2020)

# histograms of margins
sim_elxns_WI_2020 <- ((sim_Dvotes_WI_2020-sim_Rvotes_WI_2020)/(sim_Dvotes_WI_2020+sim_Rvotes_WI_2020))*100
hist(sim_elxns_WI_2020, xlab="predicted draws of Biden win margin (% pts)\nfrom 10,000 binomial process simulations", xlim=c(2, 7.5))

sim_elxns_MI_2020 <- ((sim_Dvotes_MI_2020-sim_Rvotes_MI_2020)/(sim_Dvotes_MI_2020+sim_Rvotes_MI_2020))*100
hist(sim_elxns_MI_2020, xlab="predicted draws of Biden win margin (% pts)\nfrom 10,000 binomial process simulations", xlim=c(2, 7.5))

sim_elxns_PA_2020 <- ((sim_Dvotes_PA_2020-sim_Rvotes_PA_2020)/(sim_Dvotes_PA_2020+sim_Rvotes_PA_2020))*100
hist(sim_elxns_PA_2020, xlab="predicted draws of Biden win margin (% pts)\nfrom 10,000 binomial process simulations", xlim=c(2, 7.5))

sim_elxns_AZ_2020 <- ((sim_Dvotes_AZ_2020-sim_Rvotes_AZ_2020)/(sim_Dvotes_AZ_2020+sim_Rvotes_AZ_2020))*100
hist(sim_elxns_AZ_2020, xlab="predicted draws of Biden win margin (% pts)\nfrom 10,000 binomial process simulations", xlim=c(2, 7.5))

sim_elxns_FL_2020 <- ((sim_Dvotes_FL_2020-sim_Rvotes_FL_2020)/(sim_Dvotes_FL_2020+sim_Rvotes_FL_2020))*100
hist(sim_elxns_FL_2020, xlab="predicted draws of Biden win margin (% pts)\nfrom 10,000 binomial process simulations", xlim=c(2, 7.5))

sim_elxns_OH_2020 <- ((sim_Dvotes_OH_2020-sim_Rvotes_OH_2020)/(sim_Dvotes_OH_2020+sim_Rvotes_OH_2020))*100
hist(sim_elxns_OH_2020, xlab="predicted draws of Biden win margin (% pts)\nfrom 10,000 binomial process simulations", xlim=c(2, 7.5))

sim_elxns_TX_2020 <- ((sim_Dvotes_TX_2020-sim_Rvotes_TX_2020)/(sim_Dvotes_TX_2020+sim_Rvotes_TX_2020))*100
hist(sim_elxns_TX_2020, xlab="predicted draws of Biden win margin (% pts)\nfrom 10,000 binomial process simulations", xlim=c(2, 7.5))

sim_elxns_IA_2020 <- ((sim_Dvotes_IA_2020-sim_Rvotes_IA_2020)/(sim_Dvotes_IA_2020+sim_Rvotes_IA_2020))*100
hist(sim_elxns_IA_2020, xlab="predicted draws of Biden win margin (% pts)\nfrom 10,000 binomial process simulations", xlim=c(2, 7.5))

sim_elxns_NC_2020 <- ((sim_Dvotes_NC_2020-sim_Rvotes_NC_2020)/(sim_Dvotes_NC_2020+sim_Rvotes_NC_2020))*100
hist(sim_elxns_NC_2020, xlab="predicted draws of Biden win margin (% pts)\nfrom 10,000 binomial process simulations", xlim=c(2, 7.5))

sim_elxns_GA_2020 <- ((sim_Dvotes_GA_2020-sim_Rvotes_GA_2020)/(sim_Dvotes_GA_2020+sim_Rvotes_GA_2020))*100
hist(sim_elxns_GA_2020, xlab="predicted draws of Biden win margin (% pts)\nfrom 10,000 binomial process simulations", xlim=c(2, 7.5))
