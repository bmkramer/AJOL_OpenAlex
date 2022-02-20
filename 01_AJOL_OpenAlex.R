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
date <- "2022-02-19"
#set path
path <- file.path("data",date) 


#load data (AJOL journals in long format with unique issns)
filename <- paste0("AJOL_issns_",date,".csv")
filepath <- file.path(path, filename)
data <- read_csv(filepath)
#668 issns

#pull issns into character vector
issns <- data %>%
  pull(issn_value) %>%
  unique()
#666 unique issns


# query OpenAlex API bfor ISSNs and ISSN_L 
# and extract selected variables into dataframe
# set email from .Renviron variable
# TODO use map to run functions iteratively for both issn and issn_l

# query ISSNs field
pb <- progress_estimated(length(issns))
res_issn <- map(issns, ~getOpenAlexData_progress(.,
                                                 issn_parameter = "issn",
                                                 var_email = email))
res_issn_df <- map_dfr(res_issn, extractOpenAlexData) %>%
  mutate(match_issn = case_when(
    !is.na(id) ~ "issn",
    TRUE ~ NA_character_))
rm(pb)

# query ISSN_L field
pb <- progress_estimated(length(issns))
res_issnl <- map(issns, ~getOpenAlexData_progress(.,
                                                 issn_parameter = "issn_l",
                                                 var_email = email))
res_issnl_df <- map_dfr(res_issnl, extractOpenAlexData) %>%
  mutate(match_issn_l = case_when(
    !is.na(id) ~ "issn_l",
    TRUE ~ NA_character_))
rm(pb)

rm(res_issn, res_issnl)

# write to csv
filename <- paste0("AJOL_OpenAlex_issn_",date,".csv")
filepath <- file.path(path, filename)
write_csv(res_issn_df, filepath)
#res_issn_df <- read_csv(filepath)

filename <- paste0("AJOL_OpenAlex_issnl_",date,".csv")
filepath <- file.path(path, filename)
write_csv(res_issnl_df, filepath)
#res_issnl_df <- read_csv(filepath)

#combine both datasets
res_df <- bind_rows(res_issn_df,
                    res_issnl_df)

rm(res_issn_df, res_issnl_df)

#fill out columns to  deduplicate matches
res_df <- res_df %>%
  group_by(issn_input, id) %>% 
  fill(everything(), .direction = "downup") %>%
  ungroup() %>%
  distinct()

#remove empty (non-matched) records where a match also exists
res_df <-res_df %>%
  add_count(issn_input) %>%
  ungroup() %>%
  #marks rows to be deleted
  mutate(remove = case_when(
    (is.na(id) & n > 1) ~ "remove",
    TRUE ~ NA_character_)) %>%
  filter(is.na(remove)) %>%
  select(-c(n, remove))
    
#667 records, 1 duplicate issn_input (0300-1652, Nigerian Medical Journal)
#matched to two venue IDs

#write to csv
filename <- paste0("AJOL_OpenAlex_",date,".csv")
filepath <- file.path(path, filename)
write_csv(res_df, filepath)
#res_df <- read_csv(filepath)

