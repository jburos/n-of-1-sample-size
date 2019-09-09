library(rstan)
library(brms)
library(tidyverse)
library(tidybayes)
rstan::rstan_options(auto_write = TRUE)

#' Specify default priors without direction of effect
specify_priors <- function(completion_rate) {
  c(brms::prior(normal(0, 0.4), class = 'b', check = TRUE),
    brms::prior(normal(0, 0.1), class = 'b', coef = 'notify_moderate', check = TRUE),
    brms::prior_string(glue::glue('student_t(10, {brms::logit_scaled(completion_rate)}, 0.3)'), class = 'Intercept', check = TRUE))
}

#' simple wrapper to simulate data from a brms model
#' @export
simdata <- function(n_draws = 10,
                    total_n = 700,
                    notify_prop = 0.5,
                    b_notify_moderate = log(1.1),
                    completion_props = c(0.3, 0.2, 0.1),
                    sample_props = c(0.2, 0.6, 0.2),
                    duration_days = c(5, 15, 27),
                    b_motivation_effect = c(log(1.1), log(1.2), log(1.3))) {

  # return simulated data as a list of data.frames `n_draws` long
  # where each data.frame is an independent simulation of the data with 
  # the given 
  d <- replicate(n = n_draws,
                 simulate_data_once(total_n = total_n,
                                    b_notify_moderate = b_notify_moderate,
                                    notify_prop = notify_prop,
                                    completion_props = completion_props,
                                    sample_props = sample_props,
                                    duration_days = duration_days,
                                    b_motivation_effect = b_motivation_effect),
                 simplify = F)
}

get_duration_ns <- function(total_n = 700,
                            sample_props = c(0.2, 0.6, 0.2)) {
  a <- rbinom(n = length(sample_props)-1, size = total_n, prob = sample_props[1:2])
  a[[length(sample_props)]] <- total_n - sum(a)
  a
}

simulate_data_once <- function(total_n = 700,
                               notify_prop = 0.5,
                               b_notify_moderate = log(1.1),
                               b_motivation_effect = c(log(1.1), log(1.2), log(1.3)),
                               b_motivation_strong = c(0, 0, log(1.1)),
                               b_motivation_disagree = c(0, 0, log(0.5)),
                               n_motivation_groups = 5,
                               completion_props = c(0.3, 0.2, 0.1),
                               sample_props = c(0.2, 0.6, 0.2),
                               duration_days = c(5, 15, 27)) {
  d <- tbl_df(list(study_duration = duration_days,
                   sample_prop = sample_props,
                   duration_intercept = brms::logit_scaled(completion_props),
                   b_notify_moderate = b_notify_moderate,
                   b_motivation_effect = b_motivation_effect,
                   b_motivation_strong = b_motivation_strong,
                   b_motivation_disagree = b_motivation_disagree
  )) %>%
    dplyr::mutate(duration_n = get_duration_ns(total_n = total_n, sample_props = sample_prop)) %>%
    tidyr::uncount(weights = duration_n) %>%
    dplyr::mutate(notify_moderate = as.integer(rbernoulli(n = n(), p = notify_prop)),
                  motivation_level_centered = as.integer(ceiling(runif(min = -3, max = 2, n = n()))), # centered at 3
                  motivation_level_strong = ifelse(motivation_level_centered == 2, 1, 0),  # +2 == 5 (strongly agree)
                  motivation_level_disagree = ifelse(motivation_level_centered < 0, 1, 0), # -1, -2 == 1=2 (disagree or strongly disagree)
                  linpred = duration_intercept + b_notify_moderate*notify_moderate + b_motivation_effect*motivation_level_centered +
                    b_motivation_strong*motivation_level_strong + b_motivation_disagree*motivation_level_disagree,
                  motivation_level = motivation_level_centered + min(motivation_level_centered) + 1,
                  invlogit_linpred = brms::inv_logit_scaled(linpred)) %>%
    dplyr::group_by(invlogit_linpred) %>%
    dplyr::mutate(study_completion = as.integer(rbernoulli(n = n(), p = invlogit_linpred))) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(duration_group = factor(study_duration,
                                          levels = duration_days,
                                          labels = paste(duration_days, 'days', sep = '_'),
                                          ordered = T
                                          ),
                  notification_level = ifelse(notify_moderate == 1, 'moderate', 'low')
                  )
  
  # transform duration-group specific vars to wide format
  d %>%
    dplyr::mutate(one = 1) %>%
    # add intercepts as wide-vars
    dplyr::left_join(d %>%
                       dplyr::mutate(one = 1) %>%
                       dplyr::distinct(duration_group, duration_intercept, one) %>%
                       tidyr::spread(duration_group, duration_intercept) %>%
                       dplyr::rename_at(.vars = vars(ends_with('days')),
                                        .funs = list(~ stringr::str_c('b_Intercept_', .))),
                     by = 'one'
                     ) %>%
    # add duration as dummy var
    dplyr::left_join(d %>%
                       dplyr::mutate(one = 1) %>%
                       dplyr::distinct(duration_group, study_duration, one) %>%
                       tidyr::spread(duration_group, one, fill = 0) %>%
                       dplyr::rename_at(.vars = vars(ends_with('days')),
                                        .funs = list(~ stringr::str_c('duration_', .))),
                     by = 'study_duration') %>%
    dplyr::select(-one)
  
}

