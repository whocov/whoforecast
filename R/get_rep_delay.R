#'Set reporting delay distribution
#'
#'@details This distribution is used when a nowcast is needed to correct for
#'reporting delays in the data. Ideally this should be estimated for a given country
#'or region using timestamped datasets in order to properly account for the reporting
#'delays. Otherwise an unknown reporting delay distribution can be assumed but
#'results will not be as accurate.
#'
#'@param mean mean of the reporting delay distribution. If a lognormal
#'distribution is specified, the convert_to_logmean {EpiNow2} function can be used
#'to convert to format needed
#'@param sd standard deviation of the reporting delay distribution. If a lognormal
#'distribution is specified, the convert_to_logsd {EpiNow2} function can be used
#'to convert to format needed
#'@param distribution the probability distribution used. Defaults to lognormal.
#'
#'@return list including the mean, sd and distribution type for the reporting delay distribution
#'
get_rep_delay <- function(mean = 2,
                          sd = 1,
                          dist = "lognormal",
                          max_value = 10){

  # Default from EpiNow: convert_to_logmean(2, 1), sd = convert_to_logsd(2, 1), max = 10,

  dist <- list(mean = mean,
               sd = sd,
               dist = dist,
               max = max_value
  )

  return(dist)

}
