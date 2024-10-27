#'Set reporting delay distribution
#'
#'@details This distribution is used when a nowcast is needed to correct for
#'reporting delays in the data.
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
#'@export
get_rep_delay <- function(mean = 2,
                          sd = 1,
                          dist = "lognormal",
                          max_value = 10){

  # Default from EpiNow: convert_to_logmean(2, 1), sd = convert_to_logsd(2, 1), max = 10,
  dist <- LogNormal(mean = Normal(mean, 0.2), sd = Normal(1, 0.1), max = max_value)

  return(dist)

}
