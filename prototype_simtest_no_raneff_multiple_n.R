
# Prototype simtest process without random effects
library(here)
library(tidyverse)
library(future)
library(brms)
library(furrr)
source(here('simdata.function.R'))
future::plan(multiprocess)
ggplot2::theme_set(theme_minimal())
rstan::rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

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
sample_sizes <- seq(from = 400, to = 500, by = 50)
simd <- 
  sample_sizes %>%
  furrr::future_map(~ simdata(total_n = ., n_draws = 10, 
                       response_prop = response_prop,
                       prior = priors, seed = seed,
                       formula = run_formula)) %>%
  unlist(., recursive = FALSE)
