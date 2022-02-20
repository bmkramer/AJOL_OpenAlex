#This script queries the OpenAlex and Crossref APIs to check for presence of AJOL journals in OpenAlex

#More information:
#AJOL: https://www.ajol.info/index.php/ajol
#OpenAlex API: https://docs.openalex.org/api
#rcrossref package: https://cran.r-project.org/web/packages/rcrossref/rcrossref.pdf 

#STEP 0 - collect ISSNs through web scraping

#load packages
library(tidyverse)
library(rvest)

source("R/query_AJOL.R")

#set date to date of sampling
date <- Sys.Date()
#date <- "2022-02-19"

#set path, create directory
path <- file.path("data",date) 
dir.create(path)

#set url for journal list on AJOL website   
url <- "https://www.ajol.info/index.php/ajol/browseBy/alpha?letter=all"

#collect urls for all AJOL journals
journal_urls <- getJournalData(url)
#n=546 journals

#set counter for progress bar
pb <- progress_estimated(length(journal_urls))

#collect title and issns for each journal url
data_raw <- map_dfr(journal_urls, getURLData_progress)
data <- extractData(data_raw)

rm(pb)

filename <- paste0("AJOL_journals_",date,".csv")
filepath <- file.path(path, filename)
write_csv(data, filepath)
#data <- read_csv(filepath)

rm(data_raw)

#Transform data into long format with unique ISSN list 

#keep selected columns, transform into long data with one issn column
data_issn <- transformISSN(data)

#NB This leaves out 13 titles with no ISSN (533 of 546 records)
# 668 journal-issn pairs,of which 666 unique issns 
# 2 journals (SAFP and SAJCN) have the same issn/eissn

filename <- paste0("AJOL_issns_",date,".csv")
filepath <- file.path(path, filename)
write_csv(data_issn, filepath)
#data_issn <- read_csv(filepath)
