#'Get clean timeseries of cases for estimation at a regular reporting interval
#'and reformat for epinow use
#'
#'@details This function will pull the timeseries from the data folder and reformat
#'for epinow use - this function could be tailored for a given country's dataset format

#'@param file_path specifies the file path from which to read the cleaned timeseries
#'@param adm_level sets the adm level for which data to pull with options adm0, adm1, adm2
#'@return cleaned timeseries dataset for all countries
#'@import dplyr
#'@export
get_timeseries <- function(data,
                           date_var = "date",
                           case_var = "cases",
                           adm_level = "adm0"){


 timeseries <- data %>%

  # Get epinow format
  rename(date = unname(date_var), confirm = unname(case_var)) %>%
   mutate(date = as.Date(date))

  if(any(timeseries$confirm < 0)){
    message("negative case counts detected - check data")
  }

  return(timeseries)

}
