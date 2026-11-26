# @title A get variables function
# @description  A function to provide information on available variables of a
# dataset
# @param dataset a character string providing the name of the dataset
# @param quality a boolean to to see whether we want to see what variables have
# quality flags for the specified dataset.
# @return a vector with the available variables
# @export
# @keywords ProfoundData
# @author Ramiro Silveyra Gonzalez
getVariables <- function(dataset,  quality = FALSE){
  if(is.null(dataset)){
    stop("Please provide a dataset", call. = FALSE)
  }
  variablesAvailable <- dbCall(RSQLite::dbListFields, dataset)

  if (quality == TRUE){
    variablesNoFlags <- variablesAvailable[!grepl("_qc$", variablesAvailable)]
    dummyFlags <- gsub("\\_.*", "_qc", variablesNoFlags)
    names(dummyFlags) <- variablesNoFlags
    variablesFlags <- variablesAvailable[grepl("_qc$", variablesAvailable)]
    if (length(variablesFlags)>0){
      variablesFlags <- dummyFlags[dummyFlags %in% variablesFlags]
    }else{
      variablesFlags <- NULL
    }
    variablesAvailable <- variablesFlags
  }else{
    variablesAvailable <- variablesAvailable[!grepl("_qc$", variablesAvailable)]
  }
  return(variablesAvailable)
}
