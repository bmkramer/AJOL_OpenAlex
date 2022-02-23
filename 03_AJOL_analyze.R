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
date <- "2022-02-19"

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
  select(-c(publisher, created_date)) %>%
  rename(open_alex_title = display_name,
         open_alex_count = works_count,
         open_alex_venue_id = id,
         open_alex_match_issn = match_issn,
         open_alex_match_issn_l = match_issn_l) %>%
  mutate(in_open_alex = case_when(
    !is.na(open_alex_title) ~ "open_alex",
    TRUE ~ NA_character_)) %>%
  mutate(open_alex_count = case_when(
    open_alex_count == 0 ~ NA_real_,
    TRUE ~ open_alex_count)) %>%
  select(issn_input, in_open_alex, open_alex_venue_id,
         open_alex_match_issn, open_alex_match_issn_l,
         open_alex_count)

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
#548 instead of 533 records
#15 titles linked to multiple OpenAlex venue IDs, either with the same or different works count

#Decide to *only keep highest count* (but could also decide to add counts for both issns)
#For titles with equal count, keep lowest (earliest?) venueID
#TODO check overlap of records for these title variants in OpenAlex

#data_final_corrected <- data_final %>%
data_final_corrected <- data_final %>%
  group_by(journal) %>%
  arrange(desc(open_alex_count), open_alex_venue_id) %>%
  slice(1) %>%
  ungroup()

rm(data_join, data_final)
  
filename <- paste0("AJOL_OpenAlex_Crossref_",date,".csv")
filepath <- file.path(path, filename)
write_csv(data_final_corrected, filepath)
#data_final_corrected <- read_csv(filepath)

#-----------------------------------------------------

#analyze results
#TODO Create function for counts and counts_openalex

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
  

counts_open_alex <- data_final_corrected %>%
  select(journal, in_open_alex, 
         open_alex_match_issn, open_alex_match_issn_l) %>%
  mutate(open_alex_issn_only = case_when(
    !is.na(open_alex_match_issn) & is.na(open_alex_match_issn_l) ~ "open_alex_issn_only",
    TRUE ~ NA_character_),
    open_alex_issn_l_only = case_when(
      is.na(open_alex_match_issn) & !is.na(open_alex_match_issn_l) ~ "open_alex_issn_l_only",
      TRUE ~ NA_character_),
    both = case_when(
      !is.na(open_alex_match_issn) & !is.na(open_alex_match_issn_l) ~ "both",
      TRUE ~ NA_character_),
    none = case_when(
      is.na(open_alex_match_issn) & is.na(open_alex_match_issn_l) ~ "none",
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
  

