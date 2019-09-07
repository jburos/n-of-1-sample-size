Prototype simtest without a motivation effect
================
Jacqueline Buros
9/6/2019

The purpose of this document is to review the quality of data simulations & fits to simulated data. Though we will be reviewing fits to simulated data at a particular sample size, this will serve as a prototype of the process used to evaluate the quality of results at various sample sizes.

Review simulation parameters
----------------------------

First we should review the parameters used to simulate our data. In this round of simulations, a fixed set of parameter values are used to simulate data for all of our draws. We have parameters for the completion rate according to duration consistent with 30%, 20%, and 10% response in the 5-day, 15-day and 27-day groups respectively where notification level is low.

Increasing the notification level to "moderate" confers a modest increase in completion rate uniformly across these three groups. This is reflected by a fixed OR of 1.1 (roughly a 10% increase).

These are the "target" completion rates for each of our groups used to simulate our data.

<table>
<thead>
<tr>
<th style="text-align:left;">
duration\_group
</th>
<th style="text-align:right;">
notify\_moderate
</th>
<th style="text-align:left;">
scales::percent(invlogit\_linpred)
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
5\_days
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
30.0%
</td>
</tr>
<tr>
<td style="text-align:left;">
5\_days
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
32.0%
</td>
</tr>
<tr>
<td style="text-align:left;">
15\_days
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
20.0%
</td>
</tr>
<tr>
<td style="text-align:left;">
15\_days
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
21.6%
</td>
</tr>
<tr>
<td style="text-align:left;">
27\_days
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
10.0%
</td>
</tr>
<tr>
<td style="text-align:left;">
27\_days
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
10.9%
</td>
</tr>
</tbody>
</table>
Of course, each draw of simulated data has a different *observed* completion rate. There are two sources of variation contributing to the observed completion rate in each draw. One is the composition of the particular study population -- both the notification rate and the assignment to duration groups is randomized and so one would expect *some* imbalance in these assignments in practice.

Looking at the group sizes over our draws can give a sense of how this would be expected to vary in practice for a sample of this size (640 participants).

<table>
<thead>
<tr>
<th style="text-align:left;">
duration\_group
</th>
<th style="text-align:right;">
notify\_moderate
</th>
<th style="text-align:right;">
1
</th>
<th style="text-align:right;">
2
</th>
<th style="text-align:right;">
3
</th>
<th style="text-align:right;">
4
</th>
<th style="text-align:right;">
5
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
5\_days
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
61
</td>
<td style="text-align:right;">
51
</td>
<td style="text-align:right;">
68
</td>
<td style="text-align:right;">
63
</td>
<td style="text-align:right;">
64
</td>
</tr>
<tr>
<td style="text-align:left;">
5\_days
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
67
</td>
<td style="text-align:right;">
77
</td>
<td style="text-align:right;">
60
</td>
<td style="text-align:right;">
65
</td>
<td style="text-align:right;">
64
</td>
</tr>
<tr>
<td style="text-align:left;">
15\_days
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
192
</td>
<td style="text-align:right;">
199
</td>
<td style="text-align:right;">
178
</td>
<td style="text-align:right;">
183
</td>
<td style="text-align:right;">
190
</td>
</tr>
<tr>
<td style="text-align:left;">
15\_days
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
192
</td>
<td style="text-align:right;">
185
</td>
<td style="text-align:right;">
206
</td>
<td style="text-align:right;">
201
</td>
<td style="text-align:right;">
194
</td>
</tr>
<tr>
<td style="text-align:left;">
27\_days
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
64
</td>
<td style="text-align:right;">
62
</td>
<td style="text-align:right;">
67
</td>
<td style="text-align:right;">
71
</td>
<td style="text-align:right;">
63
</td>
</tr>
<tr>
<td style="text-align:left;">
27\_days
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
64
</td>
<td style="text-align:right;">
66
</td>
<td style="text-align:right;">
61
</td>
<td style="text-align:right;">
57
</td>
<td style="text-align:right;">
65
</td>
</tr>
</tbody>
</table>
This is very likely a modest influence on the observed rates, but it is nonetheless there.

The second source comes from the simulation of the outcome itself.

Here is a sample of the observed completion rates for each of our 6 covariate combinations.

![](Review-simtest-no-motivation-effect_files/figure-markdown_github/unnamed-chunk-3-1.png)

Review priors for the model fit
-------------------------------

### Prior on `b_Intercept`

The `Intercept` term defines the proportion of the population in the 15-day study length meeting the criteria for a "sufficient" response.

I have put a fairly narrow prior centered at the 20% mark:

![](Review-simtest-no-motivation-effect_files/figure-markdown_github/prior-Intercept-plot-1.png)

### Prior on `b_duration_X`

We originally started with what is a typical weakly informative prior (`normal(0, 1)`) on the `beta` effects describing the offset from the response at 15 days for the other two study durations of 5 & 27 days. However this led to much larger effect sizes than I would have expected (ie sufficient-response rates close to 80% in one group).

In this set of responses the prior on these betas is more narrow: normal(0, 0.4).

Let's see how that translates into a more familiar metric such as an OR.

![](Review-simtest-no-motivation-effect_files/figure-markdown_github/prior-beta-duration-plot-1.png)

This suggests even this distribution is too large for our betas -- I say this because there is significant density at a two-fold difference in response depending on the study duration (however -- maybe this is right?).

### Prior on `b_notify_high`

Finally we will review the priors on our notification level.

Here we start with a more narrow prior than for the duration since I expect this will be a weaker effect.

Our prior is: .

