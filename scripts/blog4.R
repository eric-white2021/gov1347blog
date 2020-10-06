library(tidyverse)
library(ggplot2)
library(usmap)
library(gridExtra)

## set working directory here
setwd("Downloads")

# read in data
# COVID data from https://taggs.hhs.gov/coronavirus; https://covid.cdc.gov/covid-data-tracker/#cases_casesper100k
# population data from https://www2.census.gov/programs-surveys/popest/tables/2010-2019/state/totals/nst-est2019-01.xlsx
awards <- read_csv("COVID_awards.csv")
cases <- read_csv("COVID_cases.csv")
polls2020 <- read_csv("polls_2020.csv")
approval <- read_csv("approval_gallup_1941-2020.csv")
econ <- read_csv("econ.csv")
voting <- read_csv("popvote_1948-2016.csv")
pvstate <- read_csv("popvote_bystate_1948-2016.csv")
grants <- read_csv("fedgrants_bystate_1988-2008.csv")


## TRUMP APPROVAL / TIME FOR CHANGE

# plot Trump approval rating
approval %>% 
  filter(president=="Donald Trump") %>%
  mutate(net = approve - disapprove) %>%
  ggplot(aes(poll_enddate, net,color=net)) + geom_line() +
  scale_colour_gradient2(low = "red", mid = "black" , high = "green", midpoint=-8) +
  labs(title = "Trump Net Approval over time", x = "Date", y = "Net Approval Rating") +
  theme_bw()

# get incumbent party and two-party popular vote share
inc <- voting %>%
  filter(year >= 1948 & winner == TRUE) %>%
  select(year, incumbent, pv2p) 

# get 2nd quarter GDP data and add incumbent data
gdp <- econ %>%
  filter(year >= 1948 & year %% 4 == 0 & quarter == 2) %>%
  left_join(inc) %>%
  select(year, GDP_growth_qt, incumbent, pv2p)

#update data frame to show that Trump is incumbent
gdp$incumbent[gdp$year==2020] = TRUE

# combine the data frames to get information for time for change model
comb <- net_approval%>%
  left_join(gdp) %>%
  select(year, president, incumbent, net, GDP_growth_qt, pv2p)

# remove Trump data to run regression on past data
past_comb <- comb[-c(17), ]

# run regression and estimate coefficients to get prediction
t4c <- lm(pv2p ~ incumbent + net + GDP_growth_qt, past_comb)
coef <- as.numeric(t4c$coefficients)
as.numeric(comb[c(17), ][3])*coef[2]+as.numeric(comb[c(17), ][4])*coef[3]+as.numeric(comb[c(17), ][5])*coef[4]+coef[1]
summary(t4c)


## STATE SPENDING

# filter by incumbent party; push year forward by 4 because incumbent is based on who won last election
inc_party <- voting %>%
  filter(winner==TRUE & year >= 1980) %>%
  mutate(year = year + 4) %>%
  mutate(inc = (party == "republican")) %>%
  select(year, inc)

# spending changes versus incumbent performance over time
spending_change <- grants %>%
  filter((state_year_type == "swing + election year" | state_year_type == "swing + nonelection") & (year %% 4 == 0 | year %% 4 == 3)) %>%
  mutate(state = state.name[match(state_abb,state.abb)]) %>%
  arrange(state, year) %>%
  select(state_abb, state, year, elxn_year, grant_mil) %>%
  group_by(state) %>%
  mutate(diff = c(0,diff(grant_mil))) %>%
  filter(elxn_year == 1 & year > 1984) %>%
  left_join(pvstate) %>%
  left_join(inc_party) %>%
  mutate(inc_pv2p = inc*R_pv2p+(1-inc)*D_pv2p) %>%
  group_by(state, year) %>%
  mutate(lab = paste(state_abb, " ('", substr(toString(year),3,4), ")", sep="")) %>%
  select(state_abb,state, year, lab, grant_mil, diff, inc_pv2p)

# plot over all years the effect of spending on vote share in swing states
plot <- spending_change %>%
  ggplot(aes(x=diff, y=inc_pv2p,
             label=lab)) + 
  geom_text(size=3) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Incumbent party vote share vs. Change in spending") + 
  ylab("Two-party popular vote share (1988-2008)") +
  xlab("Year over year change in spending in swing states") +
  theme_bw()

