plotPROFOUND.TREE <-function(tmp){
  data <- tmp[["data"]]
  if(!inherits(data, "data.frame")) stop(paste("Error when querying:", tmp[["item"]]), call. = FALSE)
  st.err <- function(x) {
    sd(x, na.rm = T)/sqrt(length(x))
  }
  if(!"species" %in% colnames(data)) stop("Missing species!", call. = FALSE)
  if(!"year" %in% colnames(data)) stop("Missing year!", call. = FALSE)
  oldpar <- par(no.readonly = TRUE)
  on.exit(par(oldpar))
  spp <- unique(data$species)
  for (i in 1:length(spp)){
    dataSpp <- data[data$species == spp[i], ]
    years <- unique(dataSpp$year)
    if (length(years) ==1){
      warning(paste("Can't plot data for ", spp[i], ". There is data only for one year!", sep = ""), call. = FALSE)
    }else{
      plotDBH <- FALSE
      plotHeight <- FALSE
      plotCombined <- FALSE
      overviewPlots <- 0
      if ("dbh1_cm" %in% names(dataSpp))  plotDBH <- TRUE
      if ("height1_m" %in% names(dataSpp))  plotHeight <- TRUE
      if(plotDBH & plotHeight) plotCombined <- TRUE
      # Check if only variable is requested
      if (plotHeight & plotDBH & plotCombined){
        overviewPlots <- 4
      } else if (plotHeight || plotDBH & !plotCombined){
        overviewPlots <- 2
      }
      # This a values for segment(s)
      epsilon <- 0.1
      yearRange <- range(dataSpp$year, na.rm = T)
     # cat("There are ");cat(overviewPlots);cat(" plots")
      if(tmp[["automaticPanels"]] == T){
        par(mfrow = getPanels(overviewPlots), mar=c(2,2,2,0.5))
      }else{
        par(mfrow = c(1,1), mar=c(4,4,4,2))
      }

      # Histrogram based on year
      # create positions for tick marks, one more than number of bars
      atYear <- 1:(length(unique(dataSpp$year)) + 1)
      mp <- barplot(table(dataSpp$year),unique(dataSpp$year), main = paste( spp[i], ": Trees by inventory",  sep = ""),
              xlab = "year", ylab = "N trees", col = NA,  xaxt = "n")
      # add x-axis with offset positions, with ticks, but without labels.
      axis(side = 1, at = mp, labels = FALSE)
      # add x-axis with centered position, with labels, but without ticks.
      axis(side = 1, at = mp[seq(1, length(unique(dataSpp$year)), 2)],
           tick = FALSE, labels = unique(dataSpp$year)[seq(1, length(unique(dataSpp$year)), 2)])

      # Plot averaged DBH
      if(plotDBH){
        meanSppDBH <- aggregate(dataSpp$dbh1_cm  ~ dataSpp$year,  dataSpp, mean, na.action = na.omit, simplify = T)
        seSppDBH <- aggregate(dataSpp$dbh1_cm  ~ dataSpp$year,  dataSpp, st.err, na.action = na.omit, simplify = T)
        if (all(is.na(seSppDBH[,2]))) seSppDBH[,2] <- 0
        ylim <- c(floor(meanSppDBH[1,2] - seSppDBH[1,2]), ceiling(meanSppDBH[nrow(meanSppDBH),2] + seSppDBH[nrow(seSppDBH),2]))
        plot(meanSppDBH, main = paste( spp[i], ": mean dbh1_cm by year",  sep = ""),
             xlab = "year", ylab = "dbh1_cm", type = "l", ylim = ylim, xaxt = "n")
        axis(side = 1, at = unique(dataSpp$year), labels = unique(dataSpp$year))
        mtext("segment(s) indicate standard error", side = 3, cex = 0.6)
        segments(meanSppDBH[,1], meanSppDBH[,2]-seSppDBH[,2],meanSppDBH[,1], meanSppDBH[,2]+seSppDBH[,2])
        segments(meanSppDBH[,1]-epsilon,meanSppDBH[,2]-seSppDBH[,2],meanSppDBH[,1]+epsilon,meanSppDBH[,2]-seSppDBH[,2])
        segments(meanSppDBH[,1]-epsilon,meanSppDBH[,2]+seSppDBH[,2],meanSppDBH[,1]+epsilon,meanSppDBH[,2]+seSppDBH[,2])
      }
      # Plot averaged height
      if(plotHeight){
        meanSppHeight <- aggregate(dataSpp$height1_m ~ dataSpp$year, dataSpp, mean, na.action = na.omit)
        seSppHeight <- aggregate(dataSpp$height1_m  ~ dataSpp$year,  dataSpp, st.err, na.action = na.omit, simplify = T)
        if (all(is.na(seSppHeight[,2]))){
          seSppHeight[,2] <- 0
        }
        ylim <- c(floor(min(meanSppHeight[,2], na.rm = T) - max(seSppHeight[,2], na.rm = T)),
                  ceiling(max(meanSppHeight[,2], na.rm = T) + max(seSppHeight[,2], na.rm = T)))
        if(nrow(meanSppHeight)==1){
          onlyValue <- round(mean(meanSppHeight[,2], na.rm = T), digits = 0)
          if (2 > max(seSppHeight[,2], na.rm = T)) ylim <- c(onlyValue -2, onlyValue + 2)
          message(paste(spp[i], "has height data only for one year!", sep = " "))
          if(length(dataSpp$height1_m[!is.na(dataSpp$height1_m)])== 1) message(paste(spp[i], "has only one height measurement", sep = " "))
          plot(meanSppHeight, main = paste( spp[i], ": mean height1_m by year",  sep = ""),
               xlab = "year", ylab = "height1_m", type = "p", ylim = ylim,  xaxt = "n")
          axis(side = 1, at = unique(dataSpp$year), labels = unique(dataSpp$year))
       #   text(meanSppHeight[,1], meanSppHeight[,2] -5, paste(spp[i], "has height1_m data only for one year!", sep=" "))
        }else{
          plot(meanSppHeight, main = paste( spp[i], ": mean height1_m by year",  sep = ""),
               xlab = "year", ylab = "height1_m", type = "l", ylim = ylim, xaxt = "n")
          axis(side = 1, at = unique(dataSpp$year), labels = unique(dataSpp$year))
        }
        mtext("segment(s) indicate standard error", side = 3, cex = 0.6)
        segments(meanSppHeight[,1], meanSppHeight[,2]-seSppHeight[,2],meanSppHeight[,1], meanSppHeight[,2]+seSppHeight[,2])
        segments(meanSppHeight[,1]-epsilon,meanSppHeight[,2]-seSppHeight[,2],meanSppHeight[,1]+epsilon,meanSppHeight[,2]-seSppHeight[,2])
        segments(meanSppHeight[,1]-epsilon,meanSppHeight[,2]+seSppHeight[,2],meanSppHeight[,1]+epsilon,meanSppHeight[,2]+seSppHeight[,2])
      }
      # Plot height against DBH
      if (plotHeight & plotDBH & plotCombined){
        HDBHRange <- range(range(dataSpp$dbh1_cm, na.rm =T), range(dataSpp$height1_m, na.rm = T))
        HDBHRange <-c(floor(HDBHRange[1]), ceiling(HDBHRange[2]))

        plot(dataSpp$dbh1_cm, dataSpp$height1_m,  main = paste( spp[i], ": height1_m to dbh1_cm ratio", sep = ""),
             xlab = "dbh1_cm", ylab = "height1_m", xlim = HDBHRange, ylim= HDBHRange,
             pch = 3)
      }
    }
  }
}



