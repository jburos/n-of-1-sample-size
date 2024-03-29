Prototype simtest without a motivation effect
================
Jacqueline Buros
9/6/2019

The purpose of this document is to review the quality of data
simulations & fits to simulated data. Though we will be reviewing fits
to simulated data at a particular sample size, this will serve as a
prototype of the process used to evaluate the quality of results at
various sample sizes.

## Review simulation parameters

First we should review the parameters used to simulate our data. In this
round of simulations, a fixed set of parameter values are used to
simulate data for all of our draws. We have parameters for the
completion rate according to duration consistent with 30%, 20%, and 10%
response in the 5-day, 15-day and 27-day groups respectively where
notification level is low.

Increasing the notification level to “moderate” confers a modest
increase in completion rate uniformly across these three groups. This is
reflected by a fixed OR of 1.1 (roughly a 10% increase).

These are the “target” completion rates for each of our groups used to
simulate our data.

<table>

<thead>

<tr>

<th style="text-align:left;">

duration\_group

</th>

<th style="text-align:left;">

notification\_level

</th>

<th style="text-align:left;">

completion\_rate

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

5\_days

</td>

<td style="text-align:left;">

low

</td>

<td style="text-align:left;">

30.0%

</td>

</tr>

<tr>

<td style="text-align:left;">

5\_days

</td>

<td style="text-align:left;">

moderate

</td>

<td style="text-align:left;">

32.0%

</td>

</tr>

<tr>

<td style="text-align:left;">

15\_days

</td>

<td style="text-align:left;">

low

</td>

<td style="text-align:left;">

20.0%

</td>

</tr>

<tr>

<td style="text-align:left;">

15\_days

</td>

<td style="text-align:left;">

moderate

</td>

<td style="text-align:left;">

21.6%

</td>

</tr>

<tr>

<td style="text-align:left;">

27\_days

</td>

<td style="text-align:left;">

low

</td>

<td style="text-align:left;">

10.0%

</td>

</tr>

<tr>

<td style="text-align:left;">

27\_days

</td>

<td style="text-align:left;">

moderate

</td>

<td style="text-align:left;">

10.9%

</td>

</tr>

</tbody>

</table>

Of course, each draw of simulated data has a different *observed*
completion rate. There are two sources of variation contributing to the
observed completion rate in each draw. One is the composition of the
particular study population – both the notification rate and the
assignment to duration groups is randomized and so one would expect
*some* imbalance in these assignments in practice.

Looking at the group sizes over our draws can give a sense of how this
would be expected to vary in practice for a sample of this size (640
participants).

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

63

</td>

<td style="text-align:right;">

68

</td>

<td style="text-align:right;">

60

</td>

<td style="text-align:right;">

63

</td>

<td style="text-align:right;">

67

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

70

</td>

<td style="text-align:right;">

65

</td>

<td style="text-align:right;">

64

</td>

<td style="text-align:right;">

50

</td>

<td style="text-align:right;">

76

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

204

</td>

<td style="text-align:right;">

198

</td>

<td style="text-align:right;">

188

</td>

<td style="text-align:right;">

204

</td>

<td style="text-align:right;">

182

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

202

</td>

<td style="text-align:right;">

171

</td>

<td style="text-align:right;">

202

</td>

<td style="text-align:right;">

183

</td>

<td style="text-align:right;">

197

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

52

</td>

<td style="text-align:right;">

74

</td>

<td style="text-align:right;">

73

</td>

<td style="text-align:right;">

74

</td>

<td style="text-align:right;">

58

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

49

</td>

<td style="text-align:right;">

64

</td>

<td style="text-align:right;">

53

</td>

<td style="text-align:right;">

66

</td>

<td style="text-align:right;">

60

</td>

</tr>

</tbody>

</table>

This is very likely a modest influence on the observed rates, but it is
nonetheless there.

The second source comes from the simulation of the outcome itself.

Here is a sample of the observed completion rates for each of our 6
covariate
combinations.

