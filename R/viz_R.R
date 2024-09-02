#' Vizualise the cases by infection date
#'
#'@details This function will vizualise the nowcast estimates for daily cases by
#'infection date by extracting this from the preexisting epinow format
#'
#'@author Martina McMenamin
#'
#'@param now_estimates List of estimates from the nowcasting
#'
#'@param results Identifies the figure to generate. Options are 'infections', 'Rt',
#''growth_rate' or 'reported.
#'
#'@return Figure showing reported weekly cases epi curve with estimated daily
#'cases by infection date overlaid
#'@import ggplot2
#'@import dplyr
#'@import lubridate
#'@import tibble
#'@export
viz_Rt <- function(now_estimates, adm_names){

  R_estimates <- as_tibble(now_estimates$estimates$summarised) %>% filter(variable == "R")
  # Plot cases by reporting figure - note it is

  plot_weekly <- R_estimates %>%
    mutate(
      partial = ifelse(type == "estimate based on partial data", 1, 0),
      partial = ifelse(lead(partial) == 1, 1, partial),
      forecast =  ifelse(type == "forecast", 1, 0),
      forecast =  ifelse(lag(forecast) == 1 | lead(forecast) == 1, 1, forecast),
    )


  inf_week_fig <-
    ggplot(data = plot_weekly, aes(x = date)) +

    # Plot forecast - these are the estimates for the tested cases that are assumed to be fully reported
    # Add three weeks for a two week projection so that points connect (colouring by a variable breaks the timeseries)
    geom_line(data = subset(plot_weekly, forecast == 1), aes(y = median), alpha = 1, colour = "#7fcdbb") +
    geom_ribbon(data = subset(plot_weekly, forecast == 1), aes(ymin = lower_20, ymax = upper_20,  fill = "Forecast"), alpha = 0.4) +
    geom_ribbon(data = subset(plot_weekly, forecast == 1), aes(ymin = lower_50, ymax = upper_50), alpha = 0.3, fill = "#7fcdbb") +
   # geom_ribbon(data = subset(plot_weekly, forecast == 1), aes(ymin = lower_90, ymax = upper_90), alpha = 0.2, fill = "#7fcdbb") +


    # Separate out partial reported - this comes from the reporting delay distribution so
    # needs to be extracted from the estimates and then pad either side for continuous
    # representation
    geom_line(data = subset(plot_weekly, partial == 1), aes(y = median), alpha = 1, colour = "#FBEE95") +
    geom_ribbon(data = subset(plot_weekly, partial == 1), aes(ymin = lower_20, ymax = upper_20,  fill = "Nowcast"), alpha = 0.6) +
    geom_ribbon(data = subset(plot_weekly, partial == 1), aes(ymin = lower_50, ymax = upper_50), alpha = 0.5, fill = "#FBEE95") +
  #  geom_ribbon(data = subset(plot_weekly, partial == 1), aes(ymin = lower_90, ymax = upper_90), alpha = 0.4, fill = "#FBEE95") +

    # Set colour for incidence
    geom_line(data = subset(plot_weekly, type == "estimate"), aes(y = median), alpha = 1, colour = "#1d91c0") +
    geom_ribbon(data = subset(plot_weekly, type == "estimate"), aes(ymin = lower_20, ymax = upper_20, fill = "Estimate"), alpha = 0.3) +
    geom_ribbon(data = subset(plot_weekly, type == "estimate"), aes(ymin = lower_50, ymax = upper_50), alpha = 0.2, fill = "#1d91c0") +
   # geom_ribbon(data = subset(plot_weekly, type == "estimate"), aes(ymin = lower_90, ymax = upper_90), alpha = 0.1, fill = "#1d91c0") +

    # Add an intercept at each section
    geom_vline(data = plot_weekly, aes(xintercept = (max(date[type == "estimate based on partial data"]))), linetype = 2) +
    geom_vline(data = plot_weekly, aes(xintercept = (max(date[type == "estimate"]))), linetype = 2, colour = "darkgrey") +
    geom_hline(data = plot_weekly, aes(yintercept = 1), linetype = 2, colour = "black") +

    # Plot epi curve for observed - have to remove the forecast rows to plot separately by colour
    #   geom_col(data = subset(plot_weekly, !is.na(cases)), aes(y = cases), alpha = 0.2) +

    theme_bw() +
    labs(
      x = "Date",
      y = "Effective reproduction number",
      title = paste(adm_names),
      subtitle = paste0("Last reporting on ", format(max(plot_weekly$date[plot_weekly$type == "estimate based on partial data"])+days(3), "%d %B %Y"))
    ) +
    guides(fill = guide_legend(title = ""), colour = guide_legend(title = "")) +
    scale_x_date(date_breaks = "1 week", date_labels = "%b %d") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),
          legend.position = "bottom") +
    scale_fill_manual(values = c("Estimate" = "#1d91c0", "Nowcast" = "#FBEE95", "Forecast" = "#7fcdbb"))



  return(inf_week_fig)

}

