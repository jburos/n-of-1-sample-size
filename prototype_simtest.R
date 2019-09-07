
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
run_date <- '2019-09-06'
run_desc <- 'prototype_simtest_again'
run_formula <- study_completion ~ duration_5_days + duration_27_days + notify_moderate
set.seed(seed)

# specify the priors
completion_rate <- 0.2
# by default this is a weakly informative prior with no directional effects
priors <- specify_priors(completion_rate = completion_rate)

# simulate data according to priors
simd <- simdata(n_draws = 100,
                total_n = 640,
                completion_props = c(0.3, 0.2, 0.1),
                duration_days = c(5, 15, 27),
                sample_props = c(0.2, 0.6, 0.2),
                b_motivation_high = 0
                )

# plot the prior on the intercept (proportion of responses completing study)
tbl_df(list(
  study_completion = brms::inv_logit_scaled(
    brms::rstudent_t(n = 1000,
                     df = 10,
                     mu = brms::logit_scaled(completion_rate),
                     sigma = 0.3)))) %>%
  ggplot(., aes(x = study_completion)) + 
  geom_density(fill = 'lightblue') +
  geom_vline(aes(xintercept = completion_rate), linetype = 'dashed') + 
  ggtitle('Prior distribution on `b_Intercept` (proportion of participants completing study)') + 
  scale_x_continuous(labels = scales::percent, limits = c(0, 1)) +
  labs(caption = glue::glue('Vertical line shows value at x = {completion_rate}'))

# plot a summary of the simulated responses 
sim_merged <- dplyr::bind_rows(simd, .id = '.draw')
sim_merged %>% 
  dplyr::group_by(.draw, duration_group, study_duration, notify_moderate) %>% 
  dplyr::summarise(linear_predictor = mean(invlogit_linpred)) %>% 
  ggplot(., aes(x = .draw, y = linear_predictor, colour = duration_group)) + 
  geom_point(aes(shape = factor(notify_moderate), group = duration_group), position = position_dodge(width = 1)) + 
  ggtitle('Linear predictor according to covariate values') +
  scale_shape_manual('Moderate notification level', values = c(6, 19))

sim_merged %>% 
  dplyr::group_by(.draw, duration_group, study_duration, notify_moderate) %>% 
  dplyr::summarise(completion_rate = mean(study_completion),
                   linear_predictor = mean(invlogit_linpred)) %>% 
  ggplot(., aes(x = .draw, y = completion_rate, colour = duration_group)) + 
  geom_point(aes(shape = factor(notify_moderate), group = duration_group), position = position_dodge(width = 1)) + 
  ggtitle('Observed completion rate by group, according to covariate values',
          subtitle = 'for 10 draws of simulated data at random') +
  scale_shape_manual('Moderate notification level', values = c(6, 19))
 
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
# save priors object to disk
saveRDS(priors, here('.brms_fits', glue::glue('{run_desc}_{run_date}_{seed}.priors.Rds')))
