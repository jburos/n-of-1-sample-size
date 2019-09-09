
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
run_desc <- 'prototype_simtest_with_larger_motivation'
run_formula <- study_completion ~ duration_5_days + duration_27_days + notify_moderate + motivation_high
set.seed(seed)

# specify the priors
completion_rate <- 0.2
# by default this is a weakly informative prior with no directional effects
priors <- specify_priors(completion_rate = completion_rate)

# simulate data according to priors
simd <- simdata(n_draws = 500,
                total_n = 640,
                b_motivation_effect = c(log(1.2), log(1.3), log(1.6)),
                completion_props = c(0.3, 0.2, 0.1),
                duration_days = c(5, 15, 27),
                sample_props = c(0.2, 0.6, 0.2)
                )

# confirm that we have simulated the motivation effect
simd %>%
  dplyr::bind_rows(.id = '.draw') %>%
  dplyr::distinct(duration_group, notify_moderate, motivation_level,
                  scales::percent(invlogit_linpred))  %>%
  dplyr::rename(`p` = `scales::percent(invlogit_linpred)`) %>%
  dplyr::arrange(duration_group, notify_moderate, motivation_level) %>%
  tidyr::spread(motivation_level, p, sep = '_')

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
