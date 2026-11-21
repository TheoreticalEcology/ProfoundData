#calculate_basal_area <- function(tree) {
#ba <- as.data.frame(aggregate(tree$dbh1_cm, by=list(year=tree$year, species=tree$species), function(x) sum(0.25 *pi * x^2)))
#  names(ba)[names(ba) =="x"] <- "basal_area_cm2"
#  if (length(unique(tree$size_m2)) == 1) ba$basal_area_m2_per_ha <- (ba$basal_area_cm2/(100*100))/(unique(tree$size_m2)/(100*100))
#  ba
#}


meanSquaredDiameter <- function(dbh){
  if(length(dbh[!is.na(dbh)])==0){
    dq_cm <- NA
  }else{
    dq_cm <- sqrt(sum(dbh**2, na.rm = T)/length(dbh[!is.na(dbh)]))
  }
  return(dq_cm)
}

LoreysMeanDBH <- function(dbh){
  ba_cm2 <- sapply(dbh, function(x){pi * (x/2)**2})
  dbh_cm <- sum((ba_cm2 * dbh), na.rm = T)/sum(ba_cm2, na.rm = T)
  #height_m <- sqrt(sum(height**2, na.rm = T)/length(height[!is.na(height)]))
  return(dbh_cm)
}

LoreysMeanHeight <- function(height, dbh){
  if(length(height[!is.na(height)])==0){
    height_m <- NA
  }else{
    ba_m2 <- sapply(dbh/100, function(x){pi * (x/2)**2})
    ba_m2 <- ba_m2[!is.na(height)]
    height <- height[!is.na(height)]
    height_m <- sum((ba_m2 * height), na.rm = T)/sum(ba_m2, na.rm = T)
    #height_m <- sqrt(sum(height**2, na.rm = T)/length(height[!is.na(height)]))
  }
  return(height_m)
}

# basal area of stand
standBA <- function(dbh, plotSize){
  if(length(dbh[!is.na(dbh)])==0){
    ba_m2ha <- NA
  }else{
    ba_m2 <- sapply(dbh/100, function(x){pi * (x/2)**2})
    A_ha <-  unique(plotSize)* (1/10000)
    ba_m2ha <- sum(ba_m2, na.rm = T) / A_ha
  }
  return(ba_m2ha)
}
