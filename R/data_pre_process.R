#' Data preprocessing on the timeseries data
#'
#'@details Wrangle the data based on what adm level the analysis is performed.
#'Data will be nested by adm level to perform multi-country or multi-region
#'modelling across a nested tibble. This function will not be needed if only
#'ad hoc looks at individual countries are required.
#'
#'@param timeseries cleaned timeseries from get_timeseries
#'@param adm_level sets the adm level for which data to pull with options
#'adm0, adm1, adm2
#'@param date_from date from which to start the analysis
#'@return tibble nested by specified adm_level
#'@import dplyr
#'@import tidyr
#'@import lubridate
#'@export
data_pre_process <- function(timeseries,
                             adm_level = "adm0",
                             date_from = min(timeseries$date)){

  data_prep <-
    timeseries %>%
      complete(date = seq.Date(min(timeseries$date, na.rm = TRUE),
                               max(timeseries$date), na.rm = TRUE,
                               by = "day")
               ) %>%
      replace_na(list(confirm = 0)) %>%
      fill(adm0_name, .direction = "down") %>%
      fill(iso_3_code, .direction = "up") %>%
      filter(date >= date_from) %>%
      left_join(timeseries) %>%
      mutate(date = as.Date(date, format = "%Y-%m-%d")) %>%
      filter(date > date_from) %>%
      select(paste0(adm_level, "_name"), date, confirm, iso_3_code) %>%
      mutate(date = date + days(3)) %>%
      group_by_at(paste0(adm_level, "_name")) %>%
      nest()

  return(data_prep)

}
