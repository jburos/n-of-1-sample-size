
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
run_desc <- 'prototype_simtest_no_raneff'
run_formula <- sufficient_response ~ duration_5_days + duration_27_days + notify_high
set.seed(seed)

# specify the priors
response_prop <- 0.3
# by default this is a weakly informative prior with no directional effects
priors <- specify_priors(response_prop = response_prop)

# simulate data according to priors
simd <- simdata(n_draws = 10, total_n = 700,
                response_prop = response_prop,
                prior = priors, seed = seed,
                formula = run_formula
                ) %>%
  purrr::map(as.data.frame)

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
