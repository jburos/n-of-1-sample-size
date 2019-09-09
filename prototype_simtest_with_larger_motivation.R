
# Prototype simtest process without random effects
library(here)
library(tidyverse)
library(future)
library(brms)
library(furrr)
future::plan(multiprocess)
source(here('simdata.function.R'))
ggplot2::theme_set(theme_minimal())

# set the seed & run parameters
seed <- 122355482
run_date <- '2019-09-06'
run_desc <- 'prototype_simtest_with_larger_motivation'
run_formula <- study_completion ~ duration_5_days + duration_27_days + notify_moderate + motivation_level + motivation_level_strong + motivation_level_disagree
set.seed(seed)

# specify the priors
completion_rate <- 0.2
# by default this is a weakly informative prior with no directional effects
priors <- specify_priors(completion_rate = completion_rate)

# simulate data according to priors
sample_sizes <- seq(from = 400, to = 1500, by = 50)
simd <- 
  sample_sizes %>%
  furrr::future_map(~ simdata(n_draws = 500,
                              total_n = .,
                              b_motivation_effect = c(log(1.2), log(1.3), log(1.6)),
                              completion_props = c(0.3, 0.2, 0.1),
                              duration_days = c(5, 15, 27),
                              sample_props = c(0.2, 0.6, 0.2)
                              )
                    )  %>%
  unlist(., recursive = FALSE)

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