plotPROFOUND.STAND <-function(tmp){
  data <- tmp[["data"]]
  if(!inherits(data, "data.frame")) stop(paste("Error when querying:", tmp[["item"]]), call. = FALSE)
  standVariables <- c("foliageBiomass_kgha", "branchesBiomass_kgha", "stemBiomass_kgha",#"age",# age is too trivial
                      "rootBiomass_kgha", "stumpCoarseRootBiomass_kgha", "coarseBiomass_kgha",
                      "LAI", "lai", "height_m", "dbh_cm", "density_ha", "stem", "aboveGroundBiomass_kgha",
                      "dbhArith_cm", "dbhBA_cm", "dbhDQ_cm", "heightArith_m", "heightBA_m",
                      "ba_m2ha", "density_treeha")

  if(!"species" %in% colnames(data)) stop("Missing species!", call. = FALSE)
  if(!"year" %in% colnames(data)) stop("Missing year!", call. = FALSE)
  plotVariables <- standVariables[standVariables %in% colnames(data)]
  if(length(plotVariables) < 1) stop("There is nothing to plot!", call. = FALSE)
  oldpar <- par(no.readonly = TRUE)
  on.exit(par(oldpar))
  spp <- unique(data$species)
  for (i in 1:length(spp)){
    dataSpp <- data[data$species == spp[i], ]
    yearRange <- range(dataSpp$year, na.rm = T)
    if(tmp[["automaticPanels"]] == T){
      par(mfrow = getPanels(length(plotVariables)), mar=c(2,2,2,0.5))
    }else{
      par(mfrow = c(1,1), mar=c(4,4,4,2))
    }
    for (j in 1:length(plotVariables)){
      lenghtVariable <- length(dataSpp[,plotVariables[j]][!is.na(dataSpp[,plotVariables[j]])])
      if (lenghtVariable > 1 ){
        plot(dataSpp$year, dataSpp[,plotVariables[j]],  main = paste( spp[i], ": ", plotVariables[j], sep = ""),
           ylab = plotVariables[j], xlab = "year", type = "l", xlim= yearRange)
      }else if (lenghtVariable == 1 ){
        plot(dataSpp$year, dataSpp[,plotVariables[j]],  main = paste( spp[i], ": ", plotVariables[j], sep = ""),
             ylab = plotVariables[j], xlab = "year", type = "p", xlim= yearRange, pch= 3)
      }
 #     if (lenghtVariable == 1 )  text(floor(mean(dataSpp$year, na.rm = T)), floor(mean(dataSpp[,plotVariables[j]], na.rm = T)), paste(spp[i], "has ", plotVariables[j] , "data only for one year!", sep=" "))
     # if (lenghtVariable == 0 )   text(floor(mean(dataSpp$year, na.rm = T)), floor(mean(dataSpp[,plotVariables[j]], na.rm = T)), paste(spp[i], "has no",  plotVariables[j] ,"data!", sep=" "))
    }
  }
}


