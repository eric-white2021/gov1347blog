## Post-election Reflection
### November 23rd, 2020



## Key takeaways
1. My model correctly predicted 48 of the 50 states and missed 1 Congressional district as well
2. 
3. 

## Model recap

![](https://github.com/eric-white2021/gov1347blog/blob/gh-pages/final/2020pred_1.png?raw=true)

My model was a weighted ensemble of polls and fundamental data about each state. The fundamentals part of the model considered the percentage of the state population that is white, black, and over age 65, as well as the unemployment average for that state for 2020. The polls aspect of my model, which was weighted overwhlemingly more than the fundamentals, weighed the sample size, recency, and quality of the polls to create an average of polling in each state. When polling data was not available, 2016 election performance was used as a proxy, as this tends to be an effective way to predict the result, particularly in safe states that are not likely to see a massive partisan swing. Above is my map predicting which candidate would win each state. My predictions for the two-party popular vote share in each state are given below, with italicized states being ones that I expected to be within 10 points and bold states being ones that I got wrong in my prediction.

**State**|**Biden**|**Trump**|**Margin**
:-----:|:-----:|:-----:|:-----:
Alabama|38.59333|61.40667|-22.8133335
Alaska|44.9704|55.0296|-10.0592015
*Arizona*|52.29683|47.70317|4.5936599
Arkansas|32.60462|67.39538|-34.7907626
California|60.00608|39.99392|20.012162
Colorado|66.29099|33.70901|32.581973
Connecticut|65.9992|34.0008|31.9984097
Delaware|54.77868|45.22132|9.5573532
***Florida***|52.33308|47.66692|4.6661634
***Georgia***|49.57594|50.42406|-0.8481217
Hawaii|69.45923|30.54077|38.9184529
Idaho|27.23193|72.76807|-45.5361431
*Illinois*|52.78234|47.21766|5.5646771
*Indiana*|46.2933|53.7067|-7.4134013
*Iowa*|47.7414|52.2586|-4.5171941
*Kansas*|47.17733|52.82267|-5.6453317
Kentucky|38.38104|61.61896|-23.2379185
Louisiana|37.9485|62.0515|-24.1029913
Maine|58.13816|41.86184|16.2763246
Maine CD-1|59.61712|40.38288|19.23424
***Maine CD-2***|51.58011|48.41989|3.160226
Maryland|63.26843|36.73157|26.5368671
Massachusetts|68.41095|31.58905|36.8219098
*Michigan*|53.829|46.171|7.6580061
*Minnesota*|50.15969|49.84031|0.3193855
Mississippi|41.55102|58.44898|-16.8979535
Missouri|45.40799|54.59201|-9.1840274
Montana|37.72969|62.27031|-24.5406214
Nebraska|39.72492|60.27508|-20.550163
*Nebraska CD-2*|53.03052|46.96948|6.061034
*Nevada*|51.65607|48.34393|3.3121466
New Hampshire|63.00037|36.99963|26.0007314
New Jersey|60.29657|39.70343|20.5931497
New Mexico|55.54129|44.45871|11.0825785
New York|64.20354|35.79646|28.4070745
*North Carolina*|48.94769|51.05231|-2.1046133
North Dakota|39.61115|60.38885|-20.7776914
*Ohio*|48.0239|51.9761|-3.9522071
Oklahoma|40.54972|59.45028|-18.9005671
Oregon|55.91936|44.08064|11.838716
*Pennsylvania*|52.75727|47.24273|5.5145449
Rhode Island|58.85695|41.14305|17.7139041
*South Carolina*|46.03663|53.96337|-7.9267354
South Dakota|41.65608|58.34392|-16.6878349
Tennessee|37.11921|62.88079|-25.7615867
*Texas*|47.97994|52.02006|-4.0401226
Utah|35.36543|64.63457|-29.2691433
Vermont|68.64464|31.35536|37.2892791
Virginia|55.26281|44.73719|10.525627
Washington|60.19279|39.80721|20.3855821
West Virginia|38.99759|61.00241|-22.0048129
*Wisconsin*|52.3016|47.6984|4.6032081
Wyoming|20.71385|79.28615|-58.572306


## Accuracy of my model

![](https://github.com/eric-white2021/gov1347blog/blob/gh-pages/model_error_all.png?raw=true)

![](https://github.com/eric-white2021/gov1347blog/blob/gh-pages/model_error.png?raw=true)
