
# Prototype simtest process without random effects

library(here)
library(tidyverse)
library(future)
library(brms)
source(here('simdata.function.R'))
future::plan(multicore)
ggplot2::theme_set(theme_minimal())

# set the seed & run parameters
seed <- 122355482
run_date <- '2019-09-05'
run_desc <- 'prototype_simtest_with_raneff'
run_formula <- sufficient_response ~ duration_5_days + duration_27_days + notify_high + (0 + notify_high | duration_group)
set.seed(seed)

# specify the priors
response_prop <- 0.3
# by default this is a weakly informative prior with no directional effects
priors <- specify_priors(response_prop = response_prop)

# simulate data according to priors
simd <- simdata(n_draws = 100,
                total_n = 700,
                response_prop = response_prop,
                prior = priors, seed = seed,
                formula = run_formula
                )

# plot the prior on the intercept (proportion of responses meeting "sufficiency" criteria)
tbl_df(list(sufficient_response = brms::inv_logit_scaled(
  brms::rstudent_t(n = 1000,
                   df = 10,
                   mu = brms::logit_scaled(response_prop),
                   sigma = 0.3)))) %>%
  ggplot(., aes(x = sufficient_response)) + 
  geom_density(fill = 'lightblue') +
  geom_vline(aes(xintercept = response_prop), linetype = 'dashed') + 
  ggtitle('Prior distribution on `b_Intercept` (proportion of responses meeting criteria)') + 
  scale_x_continuous(labels = scales::percent, limits = c(0, 1)) +
  labs(caption = glue::glue('Vertical line shows value at x = {response_prop}'))

# plot a summary of the simulated (prior-predictive) responses 
# according to the simulated parameter values
sim_merged <- dplyr::bind_rows(simd, .id = '.draw') 
sim_merged %>% 
  dplyr::group_by(.draw, b_Intercept, duration_group, duration_days) %>% 
  dplyr::summarise(mean_response = mean(sufficient_response)) %>% 
  ggplot(., aes(x = brms::inv_logit_scaled(b_Intercept), y = mean_response)) + 
  geom_point(aes(colour = duration_group)) + 
  geom_line(aes(group = .draw), colour = 'lightgrey') +
  geom_line(data = . %>% dplyr::filter(duration_days == 15), mapping = aes(colour = duration_group), linetype = 'dashed') +
  ggtitle('Simulated response rate according to duration & `b_Intercept`')

# now we fit our model to the simulated datasets
simfits <- brms::brm_multiple(run_formula,
                              data = simd,
                              family = bernoulli,
                              prior = priors,
                              combine = FALSE,
                              seed = seed
                              )

# save simfits object to disk
saveRDS(simfits, here('.brms_fits', glue::glue('{run_desc}_{run_date}_{seed}.fits.Rds')))
# save simd object to disk
saveRDS(simd, here('.brms_fits', glue::glue('{run_desc}_{run_date}_{seed}.simd.Rds')))
