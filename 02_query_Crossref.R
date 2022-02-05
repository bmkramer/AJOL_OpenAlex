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
library(rcrossref)

# Set email as variable "openalex_email" in .Renviron
# Set email as variable "crossref_email" in .Renviron
#file.edit("~/.Renviron")
# Restart R session after saving .Renviron 

# Get email for OpenAlex as variable from .Renviron

#define function to query Crossref using rcrossref
#use tryCatch to handle issns not in Crossref


getData_cr <- function(issn){

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

#define function to extract data (approach 1)
extractData_cr <- function(x){
  
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

  
#-------------------------------------------------------
  
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


#query Crossref API, get email automatically from .Renviron with rcrossref
res_cr <- map(issns, getData_cr)

#extract selected variables into dataframe
res_cr_df <- map_dfr(res_cr, extractData_cr)

write_csv(res_cr_df, "data/AJOL_OA_Crossref_20220131.csv")
#res_cr_df <- read_csv("data/AJOL_OA_Crossref_20220131.csv")

rm(res_cr)

