#function to query Crossref using rcrossref
#use tryCatch to handle issns not in Crossref


getCrossrefData <- function(issn){

tryCatch(
  expr = {
    cr <- cr_journals_(issn, parse = TRUE)
    
    res_cr <- list(input = issn,
                output = cr$message)
    
    return(res_cr)
  },
  error = function(e){
    
    res_cr <- list(input = issn,
                  output = NULL)
    
   return(res_cr)
  }
  
)
}  


#function to add progress bar
getCrossrefData_progress <- function(x){
  pb$tick()$print()
  res <- getCrossrefData(x)
  
  return(res)
}

#define function to extract data
extractCrossrefData <- function(x){
  
  issn_input <- x$input
  
  title <- x$output %>%
    pluck("title", .default = NA)
  
  publisher <- x$output %>%
    pluck("publisher", .default = NA)
  
  total_dois <- x$output$counts %>%
    pluck("total-dois", .default = NA)
  
  res <- list(issn_input_cr = issn_input,
              title_cr = title,
              publisher_cr = publisher,
              total_dois_cr = total_dois)
  
}  