# plot the effect of spending on vote share in swing states in 1988
plot_88 <- spending_change %>%
  filter(year == 1988) %>%
  ggplot(aes(x=diff, y=inc_pv2p,
             label=state_abb)) + 
  geom_text(size=1.5) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Incumbent party vote share vs. Change in spending") + 
  ylab("Two-party popular vote share (1988)") +
  xlab("Year over year change in spending in swing states") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.5), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.5), angle=0)) +
  theme(plot.title = element_text(size=5))

# plot the effect of spending on vote share in swing states in 1992
plot_92 <- spending_change %>%
  filter(year == 1992) %>%
  ggplot(aes(x=diff, y=inc_pv2p,
             label=state_abb)) + 
  geom_text(size=1.5) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Incumbent party vote share vs. Change in spending") + 
  ylab("Two-party popular vote share (1992)") +
  xlab("Year over year change in spending in swing states") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.5), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.5), angle=0)) +
  theme(plot.title = element_text(size=5))

# plot the effect of spending on vote share in swing states in 1996
plot_96 <- spending_change %>%
  filter(year == 1996) %>%
  ggplot(aes(x=diff, y=inc_pv2p,
             label=state_abb)) + 
  geom_text(size=1.5) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Incumbent party vote share vs. Change in spending") + 
  ylab("Two-party popular vote share (1996)") +
  xlab("Year over year change in spending in swing states") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.5), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.5), angle=0)) +
  theme(plot.title = element_text(size=5))

# plot the effect of spending on vote share in swing states in 2000
plot_00 <- spending_change %>%
  filter(year == 2000) %>%
  ggplot(aes(x=diff, y=inc_pv2p,
             label=state_abb)) + 
  geom_text(size=1.5) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Incumbent party vote share vs. Change in spending") + 
  ylab("Two-party popular vote share (2000)") +
  xlab("Year over year change in spending in swing states") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.5), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.5), angle=0)) +
  theme(plot.title = element_text(size=5))

# plot the effect of spending on vote share in swing states in 2004
plot_04 <- spending_change %>%
  filter(year == 2004) %>%
  ggplot(aes(x=diff, y=inc_pv2p,
             label=state_abb)) + 
  geom_text(size=1.5) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Incumbent party vote share vs. Change in spending") + 
  ylab("Two-party popular vote share (2004)") +
  xlab("Year over year change in spending in swing states") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.5), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.5), angle=0)) +
  theme(plot.title = element_text(size=5))

# plot the effect of spending on vote share in swing states in 2008
plot_08 <- spending_change %>%
  filter(year == 2008) %>%
  ggplot(aes(x=diff, y=inc_pv2p,
             label=state_abb)) + 
  geom_text(size=1.5) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("Incumbent party vote share vs. Change in spending") + 
  ylab("Two-party popular vote share (2008)") +
  xlab("Year over year change in spending in swing states") +
  theme_bw() +
  theme(axis.title.y=element_text(size=rel(0.5), angle=90)) +
  theme(axis.title.x=element_text(size=rel(0.5), angle=0)) +
  theme(plot.title = element_text(size=5))

# show all graphs together on one plot
grid.arrange(plot_88,plot_92,plot_96,plot_00,plot_04,plot_08, ncol=3)

## COVID and polling

# used to get rid of extraneous data
awards <- awards[-c(53:58), ]
cases <- cases[-c(36, 49, 55), ]

# add state relief data to data frame
df <- awards %>%
  group_by(State) %>%
  mutate(awards_pc = Total / Population) %>%
  mutate(abb = state.abb[match(State,state.name)]) %>%
  left_join(cases) %>%
  rename(award_count=`Award Count`, case100000 = `Case Rate per 100000`) %>%
  select(State, abb, award_count, awards_pc, case100000)

# get rid of DC/PR
df <- df[-c(9,40), ]

# df[-c(9,40), ]$awards_pc
# which(df$State == "District of Columbia")
# which(df$State == "Puerto Rico")

