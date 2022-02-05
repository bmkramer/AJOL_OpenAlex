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


  
#load data
data_source <- read_csv("data/AJOL_OA_list_202007.csv")

#keep selected columns, transform into long data with one issn column
data <- data_source %>%
  select(`Journal title`, `Journal URL`, ISSN, eISSN) %>%
  mutate(ISSN2 = ISSN,
         eISSN2 = eISSN) %>%
  pivot_longer(cols = ends_with("ISSN2"),
               names_to = "issn_type",
               values_to = "issn_value",
               values_drop_na = TRUE) %>%
  select(-issn_type) %>%
  distinct()

#NB This leaves out 5 titles with no ISSN (259 of 264 records)
# 352 journal-issn pairs,of which 350 unique issns 
# 2 journals (SAFP and SAJCN) have the same issn/eissn
 
write_csv(data, "data/AJOL_OA_issns_202007.csv")
data <- read_csv("data/AJOL_OA_issns_202007.csv")
