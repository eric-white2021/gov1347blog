library(tidyverse)
library(ggplot2)
library(usmap)
library(gridExtra)

## set working directory here
setwd("Downloads")

# read in data
popvote <- read_csv("popvote_1948-2016.csv")
pvstate <- read_csv("popvote_bystate_1948-2016.csv")
pollavg <- read_csv("pollavg_1968-2016.csv")
pollstate <- read_csv("pollavg_bystate_1968-2016.csv")
polls2016 <- read_csv("polls_2016.csv")
polls2020 <- read_csv("polls_2020.csv")
ratings2016 <- read_csv("pollster-ratings_2016.csv")
ratings2020 <- read_csv("pollster-ratings_2020.csv")

# create list of swing states and their abbreviations
swing_states <- c("Arizona", "Florida", "Michigan", "Ohio", "Pennsylvania", "Wisconsin")
swing_state_abb <- state.abb[match(swing_states,state.name)]


# get polling data for polls less than 14 days until election, take unweighted average, then combine with election data for national popular vote
poll_result_close <- pollavg %>%
  filter(days_left <= 14) %>%
  select(year, party, days_left, avg_support) %>%
  group_by(year, party) %>%
  summarize(avg_support = mean(avg_support)) %>%
  left_join(popvote %>% filter(year >= 1968)) %>%
  select(year, avg_support, pv, incumbent_party) 

# get polling data for polls more than 14 days until election, take unweighted average, then combine with election data for national popular vote
poll_result_far <- pollavg %>%
  filter(days_left >= 14) %>%
  select(year, party, days_left, avg_support) %>%
  group_by(year, party) %>%
  summarize(avg_support = mean(avg_support)) %>%
  left_join(popvote %>% filter(year >= 1968)) %>%
  select(year, avg_support, pv, incumbent_party) 

# plot popular vote share vs polling data for the incumbent party, 14 days or less until election
inc_poll_close <- poll_result_close %>%
  filter(incumbent_party == TRUE) %>%
  ggplot(aes(x=avg_support, y=pv,
             label=year)) + 
  geom_text(size=2.5) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share vs. Polling average (incumbent)") + 
  xlab("Polling average two weeks before election") +
  ylab("Incumbent party vote % 1968-2016") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(plot.title = element_text(size=9.5))

# plot popular vote share vs polling data for the non-incumbent party, 14 days or less until election
noninc_poll_close <- poll_result_close %>%
  filter(incumbent_party == FALSE) %>%
  ggplot(aes(x=avg_support, y=pv,
             label=year)) + 
  geom_text(size=2.5) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share vs. Polling average (non-incumbent)") +
  xlab("Polling average two weeks before election") +
  ylab("Non-incumbent party vote % 1968-2016") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(plot.title = element_text(size=9.5))

# plot popular vote share vs polling data for the incumbent party, 14 or more days until election
inc_poll_far <- poll_result_far %>%
  filter(incumbent_party == TRUE) %>%
  ggplot(aes(x=avg_support, y=pv,
           label=year)) + 
  geom_text(size=2.5) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share vs. Polling average (incumbent)") + 
  xlab("Polling average over two weeks until election") +
  ylab("Incumbent party vote % 1968-2016") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(plot.title = element_text(size=9.5))

# plot popular vote share vs polling data for the non-incumbent party, 14 or more days until election
noninc_poll_far <- poll_result_far %>%
  filter(incumbent_party == FALSE) %>%
  ggplot(aes(x=avg_support, y=pv,
             label=year)) + 
  geom_text(size=2.5) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Vote share vs. Polling average (non-incumbent)") +
  xlab("Polling average over two weeks until election") +
  ylab("Non-incumbent party vote % 1968-2016") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.67), angle=90)) +
  theme(plot.title = element_text(size=9.5))

# plot all four graphs together
grid.arrange(inc_poll_close, noninc_poll_close, inc_poll_far, noninc_poll_far, ncol=2)

# convert dates into actual dates not strings
polls2016$startdate <- as.Date(polls2016$startdate, format = "%m/%d/%Y")
polls2016$enddate <- as.Date(polls2016$enddate, format = "%m/%d/%Y")

# use polling weight to average all of the polls together for Clinton and Trump in 2016 to get prediction
weightedpolls2016 <- polls2016 %>%
  group_by(state) %>%
  mutate(weight_pct = poll_wt / sum(poll_wt)) %>%
  mutate(weighted_clinton = weight_pct*rawpoll_clinton/100) %>%
  mutate(weighted_trump = weight_pct*rawpoll_trump/100) %>%
  summarize(weighted_clinton = sum(weighted_clinton), weighted_trump = sum(weighted_trump))

# add create new data frame that includes the statewide percentage of the vote (not 2-party popular vote)
share2016 <- pvstate %>%
  filter(year == 2016) %>%
  group_by(state) %>%
  mutate(d_vote = D / total) %>%
  mutate(r_vote = R / total) %>%
  select(state, d_vote, r_vote)

# join the data with the weighted poll predictions with voting data
df2016 <- weightedpolls2016 %>%
  left_join(share2016)

# change the labels of states to abbreviations for labeling purposes
df2016$state <- state.abb[match(df2016$state,state.name)]

# run regression for both parties comparing poll data to voting data
lm2016d <- lm(d_vote ~ weighted_clinton, data=df2016)
lm2016r <- lm(r_vote ~ weighted_trump, data=df2016)

df2016$weighted_clinton*lm2016d$coefficients[2]+lm2016d$coefficients[1]

# plot democratic vote share in all 50 states versus poll predictions
plot2016D <- df2016 %>%
  ggplot(aes(x=weighted_clinton, y=d_vote,
             label=state)) + 
  geom_text(size=2) +
  geom_smooth(method="lm", formula = y ~ x) +
  xlim(.2,.6) + ylim(.15,.65) +
  ggtitle("Vote share vs. Polling average 2016 (Clinton)") +
  xlab("Weighted polling average") +
  ylab("Vote share by state") +
  theme_bw() +
  theme(plot.title = element_text(size=9.5))

# plot republican vote share in all 50 states versus poll predictions
plot2016R <- df2016 %>%
  ggplot(aes(x=weighted_trump, y=r_vote,
             label=state)) + 
  geom_text(size=2) +
  geom_smooth(method="lm", formula = y ~ x) +
  xlim(.2,.6) + ylim(.2,.7) +
  ggtitle("Vote share vs. Polling average 2016 (Trump)") +
  xlab("Weighted polling average") +
  ylab("Vote share by state") +
  theme_bw() +
  theme(plot.title = element_text(size=9.5))

#plot both graphs next to each other
grid.arrange(plot2016D, plot2016R, ncol=2)

# find the average of the difference between reality and weighted polls in each of the swing states
mean(df2016$d_vote[df2016$state%in%swing_state_abb] - df2016$weighted_clinton[df2016$state%in%swing_state_abb])
mean(df2016$r_vote[df2016$state%in%swing_state_abb] - df2016$weighted_trump[df2016$state%in%swing_state_abb])

