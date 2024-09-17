#' Run short term forecast using the epinow2 package for estimation
#'
#' Creates figures and a report on nowcast and/or short-term forecast for a given
#' country. This uses Epinow2 package for estimation but allows more flexibility
#' in application relevant to who uses such as weekly data, report creation for policy
#' makers and the option to include only a forecast with no nowcast when reporting
#' delays are not expected or counts are derived from cumulative data with no back-corrections.
#'
#' @param data data frame with the observed data for the country or region
#' @return figures for daily or weekly analysis and a report in Word format
#' @seealso [Epinow2::epinow()] which this function wraps
#' @import dplyr
#' @import tidyverse
#' @import tidyr
#' @import purrr
#' @import here
#' @export
run_forecast <- function(data,
                         adm_level = "adm0",
                         reporting_freq = "weekly",
                         week_effect = TRUE,
                         generation_time = get_gen_time(),
                         incubation_period = get_inc_period(),
                         reporting_delay = get_rep_delay(),
                         forecast = TRUE,
                         horizon = 7,
                         create_report = TRUE,
                         date_from = min(data$date),
                         date_var = "date",
                         case_var = "cases"
){

  if(horizon > 28){
    stop("Forecasting period must be less than 28 days")
  }

  # Set date for figures
  date_pipe_run <- Sys.Date()

  # Set time series at chosen adm level
  timeseries <- get_timeseries(data,
                               date_var = date_var,
                               case_var = case_var,
                               adm_level = adm_level) #%>%
    # filter_at(vars(paste0(adm_level, "_name")), any_vars(. %in% apply_to))
  #  filter_at(vars("adm0_name"), any_vars(. %in% apply_to))

  # Nest timeseries by adm level
  timeseries_nest <- data_pre_process(timeseries,
                                      adm_level = adm_level,
                                      date_from = date_from)


  adm_names <-  timeseries_nest %>% unnest() %>% .[[paste0(adm_level, "_name")]] %>% .[1]

  # Run nowcasting across all nested adm levels - this also saves figures
  # for each adm_level
  results <- timeseries_nest$data  %>% map(., get_nowcast,
                                              adm_names,
                                              generation_time,
                                              incubation_period,
                                              reporting_delay,
                                              horizon,
                                              reporting_freq,
                                              week_effect,
                                              adm_level,
                                              date_from,
                                              create_report)


  return(results)

}

