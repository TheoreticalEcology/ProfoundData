
# Note: copied from BayesianTools::getPanels()

#' getPanels
#' 
#' Calculates the argument x for par(mfrow = x) for a desired number of panels
#' 
#' @author Florian Hartig
#' @param x the desired number of panels 
#' @return a numeric vector of length 2 with the number of rows and columns of panels.
#' @export
getPanels <- function(x){
  if (x <= 0) stop("number can't be < 1")
  
  lower = floor(sqrt(x))
  upper = ceiling(sqrt(x))
  
  if (lower == upper) return(c(lower, lower))
  else{
    if (lower * upper >= x) return(c(lower, upper))
    else return(c(upper, upper))    
  }
}  