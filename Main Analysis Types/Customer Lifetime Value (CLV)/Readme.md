# Customer Lifetime Value Analysis (CLV)

Customer Lifetime Value (CLV) stands at the forefront of e-commerce analytics, serving as a crucial metric to gauge the long-term value of customer relationships. Recent scrutiny over Shopify's simplistic CLV formula has prompted a shift towards cohort analysis for more reliable insights. This adjustment responds to two key concerns raised by the manager: the need to include all website users, not just purchasers, and the preference for a 12-week cohort analysis to capture customer engagement dynamics more effectively. The ongoing refinement of CLV calculations underscores its indispensable role in shaping marketing strategies and business planning by providing a nuanced understanding of customer value over time.

### Main Analysis 

#### 1. Average order value (AOV) / Number of customers 

As the first step you should write 1 or 2 queries to pull data of weekly revenue divided by registrations. Since in this particular site there is no concept of registration, we will simply use the first visit to our website as registration date

<img width="1200" alt="Average order Value by Cohort Week" src="https://github.com/LinasSut/Turing-College-Data-Projects/assets/92430287/0ba81778-5e23-4140-b5bc-07a555d6c19e">


- From the data above we can see that persons are more willing to buy in the first week as in the longer period the average purchases are decreasing, this could indicate that people find the required products and just slowly repleneshing them as they need them 
- We can see that in quite the same results in first 7 week from 2020-11-01 till 2020-12-13, but in the longer period the from the starting week results are slowly decreasing

#### 2. Cumulative sum of revenue growth by number of customers

In the upcoming chart, the revenue/registrations for a specific weekly cohort will be presented as a cumulative sum. To construct this chart, the revenue from the previous week was simply added to the current week’s revenue.

<img width="1200" alt="Cumulative sum of revenue growth" src="https://github.com/LinasSut/Turing-College-Data-Projects/assets/92430287/4e76d464-5199-4e18-a6f6-9882ff88326d">

  - From the data above we can see that the period 2020-11-01 till 2020-12-06 of time the cumulative revenue increases that could indicate that the particular time period when people are tend to by more seasonically.

#### 3. Future Prediction of posible sales with our current data

Next, the focus is on the future and try to predict the missing data. In this case missing data is the revenue we should expect from later acquired user cohorts. For example, for users whose first session happened on 2021-01-24 week we have only their first week revenue which is 0.19USD per user who started their first session in this week. Though we are not sure what will happen in the next 12 weeks.For this we will simply use previously calculated Cumulative growth % (red marked area in chart aboove) and predict all 12 future weeks values 

<img width="1200" alt="Future Prediction of posible sales with our current data" src="https://github.com/LinasSut/Turing-College-Data-Projects/assets/92430287/2480a245-b6d1-4879-88ed-ddc81e8cbb46">

- As data analyst and the data we have we can predict of possible sales for the future.
- From the data below we can see from our prediction of cummulate growth percentage and the following week, that people are going to spend more in the period from 2020-11-01 to 2020-12-06, as for the following period the sales are decreasing.
- From the data, we can see that we need to increase our marketing effort to better target the customers in later periods, offer some promotions to increase the potencial spendings in the future.

### Key Insights 

1. We can see that people are tend to spend more in the first weeks, as in longer period their average order value decreases.
2. We can see consistent results of people spending from 2020-11-01 till 2020-12-13 weeks comparing to following weeks, this could indicate that there is strong seasonality.
3. From the period mention before we can see higher cummulative growth compared to other weeks.
4. From future prediction we can see that the same tendency could occur in the future.
5. With the right marketing campaigns, we can avoind these inconsistencies in people spending habits, as we can create better suited campaigns or offer promotions to buy more.



























