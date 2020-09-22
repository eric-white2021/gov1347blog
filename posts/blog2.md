## Blog Post 2 - Economy
### September 21st, 2020

In this week's blog, I wanted to explore how the economy impacts election outcomes. I wanted to specifically explore how local and national economic indicators impacted the presidential races in Arizona, Florida, Pennsylvania, and Wisconsin, which are four of the key swing states in this election.
The economic indicators that I focused on were labor force participation rate & unemployment rate on the state level and inflation & Q2 GDP growth at the national level.
I chose to focus on local labor force participation rate and unemployment because I perceived these to be the best economic indicators available in the data set for judging the degree to which most people were integrated into their local economy. I chose inflation as an economic metric because some degree of inflation could be indicative of an economy that is performing well, but at the same time, especially high inflation could indicate that there are problems in the economy, as seen in the 1970s. I chose Q2 GDP growth as the short term economic indicators tend to play a role in voters' decision-making, as explained by [Achen and Bartles (2017)](https://muse-jhu-edu.ezp-prod1.hul.harvard.edu/chapter/2341029). I chose to avoid an indicator like the stock market because [84% of stocks are owned by the richest 10%](https://www.nytimes.com/2018/02/08/business/economy/stocks-economy.html) and the stock market is divorced from the day-to-day lives of many Americans.


## Key takeaways
1. Generally, there appears to be a positive relationship between incumbent party vote share and both **labor force participation rate** and **Q2 GDP growth**. There is a negative relationship between incumbent party vote share and **unemployment rate**. In general, the state-level data is more informative than the national data.
2. The impact of **inflation** is fairly inconclusive; this is probably because unless circumstances are particularly outstanding, inflation is usually fairly constant from year to year; it is also not something that is directly observed by regular voters unless circumstances are abnormal.
3. The predictive ability of the model is inconclusive. The model predicted *Arizona* fairly accurately for 2016, but Arizona was not as close to being a swing state at that time. It was off by a wide margin in *Pennsylvania* in particular for 2016.


## GDP Growth
As indicated above and proven by Achen & Bartels, there does seem to be a correlation between incumbent party vote share and GDP growth in the period right before the election. Q2 represents the months from April to June, and although it may have been more valuable to get the data right before the election, it is also reasonable to assume that some of the variables we use to measure the economy, such as GDP, are either lagging or leading indicators insofar as how they provide information on the lives of regular people. If GDP is low 5 months before an election, it is entirely within the realm of possibility that this impacts a family's financial situation far into the future and could therefore inform their voting choices.
The GDP growth could be particularly helpful as a predictor in the event that there is an economic downturn, as this could lead voters to [seek change](https://insight.kellogg.northwestern.edu/article/why-economic-crises-trigger-political-turnover-in-some-countries-but-not-others), thus hurting the incumbent party. This phenomenon is borne out in the data to a certain extent in the four states that I explored.
#### Plotting Incumbent Party vote share vs. GDP growth

![](https://github.com/eric-white2021/gov1347blog/blob/gh-pages/GDPpv2p.png?raw=true)

<sub><sup>Arizona in top left; Florida in top right; Pennsylvania in bottom left; Wisconsin in bottom right</sup></sub> 


## Inflation
The data gave inflation indexed to a given year (1983), not as a percentage over the last year. As a result, the inflation number has a very clear upward trend, which may skew the results. Nevertheless, inflation does not seem to be particularly correlated with incumbent party success. In the two states in which the model performed best (Arizona and Florida), the relationship appears to be non-existent, whereas there is some positive trend in Pennsylvania and Wisconsin, where the model performed poorly. In the future, I think it makes sense to exclude inflation from the prediction, as that is more of a long-term phenonmenon and is only relevant to the average voter (and to the economy as a whole) when the rate of inflation is particularly anomalous.

![](https://github.com/eric-white2021/gov1347blog/blob/gh-pages/Inflationpv2p.png?raw=true)

<sub><sup>Arizona in top left; Florida in top right; Pennsylvania in bottom left; Wisconsin in bottom right</sup></sub>

## Unemployment rate
The unemployment rate, on the whole, is probably a better representation of how individuals are experiencing the economy than either of the indicators explored earlier. This is not to say that the unemployment rate is a perfect statistic, but in times of high unemployment (such as we are facing today), many more people tend to suffer, and as a result, the high unemployment could reflect poorly on elected officials. As expected, there is a relatively clear trend in favor of the challenging party in an election with high unemployment numbers. I arguably should have explored what the national unemployment numbers can tell us about state-wide races, but I did not want to include two variables that I knew would be highly correlated in my regression and I wanted to focus particularly on the statewide indicators. Looking particularly at Pennsylvania and Wisconsin, there is a clear trend and the error bands around the regression line are narrower, implying that there is a more significant effect in these states. In Arizona and Florida, there is less of a compelling trend, but the error bands are wider, which could be reflective of the fact that Arizona was [not really a swing state in the past](https://www.270towin.com/states/Arizona) and [Florida tended to vote Republican as well](https://www.270towin.com/states/Florida).

![](https://github.com/eric-white2021/gov1347blog/blob/gh-pages/URpv2p.png?raw=true)

<sub><sup>Arizona in top left; Florida in top right; Pennsylvania in bottom left; Wisconsin in bottom right</sup></sub>

## Labor force participation rate
One would assume that when the labor force participation rate is higher, citizens feel more invested in their home state's economy and are thus more secure and satisfied economically. This is certainly a simplification, but that phenomenon could explain why there is a relatively clear positive trend in that direction looking at the data. In Arizona, Pennsylvania, and Wisconsin, the trend is noticeably positive and the error bands are smaller than on other graphs. Though it is hard to say that the results are statistically significant, the trend is still worth noting and incorporating into a model. Again, it probably would have been helpful to include national data as a point of comparison, but the state data intuitively seemed like it would be more useful to explore when thinking about a statewide race. 


![](https://github.com/eric-white2021/gov1347blog/blob/gh-pages/LFPRpv2p.png?raw=true)

<sub><sup>Arizona in top left; Florida in top right; Pennsylvania in bottom left; Wisconsin in bottom right</sup></sub>

## Prediction results

|           | Arizona                     | Florida                     | Pennsylvania                  | Wisconsin                     |
|-----------|-----------------------------|-----------------------------|-------------------------------|-------------------------------|
| Actual    | 51.89%-48.11% Trump victory | 50.62%-49.38% Trump victory | 50.38%-49.62% Trump victory   | 50.41%-49.59% Trump victory   |
| Predicted | 52.57%-47.43% Trump victory | 54%-46% Trump victory       | 59.38%-40.62% Clinton victory | 54.81%-45.19% Clinton victory |
| Error     | 0.68                        | 3.38                        | 9.75                          | 5.22                          |

In general, the prediction results were inconclusive. I would like to explore what the result would be if I excluded the inflation variable, as that seemed to add additional unnecessary noise. In all states except Pennsylvania, the most important explanatory variable  (i.e. correlated with the largest change in vote share, all else held constant) was **Q2 GDP** growth when running a multivariate regression with all of the aboe explanatory variables.
