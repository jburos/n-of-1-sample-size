library(rstan)
library(brms)
library(tidyverse)
library(tidybayes)
rstan::rstan_options(auto_write = TRUE)
options(mc.cores = 3)

#' Specify default priors without direction of effect
specify_priors <- function(response_prop) {
  c(brms::prior(normal(0, 0.4), class = 'b', check = TRUE),
    brms::prior(normal(0, 0.1), class = 'b', coef = 'notify_high', check = TRUE),
    brms::prior_string(glue::glue('student_t(10, {brms::logit_scaled(response_prop)}, 0.3)'), class = 'Intercept', check = TRUE))
}

#' simple wrapper to simulate data from a brms model
#' @export
simdata <- function(total_n = 700,
                    notify_prop = 0.5,
                    response_prop = 0.3,
                    n_draws = 10,
                    warmup = 1000,
                    prior = specify_priors(response_prop),
                    chains = 1,
                    iter = warmup + (n_draws / chains),
                    family = brms::bernoulli,
                    formula = sufficient_response ~ duration_5_days + duration_27_days + notify_high + (0 + notify_high | duration_group),
                    ...) {
  # construct covariate data
  d <- tbl_df(list(duration_days = c(5, 15, 27),
                   sample_prop = c(0.2, 0.6, 0.2)
                   )) %>%
    dplyr::mutate(sample_n = as.integer(total_n*sample_prop)) %>%
    tidyr::uncount(weights = sample_n) %>%
    dplyr::mutate(notify_high = as.integer(rbernoulli(n = nrow(.), p = notify_prop)),
                  duration_group = factor(duration_days,
                                          levels = c(5, 15, 27),
                                          labels = paste(c(5, 15, 27), 'days'),
                                          ordered = T),
                  duration_5_days = as.integer(duration_days == 5),
                  duration_27_days = as.integer(duration_days == 27),
                  # fake response variable (not used in simulation)
                  sufficient_response = as.integer(rbernoulli(n = nrow(.), p = response_prop))
                  )
  
  # simulate data from the priors according to the model
  prior_fit <- brms::brm(formula = formula,
                         data = d,
                         sample_prior = "only",
                         prior = prior,
                         family = family,
                         warmup = warmup,
                         iter = iter,
                         chains = chains,
                         ...)
  
  # A data.frame with our simulated outcome data for each `.row` of our original data & each `.draw`
  sim_data <- d %>%
    dplyr::select(-sufficient_response) %>%
    tidybayes::add_predicted_draws(model = prior_fit, prediction = 'sufficient_response', n = NULL) %>% 
    dplyr::ungroup() %>%
    dplyr::select(-.chain, -.iteration)

  # construct a data.frame with the "true" parameter values used to simulate each draw
  sim_params <- tidybayes::spread_draws(prior_fit, b_Intercept, b_duration_5_days, b_duration_27_days, b_notify_high) %>%
    dplyr::select(-.chain, -.iteration) %>%
    dplyr::ungroup()
  
  # join simulated response data with "true" parameter values
  sim_merged <- sim_data %>%
    dplyr::left_join(sim_params, by = '.draw')

  # return merged data as list of data.frames, one per draw
  a <- sim_merged %>%
    tidyr::nest(-.draw)
  a$data
} 

