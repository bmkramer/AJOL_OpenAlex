#This script queries the OpenAlex and Crossref APIs to check for presence of AJOL journals in OpenAlex
#Limitation: a subset of AJOL journals is checked: all OA journals listed in AJOL in July 2020
#This list was created for use in crowdsourced list of diamond journals (see link below).

#More information:
#AJOL: https://www.ajol.info/index.php/ajol
#Crowdsourced list of diamond journals:  https://tinyurl.com/diamond-journals
#OpenAlex API: https://docs.openalex.org/api
#rcrossref package: https://cran.r-project.org/web/packages/rcrossref/rcrossref.pdf 

#load packages
library(tidyverse)
library(httr)

# Set email as variable "openalex_email" in .Renviron
# Set email as variable "crossref_email" in .Renviron
#file.edit("~/.Renviron")
# Restart R session after saving .Renviron 

# Get email for OpenAlex as variable from .Renviron
email <- Sys.getenv("openalex_email")

#define function to query API
getData <- function(issn, var_email){
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


#define function to extract data (approach 1)
extractData <- function(x){
  
    issn_input <- x$input
    
    issn_l <- x$output %>%
      pluck("issn_l", .default = NA)
    
    display_name <- x$output %>%
      pluck("display_name", .default = NA)
    
    publisher <- x$output %>%
      pluck("publisher", .default = NA)
    
    works_count <- x$output %>%
      pluck("works_count", .default = NA)
    
    res <- list(issn_input = issn_input,
                issn_l = issn_l,
                display_name = display_name,
                publisher = publisher,
                works_count = works_count)
  
}  

  
#-------------------------------------------------------
  
#set date to date of sampling
#date <- Sys.Date()
date <- "2022-01-31"

#set path
path <- file.path("data",date) 


#load data (AJOL OA journal long format with unique issns)
data <- read_csv("data/AJOL_OA_issns_202007.csv")

#pull issns into character vector
issns <- data %>%
  pull(issn_value) %>%
  unique()

#NB This leaves out 5 titles with no ISSN (259 of 264 records)
# 352 journal-issn pairs,of which 350 unique issns 
# 2 journals (SAFP and SAJCN) have the same issn/eissn
 
----------------------------------------------

#query OpenAlex API, set email from .Renviron variable
res <- map(issns, ~getData(., 
                           var_email = email))

#extract selected variables into dataframe
res_df <- map_dfr(res, extractData)


filename <- paste0("AJOL_OA_OpenAlex_",date,".csv")
filepath <- file.path(path, filename)
write_csv(res_df, filepath)
res_df <- read_csv(filepath)

rm(res)
