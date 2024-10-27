#'Visualise the reported and estimated reported cases by date of report
#'
#'@details A function to visualise estimated reported weekly cases as epinow
#'only shows as a continuous timeseries with no weekly periodicity.
#'This function aggregates reported case estimates to the weekly level and
#'overlays this on the weekly reported case epicurve.This is also needed as
#'epinow show breaks in estimates which we don't want across short time frames
#'
#'@param now_estimates List of estimates from the nowcasting/forecasting
#'@param adm_level sets the adm level for which data to pull with options adm0, adm1
#'@import ggplot2
#'@import lubridate
#'@import tibble
#'@export
viz_reported_week <- function(now_estimates, adm_names, reporting_freq){

  plot_weekly_obs <- now_estimates$estimates$observations %>%
    mutate(
      year = year(date),
      month = month(date),
      week = week(date)
    )

  # Generate weekly level reported case estimates by date of report
  # and combine with observations

  plot_weekly <- now_estimates$estimated_reported_cases$summarised %>%
    rename(type_var = type) %>% # rename to keep other type variable which we want
    left_join(., now_estimates$estimates$summarised %>% filter(variable == "reported_cases")) %>%
    mutate(
      year = year(date),
      month = month(date),
      week = week(date + days(3))
    ) %>%
    full_join(., plot_weekly_obs) %>%
    as.data.frame(.) %>%
    mutate(
      partial = ifelse(type == "estimate based on partial data", 1, 0),
      partial = ifelse(lead(partial) == 1, 1, partial),
      forecast =  ifelse(type == "forecast", 1, 0),
      forecast =  ifelse(lag(forecast) == 1 | lead(forecast) == 1, 1, forecast),
    )

  rep_week_fig <-
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
    # geom_ribbon(data = subset(plot_weekly, partial == 1), aes(ymin = lower_90, ymax = upper_90), alpha = 0.4, fill = "#FBEE95") +

    # Set colour for incidence
    geom_line(data = subset(plot_weekly, type == "estimate"), aes(y = median), alpha = 1, colour = "#1d91c0") +
    geom_ribbon(data = subset(plot_weekly, type == "estimate"), aes(ymin = lower_20, ymax = upper_20, fill = "Estimate"), alpha = 0.3) +
    geom_ribbon(data = subset(plot_weekly, type == "estimate"), aes(ymin = lower_50, ymax = upper_50), alpha = 0.2, fill = "#1d91c0") +
    #  geom_ribbon(data = subset(plot_weekly, type == "estimate"), aes(ymin = lower_90, ymax = upper_90), alpha = 0.1, fill = "#1d91c0") +

    # Add an intercept at each section
    geom_vline(data = plot_weekly, aes(xintercept = (max(date[!is.na(confirm)]))), linetype = 2) +
    # geom_vline(data = plot_weekly, aes(xintercept = (max(date[type == "estimate"]))), linetype = 2, colour = "darkgrey") +

    # Plot epi curve for observed - have to remove the forecast rows to plot separately by colour
    geom_col(data = subset(plot_weekly, !is.na(confirm)), aes(y = confirm), alpha = 0.2) +

    theme_bw() +
    labs(
      x = "Date",
      y = "Cases by date of report",
      title = paste(adm_names),
      subtitle = paste0("Last reporting on ", format((max(plot_weekly$date[!is.na(plot_weekly$confirm)])+days(3)), "%d %B %Y"))
    ) +

    guides(fill = guide_legend(title = ""), colour = guide_legend(title = "")) +
    scale_x_date(date_breaks = "1 month", date_labels = "%b %d") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),
          legend.position = "bottom") +
    scale_fill_manual(values = c("Estimate" = "#1d91c0", "Nowcast" = "#FBEE95", "Forecast" = "#7fcdbb"))


  return(rep_week_fig)

}
