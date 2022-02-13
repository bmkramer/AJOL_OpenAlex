#This script queries the OpenAlex and Crossref APIs to check for presence of AJOL journals in OpenAlex

#More information:
#AJOL: https://www.ajol.info/index.php/ajol
#OpenAlex API: https://docs.openalex.org/api
#rcrossref package: https://cran.r-project.org/web/packages/rcrossref/rcrossref.pdf 

#STEP 3 - analyze results

#load packages
library(tidyverse)

#set date to date of sampling
#date <- Sys.Date()
date <- "2022-02-13"

#set path
path <- file.path("data",date) 


#load data (AJOL journals in long format with unique issns)
filename <- paste0("AJOL_issns_",date,".csv")
filepath <- file.path(path, filename)
data <- read_csv(filepath)
#532 of 545 AJOL journals have issns, 667 issns of which 665 unique
#NB 2 journals (SAFP and SAJCN) have the same issn/eissn

filename <- paste0("AJOL_OpenAlex_",date,".csv")
filepath <- file.path(path, filename)
data_openalex <- read_csv(filepath)

filename <- paste0("AJOL_Crossref_",date,".csv")
filepath <- file.path(path, filename)
data_cr <- read_csv(filepath)
# NB duplicate issn/eissn for SAFP and SAJCN resolve to SAFP in both OpenAlex and Crossref 

#----------------------------------------------------

#join OpenAlex and Crossref results to original data

#prepare dataframes
data_openalex_join <- data_openalex %>%
  select(issn_input, display_name, works_count) %>%
  rename(open_alex_title = display_name,
         open_alex_count = works_count) %>%
  mutate(in_open_alex = case_when(
    !is.na(open_alex_title) ~ "open_alex",
    TRUE ~ NA_character_)) %>%
  mutate(open_alex_count = case_when(
    open_alex_count == 0 ~ NA_real_,
    TRUE ~ open_alex_count)) %>%
  select(issn_input, in_open_alex, open_alex_count)

data_cr_join <- data_cr %>%
  select(issn_input_cr, title_cr, total_dois_cr) %>%
  rename(crossref_title = title_cr,
         crossref_count = total_dois_cr) %>%
  mutate(in_crossref = case_when(
    !is.na(crossref_title) ~ "crossref",
    TRUE ~ NA_character_)) %>%
  mutate(crossref_count = case_when(
    crossref_count == 0 ~ NA_real_,
    TRUE ~ crossref_count)) %>%
  select(issn_input_cr, in_crossref, crossref_count)

rm(data_cr, data_openalex)

#join dataframes
data_join <- data %>%
  left_join(data_openalex_join, by = c("issn_value" = "issn_input")) %>%
  left_join(data_cr_join, by = c("issn_value" = "issn_input_cr"))

rm(data_cr_join, data_openalex_join)

#fill Crossref/OpenAlex info across multiple ISSN records per title
data_final <- data_join %>%
  group_by(journal) %>%
  fill(everything(), .direction = "downup") %>%
  ungroup() %>%
  select(-issn_value) %>%
  distinct() 
#535 instead of 532 records

#3 journals have duplicate records (= different results for both issns)
#all have different results for OpenAlex (results for Crossref are either identical or filled out)
#all 3 have different title (title variants) and issn_l for both issns in OpenAlex

#Decide to *only keep highest count* (but could also decide to add counts for both issns)
#TODO check overlap of records for these title variants in OpenAlex

data_final_corrected <- data_final %>%
  group_by(journal) %>%
  arrange(desc(open_alex_count)) %>%
  slice(1) %>%
  ungroup()

rm(data_final)
  
filename <- paste0("AJOL_OpenAlex_Crossref_",date,".csv")
filepath <- file.path(path, filename)
write_csv(data_final_corrected, filepath)
#data_final_corrected <- read_csv(filepath)

#-----------------------------------------------------

#analyze results

counts <- data_final_corrected %>%
  select(journal, in_crossref, in_open_alex) %>%
  mutate(crossref_only = case_when(
            !is.na(in_crossref) & is.na(in_open_alex) ~ "crossref_only",
            TRUE ~ NA_character_),
         open_alex_only = case_when(
            is.na(in_crossref) & !is.na(in_open_alex) ~ "openalex_only",
           TRUE ~ NA_character_),
         both = case_when(
           !is.na(in_crossref) & !is.na(in_open_alex) ~ "both",
           TRUE ~ NA_character_),
         none = case_when(
           is.na(in_crossref) & is.na(in_open_alex) ~ "none",
           TRUE ~ NA_character_)) %>%
  summarise_all(~ sum(!is.na(.)))
  
#compare counts for journals in both crossref and openalex
counts_compare <- data_final_corrected %>%
  filter(!is.na(in_crossref) & !is.na(in_open_alex))  %>%
  mutate(
    crossref_more = case_when(
      crossref_count > open_alex_count ~ "crossref_more",
      TRUE ~ NA_character_),
    openalex_more = case_when(
      crossref_count < open_alex_count ~ "open_alex_more",
      TRUE ~ NA_character_),
    equal = case_when(
      crossref_count == open_alex_count ~ "equal",
      TRUE ~ NA_character_)) %>%
  select(journal, crossref_more, openalex_more, equal) %>%
  summarise_all(~ sum(!is.na(.)))
  

