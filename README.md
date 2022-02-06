# Coverage of AJOL journals in OpenAlex and Crossref

This repository contains code and data querying the OpenAlex and Crossref APIs to check for presence of [African Journals Online (AJOL)](https://www.ajol.info/index.php/ajol) journals in OpenAlex and Crossref by ISSN.

Only a subset of AJOL journals is checked: **all OA journals listed in AJOL in July 2020** - this [list](https://docs.google.com/spreadsheets/d/1yBZvjTFj4y-2tNiDHaNaCqD0ilJnXCV5/edit#gid=1878417458) was created for use in our [crowdsourced list of diamond journals](https://tinyurl.com/diamond-journals).

In total 259 journals with ISSNs were checked on Jan 30, 2021. 
Of these, **230 were found in Crossref**, and **143 in OpenAlex**. All titles retrieved from OpenAlex were also present in Crossref. 

Of the 143 titles present in Crossref and OpenAlex, **OpenAlex has more records than Crossref for 128 titles**.

Scripts:  
[00_AJOL_issns.R](00_AJOL_issns.R)  
[01_query_OpenAlex.R](01_query_OpenAlex.R)  
[02_query_Crossref.R](02_query_Crossref.R)  
[03_analyze.R](03_analyze.R)

Resulting dataset:  
[data/AJOL_OA_202007_OpenAlex_Crossref_20220130.csv](data/AJOL_OA_202007_OpenAlex_Crossref_20220130.csv)


Limitations:  

- Only a subset OA journals from AJOL is currently checked, because a journal list with ISSNs was already available for that subset. The analysis could be extended to the full AJOL journal list after collecting all ISSNs from the AJOL website. 

- Two journals ([South African Family Practice](https://www.ajol.info/index.php/safp) (SAFP) and [South African Journal of Clinical Nutrition](https://www.ajol.info/index.php/sajcn) (SAJCN) have the same ISSN/eISSN. Both ISSNs resolve to SAFP in OpenAlex and Crossref. Currently, this is not corrected in the dataset, which therefore contains duplicate data for SAFP and SAJCN. 

- No additional information was collected on e.g. type of publication or year of publication to investigate the higher record count in OpenAlex than Crossref for most journals included in both. 

- It was not checked whether OpenAlex includes additional AJOL journal titles from the subset when searched not by ISSN, but e.g. by journal name.