# Converts data with a date column into a zoo object, aggregated by date, year-month or year if
# aggregated is given. fixes #54: the unique row index replaces ts(), which recycled rows when
# their number did not match the date range (e.g. half-hourly data)
zooPROFOUND <- function(data, aggregated = NULL, FUN = mean){
  x <- data.matrix(data)
  if (is.null(aggregated)) return(zoo::zoo(x, data$date))
  by <- switch(aggregated, date = , day = data$date,
               month = zoo::as.yearmon(data$date), year = data$year)
  aggregate(zoo::zoo(x), by, FUN = FUN)
}

plotPROFOUND.DAILY <-function(tmp, forcing = NULL){
  data <- tmp[["data"]]
  if(!inherits(data, "data.frame")) stop(paste("Error when querying:", tmp[["item"]]), call. = FALSE)
  if(!"date" %in% colnames(data)) stop("Missing date!", call. = FALSE)
  if(!"year" %in% colnames(data)) stop("Missing year!", call. = FALSE)
  if(!"mo" %in% colnames(data)) stop("Missing mo!", call. = FALSE)
  if(!"day" %in% colnames(data)) stop("Missing day!", call. = FALSE)
  data$date <- as.Date(data$date, format = "%Y-%m-%d")
  data.ts <- zooPROFOUND(data, tmp[["aggregated"]], tmp[["FUN"]])
  aggText <- NULL
  if (!is.null(tmp[["aggregated"]])) aggText <- paste("aggregated by", tmp[["aggregated"]], sep = " ")
  plotVariables <- tmp[["variablesChecked"]][!grepl("_qc$",tmp[["variablesChecked"]] )]
  plotVariables <- plotVariables[plotVariables %in% names(data.ts) ]
  if(tmp[["automaticPanels"]] == T){
    oldpar <- par(mfrow = getPanels(length(plotVariables)), mar=c(2,2,2,0.5))
    on.exit(par(oldpar)) 
  }else{
    oldpar <- par(mfrow = c(1,1), mar=c(4,4,4,2))
    on.exit(par(oldpar)) 
  }
  for (i in 1:length(plotVariables)){
    if(length(data.ts[,  plotVariables[i]][is.na(data.ts[,  plotVariables[i]])]) == length(data.ts[,  plotVariables[i]])){
      warning(paste(plotVariables[i], ": No data to plot", sep=""))
    }else{
      plot(data.ts[,  plotVariables[i]],
           main =  paste( tmp[["dataset"]], " ", forcing, ": ", plotVariables[i], sep =""),
           xlab = paste("Time period: ", as.character(min(data$date)),"-", as.character(max(data$date)),sep=" "),
           ylab = "Value")
      if(!is.null(aggText)){
        mtext(aggText, side = 3, cex = 0.6)
      }
    }
  }
}

