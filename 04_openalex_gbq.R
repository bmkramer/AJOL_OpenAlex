#This script queries OpenAlex through Google Big Query instance (COKI) to check for presence of AJOL journals in OpenAlex
#Limitation: a subset of AJOL journals is checked: all OA journals listed in AJOL in July 2020
#This list was created for use in crowdsourced list of diamond journals (see link below).

#More information:
#AJOL: https://www.ajol.info/index.php/ajol
#Crowdsourced list of diamond journals:  https://tinyurl.com/diamond-journals
#OpenAlex API: https://docs.openalex.org/api
#COKI: https://openknowledge.community/

#load packages
library(tidyverse)

#load data (AJOL OA journal long format with unique issns)
data_final <- read_csv("data/AJOL_OA_202007_OpenAlex_Crossref_20220131.csv")

#load data from GBQ queries
#GBQ scripts in folder sql/
data_gbq_openalex <- read_csv("data/GBQ/gbq_ajol_openalex_20220130.csv")
data_gbq_cr <- read_csv("data/GBQ/gbq_ajol_crossref_20211207.csv")

#NB 2 journals (SAFP and SAJCN) have the same issn/eissn


#fill Crossref/OpenAlex info across multiple ISSN records per title
data_gbq_openalex_final <- data_gbq_openalex %>%
  group_by(Journal_title) %>%
  fill(everything(), .direction = "downup") %>%
  ungroup() %>%
  select(-issn_value) %>%
  distinct() 


#for crossref, counts can differ between ISSN/eISSN (whut)
data_gbq_cr_intermediate <- data_gbq_cr %>%
  mutate(cr_count_dois_issn = case_when(
          issn_value == ISSN ~ cr_count_dois,
          TRUE ~ NA_real_),
         cr_count_dois_eissn = case_when(
           issn_value == eISSN ~ cr_count_dois,
           TRUE ~ NA_real_))
  
data_gbq_cr_final <- data_gbq_cr_intermediate %>%  
  group_by(Journal_title) %>%
  fill(everything(), .direction = "downup") %>%
  ungroup() %>%
  select(-c(issn_value, cr_issn, cr_count_dois)) %>%
  distinct() 

#NB 2 journals (SAFP and SAJCN) have the same issn/eissn

#-----------------------------------------------------

#analyze results

counts <- data_final %>%
  summarise_all(~ sum(!is.na(.)))

counts_cr_gbq <- data_gbq_cr_final %>%
  mutate(in_crossref = case_when(
    (!is.na(cr_count_dois_issn) | !is.na(cr_count_dois_eissn)) ~ "in_crossref_gbq",
    TRUE ~ NA_character_)) %>%
  summarise_all(~ sum(!is.na(.)))
# n=230 - same as Crossref API. 

counts_openalex_gbq <- data_gbq_openalex_final %>%
  summarise_all(~ sum(!is.na(.)))
# n=73 - less than OpenAlex API that checks all issns, rather than issn_l only 
  
#-----------------------------------------------  
#Compare GBQ Crossref counts with direct API query

gbq_cr_counts <- data_gbq_cr_final %>%
  select(Journal_title, cr_count_dois_issn, cr_count_dois_eissn) %>%
  #THIS DOES NOT WORK PROPERLY YET
  mutate(cr_count_max = case_when(
    (!is.na(cr_count_dois_eissn) | is.na(cr_count_dois_issn)) ~ cr_count_dois_eissn,
    (is.na(cr_count_dois_eissn) | !is.na(cr_count_dois_issn)) ~ cr_count_dois_issn,
    (cr_count_dois_eissn > cr_count_dois_issn) ~ cr_count_dois_eissn,
    (cr_count_dois_eissn < cr_count_dois_issn) ~ cr_count_dois_issn,
    (cr_count_dois_eissn == cr_count_dois_issn) ~ cr_count_dois_issn,
    TRUE ~ NA_real_))

data_counts <- data_final %>%
  left_join(gbq_cr_counts, by = c("Journal title" = "Journal_title"))

write_csv(data_counts, "data/counticount.csv")    



