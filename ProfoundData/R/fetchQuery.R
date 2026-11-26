# @title A function to query data from a DB
#
# @description This function queries data on DB and returns the query
# @param tmp a named list containing needed parameters for executing the query
# @return tmp an object containing the queried data
# @keywords ProfoundData
# @author Ramiro Silveyra Gonzalez

fetchQuery <- function(tmp) {
  if(is.null(tmp[["site"]]))    message(paste("Reading data from" , tmp[["dataset"]],  sep = " "))
  queried <- try(dbCall(RSQLite::dbGetQuery, tmp[["item"]]))
  if ('try-error' %in% class(queried) || nrow(queried) < 1) {
    tmp[["query"]] <- paste ("Error when querying:", tmp[["item"]], sep = " ") # do something about this
  }else{
    tmp[["query"]] <- queried
  }
  return (tmp)
}
