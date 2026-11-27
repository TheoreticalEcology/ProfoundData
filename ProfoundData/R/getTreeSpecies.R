# @title A get treespecies function
# @description  A function to provide information on available tree species in the
# ProfoundData database
# @param species a character string providing the name of the species
# @return a table with the species if not arguments are passed. Otherwise, it returns the
# species ID.
# @export
# @examples \dontrun{
# treeSpecies <- getTreeSpecies()
# }
# @keywords ProfoundData
# @author Ramiro Silveyra Gonzalez
getTreeSpecies <- function(species){
  table <- dbCall(RSQLite::dbGetQuery, "SELECT * FROM TREESPECIES")
  if(!is.null(species)){
    if (species %in% table[["species"]]){
      species_id <- table[table$species==species,]$species_id
    }else if(species %in% table[["species_id"]]){
      species_id <- table[table$species_id==species,]$species_id
    }else{
      stop("Invalid tree species", call. = FALSE)
    }
  }else{
    stop("Invalid tree species", call. = FALSE)
  }
  return(species_id)
}
