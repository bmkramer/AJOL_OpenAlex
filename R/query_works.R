#functions to query OpenAlex API
getOpenAlexData <- function(issn, var_email){
  url <- paste0("https://api.openalex.org/",
                "venues/issn:",
                issn,
                "?mailto=",
                email)
  raw_data <- GET(url)
  rd <- httr::content(raw_data)
  
  res <- list(input = issn,
              output = rd)
}

#functions to add progress bar
getOpenAlexData_progress <- function(x, var_email){
  pb$tick()$print()
  res <- getOpenAlexDataISSN(x, var_email)
  
  return(res)
}

#function to extract data (approach 1)
extractOpenAlexData <- function(x){
  
    issn_input <- x$input
    
    issn_l <- x$output %>%
      pluck("issn_l", .default = NA)
    
    display_name <- x$output %>%
      pluck("display_name", .default = NA)
    
    publisher <- x$output %>%
      pluck("publisher", .default = NA)
    
    works_count <- x$output %>%
      pluck("works_count", .default = NA)
    
    created_date <- x$output %>%
      pluck("created_date", .default = NA)
    
    res <- list(issn_input = issn_input,
                issn_l = issn_l,
                display_name = display_name,
                publisher = publisher,
                works_count = works_count,
                created_date = created_date)
  
}  

  