# @title A get datasets function
# @description  A function to provide information on available datasets in the
# ProfoundData database
# @param dataset a character string providing the name of the dataset (optional)
# @return a vector with the available datasets if no arguments are passed. Otherwise,
# it returns a numeric boolean.
# @export
# @examples \dontrun{
# datasets <- getDatasets()
# }
# @keywords ProfoundData
# @author Ramiro Silveyra Gonzalez
getDatasets <- function(dataset = NULL){
  datasets.available <- dbCall(RSQLite::dbListTables)
  datasets.available <- datasets.available[!grepl("_master", datasets.available)]
  if(!is.null(dataset)){
    if (dataset %in% datasets.available){
      dataset.checked <- 1
    }else{
      dataset.checked  <- 0
    }
  }else{
    dataset.checked <- datasets.available[!grepl("_[0-9]|OVERVIEW", datasets.available)]
  }
  return(dataset.checked)
}
