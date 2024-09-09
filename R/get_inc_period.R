#'Set incubation period distribution
#'
#'@details This function will return information on an incubation period
#'distribution for use with the epinow package.  A default distribution is
#'set for dengue from the literature. The mean, sd and distribution type
#'can be specified manually.
#'
#'@author Martina McMenamin
#'
#'@param mean mean of the incubation period distribution. If specified in a
#'scale and shape format, the gammaParamsConvert {ConnMatTools} function can be used
#'to convert to mean
#'@param sd standard deviation of the incubation period distribution. If specified in a
#'scale and shape format, the gammaParamsConvert {ConnMatTools} function can be used
#'to convert to sd
#'@param distribution the probability distribution used. Defaults to Gamma.
#'
#'@return list including the mean, sd and distribution type for the incubation period
#'
#'@export
#'
get_inc_period <- function(mean = 1.5,
                           sd = 0.3,
                           dist = "lognormal",
                           max_value = 6){

  # Default from literature (add ref) 1.4 days (95% CI, 1.3–1.6)

  dist <- list(mean = mean,
               sd = sd,
               dist = dist,
               max = max_value
  )

  return(dist)

}

