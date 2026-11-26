# @title A get policy function
# @description  A function to provide information on the policy of the dataset
# @return a table with the policy information for the specified dataset and site
# @examples \dontrun{
# dataPolicy <- getPolicy(dataset ="CLIMATE_ISIMIP2A", site = "soro")
# }
# @export
# @keywords ProfoundData
# @author Ramiro Silveyra Gonzalez
getPolicy <- function(dataset, site = NULL){
  if(is.null(site)){
    if (!getDatasets(dataset) ){stop("Invalid dataset", call. = FALSE)}
    table <- dbCall(RSQLite::dbGetQuery, paste("SELECT * FROM ", dataset, sep = ""))
  }else{
    site <- getsites(site)
    if (!getDatasets(dataset) || !site ){stop("Invalid dataset and/or site", call. = FALSE)}
    if(!checkAvailable(dataset, site)){stop("site specific policy is not available", call. = FALSE)}
    dataset_site <- paste(dataset, site, sep="_")
    table <- dbCall(RSQLite::dbGetQuery, paste("SELECT * FROM ", dataset_site, sep = ""))
  }
  return(table)
}
