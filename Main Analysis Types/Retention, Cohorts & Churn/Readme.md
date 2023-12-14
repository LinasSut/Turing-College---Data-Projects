# Retention, Cohorts & Churn

## Task Description 

You got a follow up task from your product manager to give stats on how subscriptions churn looks like from a weekly retention standpoint. Your PM argues that to view retention numbers on a monthly basis takes too long and important insights from data might be missed out.

You remember learning previously that cohorts analysis can be really helpful in such cases. You should provide weekly subscriptions data that shows how many subscribers started their subscription in a particular week and how many remain active in the following 6 weeks. Your end result should show weekly retention cohorts for each week of data available in the dataset and their retention from week 0 to week 6. Assume that you are doing this analysis on 2021-02-07.

You should use turing_data_analytics.subscriptions table to answer this question. Please write a SQL that would extract data from the BigQuery, make a visualisation using Google spreadsheets and briefly comment your findings.

## Results, Conclusions and Insights

- Examining the cohort reveals that individuals who initiated their subscription in November are more prone to unsubscribe from our services during the second week.

- Upon reviewing December data, individuals who opted to subscribe to our services during that period demonstrate lower unsubscribing rates over a 6-week period. This may imply that a more motivated customer group was targeted during that specific timeframe. 
These findings should be juxtaposed with the marketing instruments employed to assess the effectiveness of efforts in retaining more customers.

- In the final week of January 2021, we experienced the lowest number of customer subscriptions to our services.

<img width="821" alt="Retention Cohorts" src="https://github.com/LinasSut/Turing-College-Data-Projects/assets/92430287/05d23c0a-5c9b-4001-b43b-822453398c05">