# # change DC/PR abbreviation
# df$abb[df$State == "District of Columbia"] = "DC"
# df$abb[df$State == "Puerto Rico"] = "PR"
  
# plot cases vs spending
cases_vs_spending <- df %>%
  ggplot(aes(x=awards_pc, y=case100000,
             label=abb)) + 
  geom_text(size=3) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("COVID Cases vs. COVID awards") + 
  ylab("COVID-19 Cases by state (per 100,000)") +
  xlab("COVID per capita federal awards") +
  theme_bw()

# plot cases vs spending without Alaska outlier
cases_vs_spending_noAK <- df %>%
  filter(State!="Alaska") %>%
  ggplot(aes(x=awards_pc, y=case100000,
             label=abb)) + 
  geom_text(size=3) +
  geom_smooth(method="lm", formula = y ~ x) +
  ggtitle("COVID Cases vs. COVID awards") + 
  ylab("COVID-19 Cases by state (per 100,000)") +
  xlab("COVID per capita federal awards") +
  theme_bw()

# create data frame without Alaska outlier
no_AK <- df %>% filter(State!="Alaska")

# fit linear models (stage 1 of 2SLS)
fit <- lm(case100000 ~ awards_pc, data=df)
fit_noAK <- lm(case100000 ~ awards_pc, data=no_AK)

# add residuals to data frame
df <- df %>%
  group_by(State) %>%
  mutate(resid = awards_pc-as.numeric(fit$coefficients[1])+as.numeric(fit$coefficients[2])*awards_pc)

# add residuals to data frame without Alaska outlier
no_AK <- no_AK %>%
  group_by(State) %>%
  mutate(resid = awards_pc-as.numeric(fit_noAK$coefficients[1])+as.numeric(fit_noAK$coefficients[2])*awards_pc)

# plot residuals
df %>% 
  ggplot(aes(x=case100000, y=resid,
           label=abb)) + 
  geom_text(size=3) +
  ggtitle("Regression residual") + 
  xlab("COVID-19 Cases by state (per 100,000)") +
  ylab("Residual") +
  theme_bw()

# get 10 states that are disproportionately not getting aid per the model
df$State[df$resid%in%tail(sort(df$resid),10)]


## Poll aggregtion (not done with the COVID modeling, that is returned to later)

# establish system to letter grades into numerical values
grade <- data.frame("grades" = unique(polls2020$fte_grade), "val" = c(.1, 0, .8, .5, .7, .4, .05, .11, .9, .49, .09, .06, 0.01, 0.02))

# get rid of NA
polls2020$fte_grade[is.na(polls2020$fte_grade)]="F"

# go through data and turn letter grades into numerical values
vals = c(.1, 0.001, .8, .5, .7, .4, .05, .11, .9, .49, .09, .06, 0.002, 0.005)
for (i in c(1:length(unique(polls2020$fte_grade)))){
  polls2020$fte_grade[polls2020$fte_grade == unique(polls2020$fte_grade)[i]] = as.numeric(vals[i])
}

# turn into numbers not string
polls2020$fte_grade = as.numeric(polls2020$fte_grade)

# Trump weighted polling average dataframe
polling_T <- polls2020 %>%
  filter(!is.na(state) & answer == "Trump") %>%
  mutate(daysout = -1*as.numeric(as.Date(end_date, format = "%m/%d/%Y")-as.Date(election_date, format = "%m/%d/%Y"))) %>%
  mutate(weight = fte_grade*(1.5*min(daysout)/daysout))%>%
  group_by(state) %>%
  mutate(weight = weight/sum(weight)) %>%
  arrange(state) %>%
  select(state, poll_id, fte_grade, daysout, weight, answer, pct)

# Biden weighted polling average dataframe
polling_B <- polls2020 %>%
  filter(!is.na(state) & answer == "Biden") %>%
  mutate(daysout = -1*as.numeric(as.Date(end_date, format = "%m/%d/%Y")-as.Date(election_date, format = "%m/%d/%Y"))) %>%
  mutate(weight = fte_grade*(1.5*min(daysout)/daysout))%>%
  group_by(state) %>%
  mutate(weight = weight/sum(weight)) %>%
  arrange(state) %>%
  select(state, poll_id, fte_grade, daysout, weight, answer, pct)

