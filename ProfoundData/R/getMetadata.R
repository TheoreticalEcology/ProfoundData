# @title A get metadata function
# @description  A function to provide metadata for the dataset
# @return a table with the metadata for the specified dataset and site
# @examples \dontrun{
# dataMetadata <- getMetadata(dataset ="CLIMATE_ISIMIP2A", site = "soro")
# }
# @export
# @keywords ProfoundData
# @author Ramiro Silveyra Gonzalez
getMetadata <- function(dataset, site = NULL){
  firstVariables <- c("record_id", "site", "site2", "site_id", "species", "species_id",
                      "forcingCondition", "forcingDataset",
                      "description", "reference",  "date", "year", "mo", "day")

  if(is.null(site)){
    if (!getDatasets(dataset) ){stop("Invalid dataset", call. = FALSE)}
    table <- dbCall(RSQLite::dbGetQuery, paste("SELECT * FROM ", dataset, sep = ""))
  }else{
    site <- getsites(site)
    if (!getDatasets(dataset) || !site ){stop("Invalid dataset and/or site", call. = FALSE)}
    if(!checkAvailable(dataset, site)){stop("Metadata is not available", call. = FALSE)}
    dataset_site <- paste(dataset, site, sep="_")
    table <- dbCall(RSQLite::dbGetQuery, paste("SELECT * FROM ", dataset_site, sep = ""))
  }
  tableVariables <- unique(table$variable)
  variablesOrder <- c(firstVariables[firstVariables %in% tableVariables],
                      tableVariables[!tableVariables %in% firstVariables])
  if(!any(duplicated(table$variable))){
    table <- table[match(variablesOrder, table$variable),]
    rownames(table) <- NULL
  }else{
    sources <- unique(table$source)
    tableList <- lapply(sources, function(x){
      dummy <- table[table$source ==x, ]
      dummy <- dummy[match(variablesOrder, dummy$variable),]
      dummy <- dummy[!is.na(dummy$variable),]
      return(dummy)
    })
    table <- Reduce(rbind, tableList)
#    table <- tableList
    rownames(table) <- NULL
  }

  return(table)
}