plotPROFOUND.HALFHOURLY <- function(tmp){
  data <- tmp[["data"]]
  if(!inherits(data, "data.frame")) stop(paste("Error when querying:", tmp[["item"]]), call. = FALSE)
  if(!"date" %in% colnames(data)) stop("Missing date!", call. = FALSE)
  if(!"year" %in% colnames(data)) stop("Missing year!", call. = FALSE)
  if(!"mo" %in% colnames(data)) stop("Missing mo!", call. = FALSE)
  if(!"day" %in% colnames(data)) stop("Missing day!", call. = FALSE)
  data$date <- as.Date(data$date, format = "%Y-%m-%d")
  if (!is.null(tmp[["aggregated"]])){
    aggText <- paste("aggregated by", tmp[["aggregated"]], sep = " ")
    data.ts <- zooPROFOUND(data, tmp[["aggregated"]], tmp[["FUN"]])
  }else{
    message("Plotting averaged data from half-hourly")
    aggText <- "aggregated by date with FUN = mean"
    data.ts <- zooPROFOUND(data, "date", function(x) mean(x, na.rm = T))
  }
  plotVariables <- tmp[["variablesChecked"]][!grepl("_qc$",tmp[["variablesChecked"]] )]
  plotVariables <- plotVariables[plotVariables %in% names(data.ts) ]
  if(tmp[["automaticPanels"]] == T){
    oldpar <- par(mfrow = getPanels(length(plotVariables)), mar=c(2,2,2,0.5))
    on.exit(par(oldpar)) 
  }else{
    oldpar <- par(mfrow = c(1,1), mar=c(4,4,4,2))
    on.exit(par(oldpar)) 
  }
  for (i in 1:length(plotVariables)){
    if(length(data.ts[,  plotVariables[i]][is.na(data.ts[,  plotVariables[i]])]) == length(data.ts[,  plotVariables[i]])){
      warning(paste(plotVariables[i], ": No data to plot", sep=""), call. = FALSE)
    }else{
      plot(data.ts[,  plotVariables[i]],
           main =  paste( tmp[["dataset"]], ": ", plotVariables[i], sep =""),
           xlab = paste("Time period: ", as.character(min(data$date)),"-", as.character(max(data$date)),sep=" "),
           ylab = "Value")
      if(!is.null(aggText)){
        mtext(aggText, side = 3, cex = 0.6)
      }
    }
  }
}


plotPROFOUND.YEARLY <- function(tmp, forcing = NULL){
  data <- tmp[["data"]]
  if(!inherits(data, "data.frame")) stop(paste("Error when querying:", tmp[["item"]]), call. = FALSE)
  if(!"year" %in% colnames(data)) stop("Missing year!", call. = FALSE)
  data$date <- data$year
  data.ts <- zooPROFOUND(data)

  plotVariables <- tmp[["variablesChecked"]][!grepl("_qc$",tmp[["variablesChecked"]] )]
  plotVariables <- plotVariables[plotVariables %in% names(data.ts) ]
  if(tmp[["automaticPanels"]] == T){
    oldpar <- par(mfrow = getPanels(length(plotVariables)), mar=c(2,2,2,0.5))
    on.exit(par(oldpar)) 
  }else{
    oldpar <- par(mfrow = c(1,1), mar=c(4,4,4,2))
    on.exit(par(oldpar)) 
  }
  for (i in 1:length(plotVariables)){
    if(length(data.ts[,  plotVariables[i]][is.na(data.ts[,  plotVariables[i]])]) == length(data.ts[,  plotVariables[i]])){
      warning(paste(plotVariables[i], ": No data to plot", sep=""), call. = FALSE)
    }else{
      plot(data.ts[,  plotVariables[i]],
           main =  paste( tmp[["dataset"]]," ", forcing, ": ", plotVariables[i], sep =""),
           xlab = paste("Time period: ", as.character(min(data$date)),"-", as.character(max(data$date)),sep=" "),
           ylab = "Value")
    }
  }
}

