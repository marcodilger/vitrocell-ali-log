# creates a list with log infos, ids units, etc

log_structure <- list(id = colnames(select(log, contains("flow"), contains("humidity"), contains("differential.pressure"), contains("temp")))) # all cols of interest
log_structure$label <- regmatches(log_structure$id, regexpr("^(.+)\\.{2}", log_structure$id))
log_structure$unit <- regmatches(log_structure$id, regexpr("\\.{2}(.+)\\.$", log_structure$id))
log_structure$class <- as.factor(
  ifelse(grepl("massflow", log_structure$label) & grepl("ml.min", log_structure$unit), "massflow", 
         ifelse(grepl("flow", log_structure$label) & grepl("l.h", log_structure$unit), "totalmassflow", 
                ifelse(grepl("temperature", log_structure$label), "temp", 
                       ifelse(grepl("humidity", log_structure$label), "humidity", 
                              ifelse(grepl("differential.pressure", log_structure$label), "pressure",
                                     "unknown"))))
  ))
log_structure$ymin <- unlist(lapply(log[log_structure$id], min)) #in case consistent formatting is needed: as.vector()
log_structure$ymax <- unlist(lapply(log[log_structure$id], max)) #in case consistent formatting is needed: as.vector()

