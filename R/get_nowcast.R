#'Perform estimation and create and store figures for nowcast and/or forecast
#'
#'@details Uses observed data and specified delay distributions to estimate
#'the nowcast and/or forecast for a given country or region. Figures are created
#'and stored in a specified directory as well as model outputs if set by the user.
#'
#'@param data_rep nested data frame with the observed data for the country or region
#'@param generation_time mean and sd of the generation time distribution
#'@param incubation_period mean and sd of the incubation period distribution
#'@param reporting_delay mean and sd of the reporting delay distribution. If NULL then
#'nowcast is not performed and only forecast is returned
#'@param horizon number of days to forecast
#'@param adm_level the adm level for which the analysis is performed
#'@param output_dir the directory to store the figures and results
#'@param date_from the start date from which to fit the model
#'@param store_model_res if TRUE stores the model results as an rds file. Defaults to FALSE
#'@import ggplot2
#'@import dplyr
#'@import rmarkdown
#'@import EpiNow2
#'@import tidyr
#'@import lubridate
#'@import here
#'@export
get_nowcast <- function(data_rep,
                        adm_names,
                        generation_time,
                        incubation_period,
                        reporting_delay,
                        horizon,
                        reporting_freq = "weekly",
                        week_effect = TRUE,
                        adm_level = adm_level,
                        date_from = min(data_rep$date),
                        create_report = TRUE){


  dates_obs <- data_rep %>% unnest() %>% pull(date)

  iso_3_names <- data_rep %>% .[["iso_3_code"]] %>% .[1]

  data_epinow <- data_rep %>% unnest() %>% select(date, confirm)


  if(reporting_freq == "daily"){

    rt_estor <- rt_opts()

    } else if(reporting_freq == "weekly"){

      data_epinow <- fill_missing(data_epinow, missing_dates = "accumulate", initial_accumulate = 7)
      rt_estor <- rt_opts(rw = 7)

      } else {
       message("Reporting frequency not recognised. Please specify 'daily' or 'weekly'")
     }

  if(!is.null(reporting_delay)){

     delays <- delay_opts(incubation_period + reporting_delay)

      }else{

        delays <- delay_opts(incubation_period)

  }


  model_ests <-  tryCatch({

    epinow(
    data = data_epinow,
    generation_time = generation_time_opts(generation_time),
    delays = delays,
    rt = rt_estor,
    obs = obs_opts(week_effect = week_effect),
    gp = NULL,
    forecast = forecast_opts(horizon = horizon),
    stan = stan_opts(cores = 4, warmup = 250, samples = 1000),
    logs = NULL)

  }, error = function(e) {

    message("An error occurred:", conditionMessage(e))
    NULL  # Return NULL in case of an error

    })

  if(is.null(model_ests)){

    stop("Error: Model not fit. Check input parameters")

  }


  model_ests$fig_Rt <- viz_Rt(model_ests, paste(adm_names))
  model_ests$fig_reported <- viz_reported_week(model_ests, paste(adm_names), reporting_freq)

  if(create_report){

    report_path <- system.file("reports/report.Rmd", package = "whoforecast")

    output_file <- rmarkdown::render(
      report_path,
      params = list(model_ests = model_ests,
                    adm_names = adm_names,
                    data_rep = data_rep,
                    horizon = horizon,
                    reporting_freq = reporting_freq)
    )

    # Automatically open the rendered document
    if (.Platform$OS.type == "windows") {
      system2("open", output_file)
    } else if (Sys.info()["sysname"] == "Darwin") {
      system2("open", output_file)
    } else if (.Platform$OS.type == "unix") {
      system2("xdg-open", output_file)
    }
  }


  return(model_ests)

}



