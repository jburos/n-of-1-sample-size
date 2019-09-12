
#' extract posterior draws from a fit & compare to true values
#' @export
extract_and_summarise <- function(sim_fit, sim_pars, ci_widths = c(0.95)) {
  sim_fit %>%
    tidybayes::spread_draws(`b_.*`, regex = TRUE) %>%
    tidyr::gather(parname, posterior_value, starts_with('b_')) %>%
    dplyr::group_by(parname) %>%
    tidybayes::median_qi(posterior_value, .width = c(ci_widths)) %>%
    dplyr::ungroup() %>%
    dplyr::inner_join(sim_pars %>% 
                        ungroup() %>%
                        dplyr::mutate(total_n = nrow(.)) %>%
                        dplyr::select(total_n, starts_with('b')) %>%
                        dplyr::distinct() %>% 
                        dplyr::summarise_all(.funs = mean) %>%  # for now estimate param values in absence of interaction
                        tidyr::gather(parname, true_value, starts_with('b'))
                      , by = "parname") %>%
    dplyr::group_by(parname, .width, true_value, total_n) %>%
    dplyr::summarise(ci_width = abs(.upper - .lower),
                     ci_contains_true_value = dplyr::between(true_value, left = .lower, right = .upper),
                     ci_contains_0 = dplyr::between(0, left = .lower, right = .upper),
                     ci_type_s_error = dplyr::case_when(ci_contains_0 ~ NA_integer_,
                                                        (posterior_value < 0) == (true_value < 0) ~ 0L,
                                                        (posterior_value < 0) != (true_value < 0) ~ 1L,
                                                        TRUE ~ NA_integer_),
                     ci_type_m_error = dplyr::case_when(ci_contains_0 ~ NA_integer_,
                                                        posterior_value / true_value > 2 ~ 1L,
                                                        true_value / posterior_value > 2 ~ 1L,
                                                        TRUE ~ 0L)
    ) %>%
    dplyr::ungroup()
}
