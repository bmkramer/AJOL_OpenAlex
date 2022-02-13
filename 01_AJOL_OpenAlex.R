#This script queries the OpenAlex and Crossref APIs to check for presence of AJOL journals in OpenAlex

#More information:
#AJOL: https://www.ajol.info/index.php/ajol
#OpenAlex API: https://docs.openalex.org/api
#rcrossref package: https://cran.r-project.org/web/packages/rcrossref/rcrossref.pdf 

#STEP 1 - query OpenAlex API

#load packages
library(tidyverse)
library(httr)

source("R/query_OpenAlex.R")

# Set email as variable "openalex_email" in .Renviron
#file.edit("~/.Renviron")
# Restart R session after saving .Renviron 

# Get email for OpenAlex as variable from .Renviron
email <- Sys.getenv("openalex_email")


#set date to date of sampling
#date <- Sys.Date()
date <- "2022-02-13"
#set path
path <- file.path("data",date) 


#load data (AJOL journals in long format with unique issns)
filename <- paste0("AJOL_issns_",date,".csv")
filepath <- file.path(path, filename)
data <- read_csv(filepath)
#667 issns

#pull issns into character vector
issns <- data %>%
  pull(issn_value) %>%
  unique()
#665 unique issns
 
#set counter for progress bar
pb <- progress_estimated(length(issns))

#query OpenAlex API, set email from .Renviron variable
res <- map(issns, ~getOpenAlexData_progress(., 
                           var_email = email))
rm(pb)

#extract selected variables into dataframe
res_df <- map_dfr(res, extractOpenAlexData)


filename <- paste0("AJOL_OpenAlex_",date,".csv")
filepath <- file.path(path, filename)
write_csv(res_df, filepath)
#res_df <- read_csv(filepath)

rm(res)