Let's see how that translates into a more familiar metric such as an OR.

![](Review-simtest-no-motivation-effect_files/figure-markdown_github/prior-beta-notify-plot-1.png)

This is still centered at 0 (OR = 1) but with a more narrow distribution that we had used for the duration effect. Keep in mind that these are both starting points; we can improve upon them in future versions.

Posterior fits
--------------

We can now review the posterior fits for each of these scenarios. First, let's do a "typical" or generic summary of the posterior vs the parameter values.

![](Review-simtest-no-motivation-effect_files/figure-markdown_github/post-fits-1.png)

Next, we will write a function to summarise the metrics we "really" (supposedly) care about in our particular use case.

I would say these are (for each parameter):

1.  Width of posterior 90% CI (credible interval)
2.  Does the true value fall within the 90% posterior credible interval (check calibration)
3.  For regression parameters, estimate the Type S (sign) error rate \[if CI excludes 0\]

-   IE does this interval contain 0?
    -   if so, consider this analysis as "inconclusive"
    -   if *not*, call the beta as being &lt; or &gt; 0
-   compare this determination to the direction of the "true effect"

1.  For regression parameters, estimate the Type M (magnitude) error rate \[if CI excludes 0\]

-   IE does this interval contain 0?
    -   if so, consider this analysis as "inconclusive"
    -   if *not*, use the median value of the parameter as the "estimated effect"
-   compare this determination to the value of the "true effect". Is it &gt;2 times as large?

Let's prototype this summary for each of our model fit summarized above.

<table>
<thead>
<tr>
<th style="text-align:left;">
parname
</th>
<th style="text-align:right;">
.width
</th>
<th style="text-align:right;">
ci\_width
</th>
<th style="text-align:left;">
ci\_contains\_true\_value
</th>
<th style="text-align:left;">
ci\_contains\_0
</th>
<th style="text-align:right;">
ci\_type\_s\_error
</th>
<th style="text-align:right;">
ci\_type\_m\_error
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
b\_duration\_27\_days
</td>
<td style="text-align:right;">
0.9
</td>
<td style="text-align:right;">
0.7457985
</td>
<td style="text-align:left;">
TRUE
</td>
<td style="text-align:left;">
FALSE
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
b\_duration\_5\_days
</td>
<td style="text-align:right;">
0.9
</td>
<td style="text-align:right;">
0.6806041
</td>
<td style="text-align:left;">
FALSE
</td>
<td style="text-align:left;">
TRUE
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
b\_Intercept
</td>
<td style="text-align:right;">
0.9
</td>
<td style="text-align:right;">
0.3927293
</td>
<td style="text-align:left;">
TRUE
</td>
<td style="text-align:left;">
FALSE
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
b\_notify\_moderate
</td>
<td style="text-align:right;">
0.9
</td>
<td style="text-align:right;">
0.2841230
</td>
<td style="text-align:left;">
TRUE
</td>
<td style="text-align:left;">
TRUE
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:right;">
NA
</td>
</tr>
</tbody>
</table>
This is how we will summarize the results for all 10 fits. We will additionally retain the "true value" in our result vector since we will eventually want to summarise how our fit quality changes for different magnitudes of effect.

<table>
<thead>
<tr>
<th style="text-align:left;">
parname
</th>
<th style="text-align:right;">
width
</th>
<th style="text-align:right;">
ci\_width
</th>
<th style="text-align:left;">
ci\_contains\_true\_value
</th>
<th style="text-align:left;">
ci\_contains\_0
</th>
<th style="text-align:left;">
ci\_type\_s\_error
</th>
<th style="text-align:left;">
ci\_type\_m\_error
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
b\_duration\_27\_days
</td>
<td style="text-align:right;">
0.95
</td>
<td style="text-align:right;">
0.9231509
</td>
<td style="text-align:left;">
84.0%
</td>
<td style="text-align:left;">
30.0%
</td>
<td style="text-align:left;">
0.0%
</td>
<td style="text-align:left;">
0.0%
</td>
</tr>
<tr>
<td style="text-align:left;">
b\_duration\_5\_days
</td>
<td style="text-align:right;">
0.95
</td>
<td style="text-align:right;">
0.7856807
</td>
<td style="text-align:left;">
96.0%
</td>
<td style="text-align:left;">
34.0%
</td>
<td style="text-align:left;">
0.0%
</td>
<td style="text-align:left;">
0.0%
</td>
</tr>
<tr>
<td style="text-align:left;">
b\_Intercept
</td>
<td style="text-align:right;">
0.95
</td>
<td style="text-align:right;">
0.4820053
</td>
<td style="text-align:left;">
97.0%
</td>
<td style="text-align:left;">
0.0%
</td>
<td style="text-align:left;">
0.0%
</td>
<td style="text-align:left;">
0.0%
</td>
</tr>
<tr>
<td style="text-align:left;">
b\_notify\_moderate
</td>
<td style="text-align:right;">
0.95
</td>
<td style="text-align:right;">
0.3498556
</td>
<td style="text-align:left;">
99.0%
</td>
<td style="text-align:left;">
100.0%
</td>
<td style="text-align:left;">
NaN%
</td>
<td style="text-align:left;">
NaN%
</td>
</tr>
</tbody>
</table>
The width of the credible intervals shown above, however, is on the log(OR) scale. It's not very easy to tell what that might look like in practice.

Let's review what the posterior density for the OR looks like in order to better appreciate this.

![](Review-simtest-no-motivation-effect_files/figure-markdown_github/unnamed-chunk-4-1.png)
