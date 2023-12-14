# A/B Testing
## Task Requirements

- You should prepare SQL query which would pull all data needed and similarly as before estimate if different variants of marketing campaigns (V1 vs V2) for both “NewYear” and “BlackFriday” campaigns had significantly better clickthrough rates (estimated as: number of users who clicked on campaign / number of impressions).
- For now you can ignore timing of user tracking data, you do not need to check if those sessions were recorded when the marketing campaign was running.
- Run the A/B testing on the results from your query.
- You can use Binomial A/B test Calculator.
- Add visualizations to help illustrate A/B testing results.

## Results & Conclusions 
### Black Friday Campaign

Here, I analyzed two Black Friday campaigns (V1 and V2) conducted in November 2020 and attempted to evaluate my hypotheses based on the test results. The hypotheses are as follows:

H0 (Null Hypothesis): There is no statistically significant difference between Black Friday V1 and Black Friday V2 campaigns.

Ha (Alternative Hypothesis): There is a statistically significant difference between Black Friday V1 and Black Friday V2 campaigns.

  
<img width="1178" alt="Black_Friday_Campaig" src="https://github.com/LinasSut/Turing-College-Data-Projects/assets/92430287/5ba34912-7275-4c5c-b472-df0c3564b65b">

In the analysis, it is evident that there is no statistically significant difference between Black Friday Campaign V1 and Black Friday V2 at either the 95% or 99% confidence levels. With a p-value of 0.4846, a Z-score of 0.04, and considering a 95% or 99% confidence level, our P-value exceeds the chosen confidence level (alpha = 0.05 or alpha = 0.01). Consequently, we fail to reject the null hypothesis, indicating that there is no significant difference between the two groups.

### New Year Campaign

Here, I examined two New Year campaigns (V1 and V2) conducted in January 2021 and aimed to assess my hypotheses based on the test results.

H0 (Null Hypothesis): There is no statistical significance between NewYear_V1 and NewYear_V2 campaigns.

Ha (Alternative Hypothesis): There is statistical significance between NewYear_V1 and NewYear_V2 campaigns.

<img width="1178" alt="Screenshot 2023-12-14 at 22 06 53" src="https://github.com/LinasSut/Turing-College-Data-Projects/assets/92430287/2a63e54f-1efd-4ad1-806f-c7ebd6a85cb4">

Based on the results, a notable difference exists between the two groups, given our confidence level of 95% (alpha = 0.05). With a P-value of 1, surpassing the alpha threshold, and an observed uplift of approximately -80 percent between the groups, we have grounds to reject the null hypothesis (H0), which posits no difference between the two groups. Instead, we support the alternative hypothesis, affirming the presence of a significant difference between the groups
