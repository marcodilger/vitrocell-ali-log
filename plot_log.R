# plot function, needs to be kept as general as possible

plot_ali_log <- function(plot_id) {
  
  cat(paste("plotting id:",plot_id))
  
  data_long <- melt(subset(log, select=c("time", plot_id)), id="time")
  
  current_col <- which(log_structure$id == plot_id)
  class <- log_structure$class[current_col]
  y_max <- ceiling(log_structure$ymax[current_col]/10)*10
  y_min <- floor(log_structure$ymin[current_col]/10)*10
  y_lab <- gsub(x = paste0(log_structure$label[current_col],"[",log_structure$unit[current_col],"]"), pattern = "\\.+", replacement = " ")
  
  ggplot(data = data_long,
         aes(x = time, y = value, colour = variable)) +
    ylim(c(y_min, y_max)) +
    geom_line() +
    labs(y = y_lab, 
         title = ifelse(class == "massflow" & y_max > 300,"Warning: sensor floating?",  # 2 b improved, needs to account for other classes and mass flows with higher set_values as well
                        ifelse(y_min == 0 & y_max == 0, "Warning: no sensor readings",
                               "")
         )
    ) + # todo: if multiple log files should be processed as a batch, put the origin of the data in the caption/title/subtitle
    theme(legend.position="none")
}
