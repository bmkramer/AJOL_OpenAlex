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

#load data (AJOL OA journal long format with unique issns)
data <- read_csv("data/AJOL_OA_issns_202007.csv")

#NB 2 journals (SAFP and SAJCN) have the same issn/eissn

data_openalex <- read_csv("data/AJOL_OA_OpenAlex_20220131.csv")
data_cr <- read_csv("data/AJOL_OA_Crossref_20220131.csv")

# NB duplicate issn/eissn for SAFP and SAJCN 
# resolve to SAFP in both OpenAlex and Crossref 

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
  select(issn_input, in_open_alex, open_alex_count)

data_cr_join <- data_cr %>%
  select(issn_input_cr, title_cr, total_dois_cr) %>%
  rename(crossref_title = title_cr,
         crossref_count = total_dois_cr) %>%
  mutate(in_crossref = case_when(
    !is.na(crossref_title) ~ "crossref",
    TRUE ~ NA_character_)) %>%
  select(issn_input_cr, in_crossref, crossref_count)

#join dataframes
data_join <- data %>%
  left_join(data_openalex_join, by = c("issn_value" = "issn_input")) %>%
  left_join(data_cr_join, by = c("issn_value" = "issn_input_cr") )

#fill Crossref/OpenAlex info across multiple ISSN records per title
data_final <- data_join %>%
  group_by(`Journal title`) %>%
  fill(everything(), .direction = "downup") %>%
  ungroup() %>%
  select(-issn_value) %>%
  distinct() 

write_csv(data_final, "data/AJOL_OA_202007_OpenAlex_Crossref_20220131.csv")
data_final <- read_csv("data/AJOL_OA_202007_OpenAlex_Crossref_20220131.csv")
#-----------------------------------------------------

#analyze results

counts <- data_final %>%
  select(`Journal title`, in_crossref, in_open_alex) %>%
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
  
counts_compare <- data_final %>%
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
  select(`Journal title`, crossref_more, openalex_more, equal) %>%
  summarise_all(~ sum(!is.na(.)))
  
  

