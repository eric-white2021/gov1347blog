library(tidyverse)
library(ggplot2)
library(usmap)
library(gridExtra)

## set working directory here
setwd("Downloads")

## read csv data
popvote <- read_csv("popvote_1948-2016.csv")
pvstate <- read_csv("popvote_bystate_1948-2016.csv")
econ <- read_csv("econ.csv")
local <- read_csv("local.csv")

# create list of swing states
swing_states <- c("Arizona", "Florida", "Pennsylvania", "Wisconsin")

# changes names of column to make the merging of the data easier
colnames(local)[3] <- "state"
colnames(local)[4] <- "year"



# combine the national economic data and swing state voting data into a dataframe for years 1976 and onward
econ_data <- pvstate %>% 
  filter(state%in%swing_states) %>%
  select(state, year, D_pv2p, R_pv2p) %>%
  left_join(econ %>% filter(quarter == 2)) %>% 
  select(state, year, D_pv2p, R_pv2p, GDP_growth_qt, inflation) %>%
  filter(year >= 1976)

# create incumbent vote share column
econ_data$inc_pv2p = econ_data$D_pv2p
econ_data$inc_pv2p[econ_data$year==1984] = econ_data$R_pv2p[econ_data$year==1984]
econ_data$inc_pv2p[econ_data$year==1988] = econ_data$R_pv2p[econ_data$year==1988]
econ_data$inc_pv2p[econ_data$year==1992] = econ_data$R_pv2p[econ_data$year==1992]
econ_data$inc_pv2p[econ_data$year==2004] = econ_data$R_pv2p[econ_data$year==2004]


# filter the local economic data in swing states to look at only election years from 1976 onward using the economic data from June (last month of Q2)
local_data <- local %>%
  filter((year %% 4) == 0 & year >= 1976 & Month == "06" & state%in%swing_states) %>%
  select(state, year, Unemployed_prce, LaborForce_prct)

# join together the local economic data, national economic data, and electoral data into one dataframe
data <- econ_data %>%
  left_join(local_data) %>%
  select(state, year, inc_pv2p, GDP_growth_qt, inflation, Unemployed_prce, LaborForce_prct)


