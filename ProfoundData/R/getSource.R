# @title A get source function
# @description  A function to provide information source of the dataset (which institution/entity provided the data)
# @return a table with the source information
# @examples \dontrun{
# dataSource <- getSource(dataset ="CLIMATE_ISIMIP2A", site = "soro")
# }
# @export
# @keywords ProfoundData
# @author Ramiro Silveyra Gonzalez
getSource <- function(dataset, site = NULL){
  if(is.null(site)){
    if (!getDatasets(dataset) ){stop("Invalid dataset", call. = FALSE)}
    table <- dbCall(RSQLite::dbGetQuery, paste("SELECT * FROM ", dataset, sep = ""))
  }else{
    site <- getsites(site)
    if (!getDatasets(dataset) || !site ){stop("Invalid dataset and/or site", call. = FALSE)}
    if(!checkAvailable(dataset, site)){stop("site specific source is not available", call. = FALSE)}
    dataset_site <- paste(dataset, site, sep="_")
    table <- dbCall(RSQLite::dbGetQuery, paste("SELECT * FROM ", dataset_site, sep = ""))
  }
  return(table)
}

