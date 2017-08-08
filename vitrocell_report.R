## goal: geneate reproducible reports from the logfiles of Vitrocell ALI exposure systems
setwd("D:/GoogleDrive/KIT work google drive/R scripts/Vitrocell ali report")



library(dplyr)
library(ggplot2)
library("reshape2")


log <- read.delim(file = "exampleLog.csv", sep = ";", header = T, as.is = T, skip = 3)

#todo set_values (line 2 & 3 of logfile)

log$time <- strptime(log$sDateTime, format = "%d/%m/%Y %T")


# setup

# Experiment start time
print(log$time[1])
#print(log$time[length(log$time)])
# Experiment duration
round((difftime(log$time[length(log$time)], log$time[1], units = "mins"))[[1]])

#todo? start timescale at 0:00


# create list with log infos, ids units, etc

log_structure <- list(id = colnames(select(log, contains("flow"), contains("humidity"), contains("differential.pressure"), contains("temp")))) # all cols of interest (for now: flow and humidity)
log_structure$label <- regmatches(log_structure$id, regexpr("^(.+)\\.{2}", log_structure$id))
#log_structure$label <- strsplit(log_structure$id, "\\.{2}"))
 # regmatches(log_structure$id, regexpr("^(.+)\\.{2}", log_structure$id))
log_structure$unit <- regmatches(log_structure$id, regexpr("\\.{2}(.+)\\.$", log_structure$id))
log_structure$class <- as.factor(ifelse(
  grepl("massflow", log_structure$label) & grepl("ml.min", log_structure$unit), "massflow", ifelse(
  grepl("flow", log_structure$label) & grepl("l.h", log_structure$unit), "totalmassflow", ifelse(
  grepl("temperature", log_structure$label), "temp", ifelse(
  grepl("humidity", log_structure$label), "humidity", ifelse(
  grepl("differential.pressure", log_structure$label), "pressure",
  "unknown"))))
  ))
log_structure$ymin <- unlist(lapply(log[log_structure$id], min)) #für gleiches Format wie rest: as.vector()
log_structure$ymax <- unlist(lapply(log[log_structure$id], max)) #für gleiches Format wie rest: as.vector()





# create table to lookup for units, baselabel (= massflow, humidity...etc) based on class



  
# function plot column, so allgemein wie möglich

plot_id <- log_structure$id[10]

plotAliLog <- function(plot_id) {
print(plot_id)
#data <- log %>% select(time, paste(plot_id))
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
       title = ifelse(class == "massflow" & y_max > 300,"Warning: sensor floating?", 
               ifelse(y_min == 0 & y_max == 0, "Warning: no sensor readings",""))
       ) + # if multiple log files should be processed as a batch, put the origin of the data in the caption/title/subtitle
  theme(legend.position="none")

}
plotAliLog(plot_id)

pdf(file = "pdf_out.pdf", onefile = TRUE)
# look into "multiplot" http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/
lapply(X = log_structure$id, FUN = plotAliLog)
dev.off()
