
# Prototype simtest process without random effects
library(here)
library(tidyverse)
library(future)
library(brms)
library(lubridate)
library(furrr)
future::plan(multiprocess)
source(here::here(file = 'simdata.function.R'))
source(here::here(file = 'extract_and_summarise.function.R'))
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
sim_per_sample_size <- function(total_n, run_desc, run_formula = run_formula,
                                run_date = lubridate::today(), 
                                priors = specify_priors(completion_rate = 0.2), 
                                n_draws = 500,
                                ...) { 
  
  # construct files for all outputs
  label <- glue::glue('{run_desc}_{run_date}_{seed}_draw{n_draws}_n{total_n}')
  filenames <- c('results', 'simd', 'fits', 'priors') %>%
    purrr::set_names(.) %>%
    purrr::map_chr(~ here::here('.brms_fits', glue::glue('{label}.{.}.Rds'))) %>%
    as.list()
  
  # return results if file exists
  if (file.exists(filenames$results)) {
    sim_results <- readRDS(filenames$results)
    return(sim_results)
  }
  
  # simulate data  
  if (!file.exists(filenames$simd)) {
    sim_data <- simdata(total_n = total_n,
                    n_draws = n_draws,
                    b_motivation_level = c(log(1.2), log(1.3), log(1.6)),
                    completion_props = c(0.3, 0.2, 0.1),
                    duration_days = c(5, 15, 27),
                    sample_props = c(0.2, 0.6, 0.2)#,
                    #...
                    )
    # save simd object to disk
    saveRDS(sim_data, filenames$simd)
  } else {
    sim_data <- readRDS(filenames$simd)
  }
  
  if (!file.exists(filenames$fits)) {
    sim_fits <- brms::brm_multiple(run_formula,
                                  data = sim_data,
                                  family = bernoulli,
                                  prior = priors,
                                  combine = FALSE,
                                  seed = seed,
                                  future = FALSE
                                  )
    # save simfits object to disk
    saveRDS(sim_fits, filenames$fits)
    # save priors object to disk
    saveRDS(priors, filenames$priors)
  } else {
    sim_fits <- readRDS(filenames$fits)
  }
  
  # extract a single simulated data frame containing parameter values used for simulation
  # (note: effects are uniform for all simulated data in this "batch")
  # also transform our "target" percentages into log(OR) as specified by the model
  sim_pars <- sim_data[[1]] %>% 
    dplyr::mutate(b_duration_27_days = log((10/90) / (20/80)),
                  b_duration_5_days = log((30/70) / (20/80))) %>%
    dplyr::rename(b_Intercept = b_Intercept_15_days)
  
  sim_results <- purrr::map_dfr(sim_fits,
                        extract_and_summarise,
                        sim_pars = sim_pars,
                        ci_widths = c(0.95),
                        .id = 'fit')
  
  saveRDS(sim_results, filenames$results)
  
  sim_results
}

# test function above
a <- sim_per_sample_size(total_n = 100, run_desc = 'test', run_date = today(), run_formula = run_formula)

#stophere()

sim_results <- seq(from = 400, to = 1500, by = 50) %>%
  furrr::future_map_dfr(sim_per_sample_size, run_desc = run_desc, run_date = run_date, run_formula = run_formula, .id = 'samp')

# save sim_res object to disk
saveRDS(sim_results, here::here('.brms_fits', glue::glue('{run_desc}_{run_date}_{seed}.sim_results.Rds')))

# (plot results)
(p <- sim_results %>% 
    dplyr::mutate(alpha = 1 - .width) %>%
    dplyr::filter(parname != 'b_Intercept') %>%
    dplyr::group_by(parname, total_n, alpha) %>%
    dplyr::summarise(power = 1 - mean(ci_contains_0)) %>%
    dplyr::ungroup() %>%
    ggplot(., aes(x = total_n, y = power, group = parname, colour = parname)) + 
    geom_line() +
    scale_y_continuous(labels = scales::percent) +
    ggtitle('Power estimates for detecting the simulated effect size') +
    labs(caption = 'Power reflects the probability of a posterior 95% CI excluding 0') +
    geom_hline(aes(yintercept = 0.8), colour = 'lightgrey', linetype = 'dashed') +
    scale_x_continuous('Sample size (n)')
  )