# organize the plot for regressing Incumbent party vote share against GDP growth in Q2 for Arizona
gdp_az <- data %>%
  filter(state == "Arizona", year!="2016") %>%
  ggplot(aes(x=GDP_growth_qt, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Second quarter GDP growth") +
  ylab("Incumbent party vote % 1976-2012 (AZ)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against GDP growth in Q2 for Florida
gdp_fl <- data %>%
  filter(state == "Florida", year!="2016") %>%
  ggplot(aes(x=GDP_growth_qt, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Second quarter GDP growth") +
  ylab("Incumbent party vote % 1976-2012 (FL)") +
  theme_bw() + 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against GDP growth in Q2 for Pennsylvania
gdp_pa <- data %>%
  filter(state == "Pennsylvania", year!="2016") %>%
  ggplot(aes(x=GDP_growth_qt, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Second quarter GDP growth") +
  ylab("Incumbent party vote % 1976-2012 (PA)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against GDP growth in Q2 for Wisconsin
gdp_wi <- data %>%
  filter(state == "Wisconsin", year!="2016") %>%
  ggplot(aes(x=GDP_growth_qt, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Second quarter GDP growth") +
  ylab("Incumbent party vote % 1976-2012 (WI)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# plot all four graphs for vote share vs GDP together
grid.arrange(gdp_az, gdp_fl, gdp_pa, gdp_wi, ncol=2)


# organize the plot for regressing Incumbent party vote share against inflation in quarter 2 for Arizona
inf_az <- data %>%
  filter(state == "Arizona", year!="2016") %>%
  ggplot(aes(x=inflation, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Inflation (pp)") +
  ylab("Incumbent party vote % 1976-2012 (AZ)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against inflation in quarter 2 for Florida
inf_fl <- data %>%
  filter(state == "Florida", year!="2016") %>%
  ggplot(aes(x=inflation, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Inflation (pp)") +
  ylab("Incumbent party vote % 1976-2012 (FL)") +
  theme_bw() + 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against inflation in quarter 2 for Pennsylvania
inf_pa <- data %>%
  filter(state == "Pennsylvania", year!="2016") %>%
  ggplot(aes(x=inflation, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Inflation (pp)") +
  ylab("Incumbent party vote % 1976-2012 (PA)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against inflation in quarter 2 for Wisconsin
inf_wi <- data %>%
  filter(state == "Wisconsin", year!="2016") %>%
  ggplot(aes(x=inflation, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Inflation (pp)") +
  ylab("Incumbent party vote % 1976-2012 (WI)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# plot all four graphs for vote share vs inflation together
grid.arrange(inf_az, inf_fl, inf_pa, inf_wi, ncol=2)


# organize the plot for regressing Incumbent party vote share against unemployment rate in June in Arizona
ur_az <- data %>%
  filter(state == "Arizona", year!="2016") %>%
  ggplot(aes(x=Unemployed_prce, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Unemployment Rate (pp)") +
  ylab("Incumbent party vote % 1976-2012 (AZ)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against unemployment rate in June in Florida
ur_fl <- data %>%
  filter(state == "Florida", year!="2016") %>%
  ggplot(aes(x=Unemployed_prce, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Unemployed Rate (pp)") +
  ylab("Incumbent party vote % 1976-2012 (FL)") +
  theme_bw() + 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against unemployment rate in June in Pennsylvania
ur_pa <- data %>%
  filter(state == "Pennsylvania", year!="2016") %>%
  ggplot(aes(x=Unemployed_prce, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Unemployed Rate (pp)") +
  ylab("Incumbent party vote % 1976-2012 (PA)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against unemployment rate in June in Wisconsin
ur_wi <- data %>%
  filter(state == "Wisconsin", year!="2016") %>%
  ggplot(aes(x=Unemployed_prce, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Unemployed Rate (pp)") +
  ylab("Incumbent party vote % 1976-2012 (WI)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# plot all four graphs for vote share vs state unemployment rate together
grid.arrange(ur_az, ur_fl, ur_pa, ur_wi, ncol=2)


# organize the plot for regressing Incumbent party vote share against labor force participation rate in June in Arizona
lfpr_az <- data %>%
  filter(state == "Arizona", year!="2016") %>%
  ggplot(aes(x=LaborForce_prct, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Labor Force Participation Rate (pp)") +
  ylab("Incumbent party vote % 1976-2012 (AZ)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against labor force participation rate in June in Arizona
lfpr_fl <- data %>%
  filter(state == "Florida", year!="2016") %>%
  ggplot(aes(x=LaborForce_prct, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Labor Force Participation Rate (pp)") +
  ylab("Incumbent party vote % 1976-2012 (FL)") +
  theme_bw() + 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against labor force participation rate in June in Arizona
lfpr_pa <- data %>%
  filter(state == "Pennsylvania", year!="2016") %>%
  ggplot(aes(x=LaborForce_prct, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Labor Force Participation Rate (pp)") +
  ylab("Incumbent party vote % 1976-2012 (PA)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# organize the plot for regressing Incumbent party vote share against labor force participation rate in June in Arizona
lfpr_wi <- data %>%
  filter(state == "Wisconsin", year!="2016") %>%
  ggplot(aes(x=LaborForce_prct, y=inc_pv2p,
             label=year)) + 
  geom_text() +
  geom_smooth(method="lm", formula = y ~ x) +
  xlab("Labor Force Participation Rate (pp)") +
  ylab("Incumbent party vote % 1976-2012 (WI)") +
  theme_bw()+ 
  theme(axis.title.y=element_text(size=rel(0.67), angle=90))

# plot all four graphs for vote share vs state labor force participation rate together
grid.arrange(lfpr_az, lfpr_fl, lfpr_pa, lfpr_wi, ncol=2)


# filter all the data for Arizona, not including 2016
arizona <-  data %>%
  filter(state == "Arizona", year!="2016")
# filter all the data for Florida, not including 2016
florida <-  data %>%
  filter(state == "Florida", year!="2016")
# filter all the data for Pennsylvania, not including 2016
pennsylvania <-  data %>%
  filter(state == "Pennsylvania", year!="2016")
# filter all the data for Wisconsin, not including 2016
wisconsin <-  data %>%
  filter(state == "Wisconsin", year!="2016")


# filter all the data for Arizona in 2016
arizona_2016 <-  data %>%
  filter(state == "Arizona", year=="2016")
# filter all the data for Florida in 2016
florida_2016 <-  data %>%
  filter(state == "Florida", year=="2016")
# filter all the data for Pennsylvania in 2016
pennsylvania_2016 <-  data %>%
  filter(state == "Pennsylvania", year=="2016")
# filter all the data for Wisconsin in 2016
wisconsin_2016 <-  data %>%
  filter(state == "Wisconsin", year=="2016")

# fit voting data for 1976 to 2012 to the four explanatory variables given for Arizona
fit_az <- lm(inc_pv2p ~ GDP_growth_qt + inflation + Unemployed_prce + LaborForce_prct, data = arizona)
summary(fit_az)

# fit voting data for 1976 to 2012 to the four explanatory variables given for Florida
fit_fl <- lm(inc_pv2p ~ GDP_growth_qt + inflation + Unemployed_prce + LaborForce_prct, data = florida)
summary(fit_fl)

# fit voting data for 1976 to 2012 to the four explanatory variables given for Pennsylvania
fit_pa <- lm(inc_pv2p ~ GDP_growth_qt + inflation + Unemployed_prce + LaborForce_prct, data = pennsylvania)
summary(fit_pa)

# fit voting data for 1976 to 2012 to the four explanatory variables given for Wisconsin
fit_wi <- lm(inc_pv2p ~ GDP_growth_qt + inflation + Unemployed_prce + LaborForce_prct, data = wisconsin)
summary(fit_wi)

#using data fitting results, predict 2016 results in swing states
pred_az <- as.numeric(sum(fit_az$coefficients[2:5]*as.data.frame(arizona_2016[4:7]))+fit_az$coefficients[1])
pred_fl <- as.numeric(sum(fit_fl$coefficients[2:5]*as.data.frame(florida_2016[4:7]))+fit_fl$coefficients[1])
pred_pa <- as.numeric(sum(fit_pa$coefficients[2:5]*as.data.frame(pennsylvania_2016[4:7]))+fit_pa$coefficients[1])
pred_wi <- as.numeric(sum(fit_wi$coefficients[2:5]*as.data.frame(wisconsin_2016[4:7]))+fit_wi$coefficients[1])

# determine absolute error of prediction
error_az <- abs(arizona_2016$inc_pv2p - pred_az)
error_fl <- abs(florida_2016$inc_pv2p - pred_fl)
error_pa <- abs(pennsylvania_2016$inc_pv2p - pred_pa)
error_wi <- abs(wisconsin_2016$inc_pv2p - pred_wi)
