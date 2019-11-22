Prototype simtest with a motivation effect
================
Jacqueline Buros
9/6/2019

  - [Review simulation parameters](#review-simulation-parameters)
  - [Review priors for the model fit](#review-priors-for-the-model-fit)
      - [Prior on `b_Intercept`](#prior-on-b_intercept)
      - [Prior on `b_duration_X`](#prior-on-b_duration_x)
      - [Prior on `b_notify_high`](#prior-on-b_notify_high)
  - [Posterior fits](#posterior-fits)
      - [Summary of model fits](#summary-of-model-fits)
  - [Review parameters across a range of sample
    sizes](#review-parameters-across-a-range-of-sample-sizes)

The purpose of this document is to review the quality of model fits to
simulated data. This document builds on an earlier doc by including a
“motivation” effect on the outcome (completion rate) in addition to
the effects of study duration & notification level.

The earlier doc sets up some details about our simulation scenario. We
are simulating data from an n-of-1 study in which participants are
enrolled into a study with either a 5, 15, or 27 day duration, they are
randomly assigned to either a high or low notification level, and the
provide a self-reported motivation level. Since 2/3 assignments are
randomized, we assume no correlation between the covariates of interest.

The analysis method is a multivariate logistic regression fit using Stan
(via the [brms](https://cran.r-project.org/package=brms) R package).

*Side note: The fits & other docs are generated using the
[prototype\_simtest\_with\_motivation.R](prototype_simtest_with_motivation.R)
script included in this repository. Please refer to that script for
details of how the data are simulated & the models fit.*

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

In addition, we are assuming that the motivation level will be set into
two groups (mostly for simplicity of the simulation) high vs low, and
that roughly 20% of the participants will be in the “high” motivation
group. Motivation increases completion rate by an OR of 1.2.

Given these parameter values, these are the “target” completion rates
for each of our groups used to simulate our data.

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

motivation\_high: 0

</th>

<th style="text-align:left;">

motivation\_high: 1

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

30.8%

</td>

<td style="text-align:left;">

30.8%

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

32.8%

</td>

<td style="text-align:left;">

32.8%

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

20.6%

</td>

<td style="text-align:left;">

20.6%

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

22.2%

</td>

<td style="text-align:left;">

22.2%

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

10.3%

</td>

<td style="text-align:left;">

10.3%

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

11.3%

</td>

<td style="text-align:left;">

11.3%

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

motivation\_high

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

0

</td>

<td style="text-align:right;">

48

</td>

<td style="text-align:right;">

48

</td>

<td style="text-align:right;">

52

</td>

<td style="text-align:right;">

57

</td>

<td style="text-align:right;">

52

</td>

</tr>

<tr>

<td style="text-align:left;">

5\_days

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

13

</td>

<td style="text-align:right;">

16

</td>

<td style="text-align:right;">

11

</td>

<td style="text-align:right;">

13

</td>

<td style="text-align:right;">

11

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

0

</td>

<td style="text-align:right;">

53

</td>

<td style="text-align:right;">

51

</td>

<td style="text-align:right;">

56

</td>

<td style="text-align:right;">

48

</td>

<td style="text-align:right;">

52

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

1

</td>

<td style="text-align:right;">

14

</td>

<td style="text-align:right;">

13

</td>

<td style="text-align:right;">

9

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

13

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

0

</td>

<td style="text-align:right;">

147

</td>

<td style="text-align:right;">

170

</td>

<td style="text-align:right;">

144

</td>

<td style="text-align:right;">

164

</td>

<td style="text-align:right;">

147

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

1

</td>

<td style="text-align:right;">

45

</td>

<td style="text-align:right;">

37

</td>

<td style="text-align:right;">

39

</td>

<td style="text-align:right;">

40

</td>

<td style="text-align:right;">

40

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

0

</td>

<td style="text-align:right;">

159

</td>

<td style="text-align:right;">

136

</td>

<td style="text-align:right;">

171

</td>

<td style="text-align:right;">

144

</td>

<td style="text-align:right;">

151

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

1

</td>

<td style="text-align:right;">

33

</td>

<td style="text-align:right;">

41

</td>

<td style="text-align:right;">

30

</td>

<td style="text-align:right;">

36

</td>

<td style="text-align:right;">

46

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

0

</td>

<td style="text-align:right;">

55

</td>

<td style="text-align:right;">

55

</td>

<td style="text-align:right;">

58

</td>

<td style="text-align:right;">

59

</td>

<td style="text-align:right;">

46

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

1

</td>

<td style="text-align:right;">

9

</td>

<td style="text-align:right;">

14

</td>

<td style="text-align:right;">

13

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

13

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

0

</td>

<td style="text-align:right;">

54

</td>

<td style="text-align:right;">

47

</td>

<td style="text-align:right;">

47

</td>

<td style="text-align:right;">

50

</td>

<td style="text-align:right;">

62

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

1

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

12

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:right;">

13

</td>

<td style="text-align:right;">

7

</td>

</tr>

</tbody>

</table>

This is very likely a modest influence on the observed rates, but it is
nonetheless there.

The second source comes from the simulation of the outcome itself.

Here is a sample of the observed completion rates for each of our 6
covariate combinations.

![](Review-simtest-with-larger-motivation-effect_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

## Review priors for the model fit

### Prior on `b_Intercept`

The `Intercept` term defines the proportion of the population in the
15-day study length meeting the criteria for a “sufficient” response.

I have put a fairly narrow prior centered at the 20% mark:

![](Review-simtest-with-larger-motivation-effect_files/figure-gfm/prior-Intercept-plot-1.png)<!-- -->

### Prior on `b_duration_X`

We originally started with what is a typical weakly informative prior
(`normal(0, 1)`) on the `beta` effects describing the offset from the
response at 15 days for the other two study durations of 5 & 27 days.
However this led to much larger effect sizes than I would have expected
(ie sufficient-response rates close to 80% in one group).

In this set of responses the prior on these betas is more narrow:
normal(0, 0.4).

Let’s see how that translates into a more familiar metric such as an OR.

![](Review-simtest-with-larger-motivation-effect_files/figure-gfm/prior-beta-duration-plot-1.png)<!-- -->

This suggests even this distribution is too large for our betas – I say
this because there is significant density at a two-fold difference in
response depending on the study duration (however – maybe this is
right?).

### Prior on `b_notify_high`

Finally we will review the priors on our notification level.

Here we start with a more narrow prior than for the duration since I
expect this will be a weaker effect.

Our prior is: .

Let’s see how that translates into a more familiar metric such as an OR.

![](Review-simtest-with-larger-motivation-effect_files/figure-gfm/prior-beta-notify-plot-1.png)<!-- -->

This is still centered at 0 (OR = 1) but with a more narrow distribution
that we had used for the duration effect. Keep in mind that these are
both starting points; we can improve upon them in future versions.

## Posterior fits

We can now review the posterior fits for each of these scenarios. First,
let’s do a “typical” or generic summary of the posterior vs the
parameter values.

![](Review-simtest-with-larger-motivation-effect_files/figure-gfm/post-fits-1.png)<!-- -->

Next, we will write a function to summarise the metrics we “really”
(supposedly) care about in our particular use case.

I would say these are (for each parameter):

1.  Width of posterior 95% CI (credible interval)
2.  Does the true value fall within the 95% posterior credible interval
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

0.9163996

</td>

<td style="text-align:left;">

88.0%

</td>

<td style="text-align:left;">

18.0%

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

0.7833798

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

0.5041869

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

b\_motivation\_high

</td>

<td style="text-align:right;">

0.95

</td>

<td style="text-align:right;">

0.8214826

</td>

<td style="text-align:left;">

92.0%

</td>

<td style="text-align:left;">

97.0%

</td>

<td style="text-align:left;">

0.0%

</td>

<td style="text-align:left;">

100.0%

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

0.3479631

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

Just to be clear, this uses a two-sided 95% posterior credible interval.

The width of the credible intervals shown above, however, is on the
log(OR) scale. It’s not very easy to tell what that might look like in
practice.

Let’s review what the posterior density for the OR looks like in order
to better appreciate this.

![](Review-simtest-with-larger-motivation-effect_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

For notification level, most of our posterior intervals will be
consistent with a weak effect, if any.

Only the difference in completion rate for the 27-day group (vs 15 days)
shows a consistently clear direction of effect at this sample size.

## Review parameters across a range of sample sizes

This shows us some of the details of our process for a sample size of
640 – roughly the sample size proposed by the frequentist analysis.

Next, we want to summarise the results of this process repeated across a
range of sample sizes. These results were generated according to the
code in
[prototype\_simtest\_with\_larger\_motivation.R](prototype_simtest_with_larger_motivation.R).
Here we read in the results from that simtest. We summarize “power” as
the % of simulations in which the posterior 95% credible interval
excludes a value of 0.

![](Review-simtest-with-larger-motivation-effect_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

As in the simulations described above, this is for a Bayesian
multivariate logistic regression analysis with terms for study duration
(27 & 5 days vs 15 days), motivation level (as a global effect), and
notification level (as a global effect). While we have simulated our
data assuming some interaction effects between motivation & notification
level and duration, we are not incorporating these interactions into the
analysis.