plotPROFOUND.MODIS <- function(tmp){
  data <- tmp[["data"]]
  if(!inherits(data, "data.frame")) stop(paste("Error when querying:", tmp[["item"]]), call. = FALSE)
  if(!"date" %in% colnames(data)) stop("Missing date!", call. = FALSE)
  if(!"year" %in% colnames(data)) stop("Missing year!", call. = FALSE)
  if(!"mo" %in% colnames(data)) stop("Missing mo!", call. = FALSE)
  if(!"day" %in% colnames(data)) stop("Missing day!", call. = FALSE)
  data$date <- as.Date(data$date, format = "%Y-%m-%d")
  data.ts <- zooPROFOUND(data, tmp[["aggregated"]], tmp[["FUN"]])
  plotVariables <- tmp[["variablesChecked"]][!grepl("_qc$",tmp[["variablesChecked"]] )]
  plotVariables <- plotVariables[!grepl("Cor$",plotVariables )]
  plotVariables <- plotVariables[plotVariables %in% names(data.ts) ]
  if(tmp[["automaticPanels"]] == T){
    oldpar <- par(mfrow = getPanels(length(plotVariables)), mar=c(2,2,2,0.5))
    on.exit(par(oldpar)) 
  }else{
    oldpar <- par(mfrow = c(1,1), mar=c(4,4,4,2))
    on.exit(par(oldpar)) 
  }
  #par(mar=c(4,4,4,2)) #bltr
  #par(mar=c(2,2,2,0.5)) #bltr
  for (i in 1:length(plotVariables)){
    if(length(data.ts[,  plotVariables[i]][is.na(data.ts[,  plotVariables[i]])]) == length(data.ts[,  plotVariables[i]])){
      warning(paste(plotVariables[i], ": No data to plot", sep=""), call. = FALSE)
    }else{
      ylim <- range(data.ts[is.finite(data.ts[,  plotVariables[i]]),  plotVariables[i]], na.rm = T)
      plot(data.ts[,  plotVariables[i]],
           main =  paste( tmp[["dataset"]], ": ", plotVariables[i], sep =""),
           xlab = paste("Time period: ", as.character(min(data$date)),"-", as.character(max(data$date)),sep=" "),
           ylab = "Value", ylim = ylim)
      if(!is.null(tmp[["aggregated"]])) mtext(paste("aggregated by", tmp[["aggregated"]]), side = 3, cex = 0.6)
    }
  }
}

plotPROFOUND.ISIMIP <- function(tmp){
  data <- tmp[["data"]]
  plotForcing <- function(df, forcing = NULL){
    # fixes #54 (a forcing without data in the period stopped the plot with "Missing date!")
    if (nrow(df) == 0){
      warning(paste(tmp[["dataset"]], " ", forcing, ": No data to plot", sep = ""), call. = FALSE)
      return(invisible())
    }
    tmp[["data"]] <- df[,colSums(is.na(df))<nrow(df)]
    # check whether is daily or yearly
    if (!"date" %in% names(df)) plotPROFOUND.YEARLY(tmp, forcing = forcing) else plotPROFOUND.DAILY(tmp, forcing = forcing)
  }
  if (inherits(data, "data.frame")){
    plotForcing(data)
  }else if (inherits(data, "list")){
    message("You are trying to plot several forcings. It will take long!")
    if (inherits(data[[1]], "list")){
      for (i in 1:length(data)){
        for (j in 1:length(data[[i]])){
          plotForcing(data[[i]][[j]], forcing = paste(names(data)[i],names(data[[i]])[j], sep="_"))
        }
      }
    }else if (inherits(data[[1]], "data.frame")){
      for (i in 1:length(data)){
        plotForcing(data[[i]], forcing = names(data)[i])
      }
    }else{
      warning("You might have found a bug! Please report it", call. = FALSE)
    }
  }
}
