#'Set generation time distribution
#'
#'@details This function will return information on a generation time
#'distribution for use with the epinow package. A default distribution is
#'set for dengue from the literature. The mean, sd and distribution type
#'can be specified manually
#'
#'@param mean mean of the generation time distribution. If specified in a
#'scale and shape format, the gammaParamsConvert {ConnMatTools} function can be used
#'to convert to mean
#'@param sd standard deviation of the generation time distribution. If specified in a
#'scale and shape format, the gammaParamsConvert {ConnMatTools} function can be used
#'to convert to sd
#'@param distribution the probability distribution used. Defaults to Gamma.
#'@param max_value specifies the maximum possible value. Defaults to 10 days.
#'@return list including the mean, sd and distibution type for the generation time
#'@export
get_gen_time <- function(mean = 5,
                         sd = 7.071068,
                         dist = "gamma",
                         max_value = 10){

  # Default for dengue which is equivalent to shape = 0.5,
  # scale = 1/0.1, interval = 1

  dist <- list(mean = mean,
               sd = sd,
               dist = dist,
               max = max_value
               )

 return(dist)
}
