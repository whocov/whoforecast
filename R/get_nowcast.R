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
#'@export
get_nowcast <- function(data_rep,
                        adm_names,
                        generation_time,
                        incubation_period,
                        reporting_delay,
                        horizon,
                        nowcast = FALSE,
                        rep_frequency = "weekly",
                        adm_level = adm_level,
                        output_dir = here("outputs"),
                        date_from = min(data_rep$date),
                        store_model_res = FALSE,
                        create_report = TRUE){


  iso_3_names <- data_rep %>% .[["iso_3_code"]] %>% .[1]

  data_epinow <- data_rep %>% unnest() %>% select(date, confirm)


  if(rep_frequency == "daily"){

    week_effect <- FALSE
    rt_estor <- rt_opts()

    } else if(rep_frequency == "weekly"){

      week_effect <- TRUE
      rt_estor <- rt_opts(prior = list(mean = 2, sd = 0.2), rw = 7)

      } else {
       message("Reporting frequency not recognised. Please specify 'daily' or 'weekly'")
     }

  if(nowcast == TRUE){

     delays <- delay_opts(incubation_period, reporting_delay)

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
    horizon = horizon,
    stan = stan_opts(cores = 4, warmup = 250, samples = 1000))

  }, error = function(e) {

    message("An error occurred:", conditionMessage(e))
    NULL  # Return NULL in case of an error

    })


  model_ests$fig_Rt <- viz_Rt(model_ests, paste(adm_names))
  model_ests$fig_reported <- viz_reported_week(model_ests, paste(adm_names))


  if(create_report){
    model_ests$report <- rmarkdown::render(
      here("R", "report.Rmd"),
      params = list(model_ests = model_ests, adm_names = adm_names, data_rep = data_rep, horizon = horizon)
    )
  }

  return(model_ests)

}



