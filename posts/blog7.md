## Blog Post 7 - COVID & Shocks
### October 26th, 2020

In this week's blog, I wanted to explore how COVID-19 might impact the race this year. This is not a particularly easy task because it is so unprecedented, but the pandemic will unquestionably impact the race, not only in terms of how voters perceive of the two candidates, but also how voters actually go about voting as well, as COVID is sure to impact turnout in an unpredictable manner.

## Key takeaways
1. It does not appear that there is much of an effect of increased COVID-19 cases per capita on a change in Trump's support from 2016 to 2020.
2. Population density makes it hard to disaggregate the relationship between COVID and voting, but there may be evidence that Democratic-leaning areas are hit harder than Republican-leaning areas on average, though there are many outliers, like South Dakota.
3. Decreased turnout tends to negatively impact Democrats; my model indicates that if COVID decreases turnout, Trump will be more likely to win, but he is still at a large enough polling deficit that it will be hard for him to make up significant ground

## Nationwide effect of COVID
Using COVID data and polling data, I first looked into how President Trump might be performing in certain states relative to his performance last election cycle, and to see if certain underperformance tracked with COVID cases and COVID deaths. 
Specifically, I used FiveThirtyEight polling data to examine how Trump is polling in the states for which there is relatively recent data. There could certainly be some problems with how I aggregated polls, as I took a simple average of all of the high quality (graded B or better) polls in the last 40 days, and found Trump's two-party popular vote share. I then compared that value to the two-party popular vote share he received in 2016. Because Trump has seen a decrease in his performance (at least according to the polling) across the board, this must be taken into account, so I then normalized the difference in performance between 2020 and 2016 in each state by taking subtracting off the mean difference from each state.
This can be used to then examine the excess over or underperformance on a state-by-state basis and compare it to the state's handling of COVID-19. I looked at both cases per capita and deaths per capita and ran a regression to see if there was any compelling relationship between these two variables.

![](https://github.com/eric-white2021/gov1347blog/blob/gh-pages/covid_compare_trump.png?raw=true)

The relationship is not particularly strong. There are a number of outliers, such as California and South Dakota, which are very far from the average in terms of Trump's underperformance from 2016, and New Jersey, where the deaths per capita are very high. On the whole, there is a weak negative correlation when looking at cases, indicating that more cases is correlated with Trump underperforming his 2016 result by a greater margin, but the relationship is not strong. Looking at death per capita, there is actually a positive relationship, which would indicate that we would actually predict Trump to perform better relative to 2016 in states with higher death rates, which is not intuitive. These relationships still exist in broadly the same manner when we do not make the election-over-election difference to have mean 0.

One interesting phenomenon is that these relationships flip when simply looking at the polling results for this cycle; there is a positive relationship between cases per capita and Trump's two-party popular vote share, but a negative relationship between death and two party vote share. This could be because many of the states that had early spikes, such as Massachusetts and New Jersey, are out of reach for Trump, whereas some of the states that have seen cases rise rapidly in recent weeks, such as South Dakota, are strong Trump states and have not had time for the death rates to level out based on the case load.

![](https://github.com/eric-white2021/gov1347blog/blob/gh-pages/covid_polling_trump.png?raw=true)


## Statewide COVID trends & voting
I chose to look at Arizona to see if I could discern any meaningful trends by examining voting patterns by county and COVID death concentration. Arizona is an imporant state this election but it is also one of the few states that had good county-wide COVID data, as the dataset as a whole was fairly sparse. Looking at the graph below, it is hard to tell whether there is a real trend. COVID tends to concentrate around urban and more dense areas, and those areas tend to vote Democratic, so it is difficult to make any judgement on what the trends are based on this data and we would probably have to acquire more data about transmission of the virus in order to disentangle the relationship between density with the two variables of interest.

![](https://github.com/eric-white2021/gov1347blog/blob/gh-pages/az_cov.png?raw=true)


## Turnout and updated model for swing states using COVID to suppress turnout
In this model, I assumed that COVID-19 would decrease turnout. This is a hard assumption to verify, as although fewer people will be voting in person thanks to the pandemic, it may be the case that options to vote by mail not only make up the difference of in-person turnout, but actually increases turnout because the cost of voting is lowered for some people who do not have the ability to wait in line or skip work on election day. I simulated turnout for 100 elections based on past data in each state, then discounted the 25 smallest turnout rates by a number that was a function of the number of COVID cases per capita in the state. For the swing state that had the most COVID cases per capita relative to the nationwide average (Iowa), the turnout in these 25 scenarios was discounted by a factor of 0.85; for the swing state with the fewest COVID cases per capita relative to the national average (Pennsylvania), the turnout was not discounted. 

Higher turnout tends to benefit Democratic candidates all else equal, so states such as Pennsylvania, Ohio, and Michigan, which are comparatively not as overwhelmingly imapcted, do not get biased toward Republicans in the way that Iowa, Wisconsin, and Florida do.

This model predicts a narrow Biden victory (assuming all other states go as expected), with Biden reaching at least 278 electoral votes and Trump reaching at least 258, with the remaining two being from the Maine and Nebraska congressional districts, which are swing districts but do not have the same level of data available and thus are harder to predict with this model.

![](https://github.com/eric-white2021/gov1347blog/blob/gh-pages/swing_covid_pred.png?raw=true)


