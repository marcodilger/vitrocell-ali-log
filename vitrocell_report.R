## goal: geneate reproducible reports from the logfiles of Vitrocell ALI exposure systems


library(dplyr)
library(ggplot2)
library(reshape2)


log <- read.delim(file = "exampleLog.csv", sep = ";", header = T, as.is = T, skip = 3)

#todo set_values (line 2 & 3 of logfile)

log$time <- strptime(log$sDateTime, format = "%d/%m/%Y %T")


# setup

# Experiment start time
print(log$time[1])
# Experiment end time
print(tail(log$time, 1))
# Experiment duration
round((difftime(log$time[length(log$time)], log$time[1], units = "mins"))[[1]])

#todo? start timescale at 0:00




source("log_structure.R") # creates a list with log infos, ids units, etc

# todo create table to lookup for units, baselabel (= massflow, humidity...etc) 
# based on class for clean plot labels

  
source("plot_log.R") # reads in the function to create the plots


plot_id <- log_structure$id[11]

plot_ali_log(plot_id)

pdf(file = "pdf_out.pdf", onefile = TRUE)
# look into "multiplot" http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/
lapply(X = log_structure$id, FUN = plot_ali_log)
dev.off()