# combine sum of weighted polls to get final result for each state for Trump
results_T <- polling_T %>%
  group_by(state) %>%
  summarise(result_rep = sum(weight*pct))

# combine sum of weighted polls to get final result for each state for Biden
results_B <- polling_B %>%
  group_by(state) %>%
  summarise(result_dem = sum(weight*pct))

# total results data frame and calculation of 2 party vote share
results <- results_T %>%
  left_join(results_B) %>%
  group_by(state) %>%
  mutate(pv2pR = 100 *result_rep / (result_rep+result_dem)) %>%
  mutate(pv2pD = 100 * result_dem / (result_rep+result_dem)) %>%
  mutate(margin = pv2pR - pv2pD)


# determine which states were not polled for and remove Illinois, Nebraska, Rhode Island, South Dakota, Wyoming
clean_results <- results[-c(19, 20, 28, 29), ]
`%notin%` <- Negate(`%in%`)
state.name[state.name%notin%clean_results$state]

# create new data frame with manipulated results and a new column that is true if Trump is predicted to win that state
holder <- clean_results %>%
  select(state, margin) %>%
  mutate(flag = (margin > 0))

# electoral college values for the states that were polled for           
electors = c(9, 3, 11, 6, 55, 9, 7, 3, 29, 16, 4, 4, 11, 6, 6, 8, 8, 4, 10, 
             11, 16, 10, 6, 10, 3, 6, 4, 14, 5, 29, 15, 3, 18, 7, 7, 20, 9, 
             11, 38, 6, 3, 13, 12, 5, 10)

# get results for ME/NE congressional districts
results$state[results$state%notin%state.name]
results$margin[results$state%notin%state.name]

# add in Nebraska, South Dakota, Wyoming, and NE-01 that Trump won to get his delegate count
Trump_delegates <- sum(holder$flag*electors)+5+3+3+1
# get Biden's delegate count
Biden_delegates <- 538 - Trump_delegates


# # Biden wins 351 to 187

# plot map of results; unpolled states not listed
plot_usmap(data = clean_results, regions = "states", values = "margin", labels = TRUE) +
  scale_fill_gradient2(
    high = "red", 
    #mid = "purple",
    mid = "white",
    low = "blue", 
    breaks = c(-40,-20,0,20,40), 
    limits = c(-40,40),
    name = "win margin"
  ) +
  theme_void() + 
  labs(title = "Win Margin By State, 2020 US Presidential Election")



# list of states with data across multiple data frames
state_list <- unique(c(results$state[results$state%in%df$State],df$State[df$State%in%results$state]))

# poll results in states we have data for; with and without Alaska
poll_res <- results$pv2pR[results$state%in%state_list]
poll_res_noAK <- poll_res[clean_results$state != "Alaska"]

# 1st stage of 2SLS predicting cases from initial regression of cases on spending
case_pred <- as.numeric(fit$coefficients[1])+as.numeric(fit$coefficients[2])*df$awards_pc[df$State%in%state_list]
case_pred_noAK <- as.numeric(fit_noAK$coefficients[1])+as.numeric(fit_noAK$coefficients[2])*no_AK$awards_pc[no_AK$State%in%state_list]

# 2nd stage of 2SLS fitting model to predicted data of cases based on spending
iv <- lm(poll_res ~ case_pred)
iv_noAK <- lm(poll_res_noAK ~ case_pred_noAK)

# create data frame
z <- data.frame("cases"=case_pred, "polls"=poll_res)
z_noAK <- data.frame("cases_noAK"=case_pred_noAK, "polls_noAK"=poll_res_noAK)

# plot results for with and without Alaska
ggplot(z, aes(x=cases, y=polls)) + geom_point()
ggplot(z_noAK, aes(x=cases_noAK, y=polls_noAK)) + geom_point() + 
  geom_smooth(method="lm", formula = y ~ x) + theme_bw() + 
  labs(title = "2SLS Polling vs. COVID spending (some states excluded)", x = "Predicted cases based on spending", y = "State Polling predictions")
  
  