![](Review-simtest-no-motivation-effect_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

## Review priors for the model fit

### Prior on `b_Intercept`

The `Intercept` term defines the proportion of the population in the
15-day study length completing the study. By “study completion”, we mean
that these participants satisfy the minimum criteria for an evaluable
response.

I have put a fairly narrow prior centered at the 20%
mark:

![](Review-simtest-no-motivation-effect_files/figure-gfm/prior-Intercept-plot-1.png)<!-- -->

### Prior on `b_duration_X`

We originally started with what is a typical weakly informative prior
(`normal(0, 1)`) on the `beta` effects describing the offset from the
response at 15 days for the other two study durations of 5 & 27 days.
However this led to much larger effect sizes than I would have expected
(ie sufficient-response rates close to 80% in one group).

In this set of responses the prior on these betas is more narrow:
normal(0, 0.4).

Let’s see how that translates into a more familiar metric such as an
OR.

![](Review-simtest-no-motivation-effect_files/figure-gfm/prior-beta-duration-plot-1.png)<!-- -->

This suggests even this distribution is too large for our betas – I say
this because there is significant density at a two-fold difference in
response depending on the study duration (however – maybe this is
right?).

### Prior on `b_notify_moderate`

Finally we will review the priors on our notification level.

Here we start with a more narrow prior than for the duration since I
expect this will be a weaker effect.

Our prior is: normal(0, 0.1).

Let’s see how that translates into a more familiar metric such as an
OR.

![](Review-simtest-no-motivation-effect_files/figure-gfm/prior-beta-notify-plot-1.png)<!-- -->

This is still centered at 0 (OR = 1) but with a more narrow distribution
that we had used for the duration effect. Keep in mind that these are
both starting points; we can improve upon them in future versions.

## Posterior fits

We can now review the posterior fits for each of these scenarios. First,
let’s do a “typical” or generic summary of the posterior vs the
parameter
values.

![](Review-simtest-no-motivation-effect_files/figure-gfm/post-fits-1.png)<!-- -->

Next, we will write a function to summarise the metrics we “really”
(supposedly) care about in our particular use case.

I would say these are (for each parameter):

1.  Width of posterior 90% CI (credible interval)
2.  Does the true value fall within the 90% posterior credible interval
    (check calibration)
3.  For regression parameters, estimate the Type S (sign) error rate
    \[if CI excludes 0\]
      - IE does this interval contain 0?
          - if so, consider this analysis as “inconclusive”
          - if *not*, call the beta as being \< or \> 0
      - compare this determination to the direction of the “true effect”
4.  For regression parameters, estimate the Type M (magnitude) error
    rate \[if CI excludes 0\]
      - IE does this interval contain 0?
          - if so, consider this analysis as “inconclusive”
          - if *not*, use the median value of the parameter as the
            “estimated effect”
      - compare this determination to the value of the “true effect”. Is
        it \>2 times as large?

### Summary of model fits

Summarizing these metrics for our 100 fits at this sample size (n =
640):

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

0.9290286

</td>

<td style="text-align:left;">

93.0%

</td>

<td style="text-align:left;">

25.0%

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

0.7896361

</td>

<td style="text-align:left;">

96.0%

</td>

<td style="text-align:left;">

40.0%

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

0.4792451

</td>

<td style="text-align:left;">

95.0%

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

0.3489639

</td>

<td style="text-align:left;">

100.0%

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

The width of the credible intervals shown above, however, is on the
log(OR) scale. It’s not very easy to tell what that might look like in
practice.

Let’s review what the posterior density for the OR looks like in order
to better appreciate
this.

![](Review-simtest-no-motivation-effect_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

For comparison, we will review the same two summary outputs from a run
with a sample size of 1280 participants (twice that in the simulation
above) and the same parameter
values.

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

0.7275142

</td>

<td style="text-align:left;">

90.0%

</td>

<td style="text-align:left;">

3.0%

</td>

<td style="text-align:left;">

0.0%

</td>

<td style="text-align:left;">

6.2%

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

0.5913198

</td>

<td style="text-align:left;">

95.0%

</td>

<td style="text-align:left;">

9.0%

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

0.3673993

</td>

<td style="text-align:left;">

95.0%

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

0.3179337

</td>

<td style="text-align:left;">

94.0%

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

![](Review-simtest-no-motivation-effect_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->
