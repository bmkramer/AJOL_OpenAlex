#This script queries the OpenAlex and Crossref APIs to check for presence of AJOL journals in OpenAlex

#More information:
#AJOL: https://www.ajol.info/index.php/ajol
#OpenAlex API: https://docs.openalex.org/api
#rcrossref package: https://cran.r-project.org/web/packages/rcrossref/rcrossref.pdf 

#STEP 2 - query Crossref API (journal route)

#load packages
library(tidyverse)
library(rcrossref)

source("R/query_Crossref.R")

# Set email as variable "crossref_email" in .Renviron
#file.edit("~/.Renviron")
# Restart R session after saving .Renviron 


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

#query Crossref API, get email automatically from .Renviron with rcrossref
res_cr <- map(issns, getCrossrefData_progress)

rm(pb)

#extract selected variables into dataframe
res_cr_df <- map_dfr(res_cr, extractCrossrefData)


filename <- paste0("AJOL_Crossref_",date,".csv")
filepath <- file.path(path, filename)
write_csv(res_cr_df, filepath)
#res_cr_df <- read_csv(filepath)

rm(res_cr)

