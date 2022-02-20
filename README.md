# Coverage of AJOL journals in OpenAlex and Crossref

This repository contains code and data querying the OpenAlex and Crossref APIs to check for presence of [African Journals Online (AJOL)](https://www.ajol.info/index.php/ajol) journals in OpenAlex and Crossref by ISSN. For OpenAlex, both the ISSN and ISSN-L field were queried.

The current check was done on February 19, 2022.

ISSNs were retrieved for **533 of 546 journals** from the AJOL website.
Of these, **467 journals were found in Crossref**, and **488 in OpenAlex**. 

All titles with ISSNs in Crossref were also found by ISSN in OpenAlex, with one exception ([Caliphate Journal of Science and Technology](https://www.ajol.info/index.php/cajost)). Twenty-two (22) journals not using Crossref DOIs were found by ISSN in OpenAlex. All of these only had an ISSN-L identifier in OpenAlex, with null values in the ISSN field. 

Of the 466 titles present in Crossref and OpenAlex, OpenAlex has more records than Crossref for **247 titles**, while Crossref has more records for **105 titles**. This could be due to not all articles from a journal having DOIs (e.g. when a journal only started assigning DOIs from a certain year onwards) and incomplete detection by OpenAlex, respectively, but warrants further checks.

Scripts:  
[00_AJOL_journals.R](00_AJOL_journals.R)  
[01_AJOL_OpenAlex.R](01_AJOL_OpenAlex.R)  
[02_AJOL_Crossref.R](02_AJOL_Crossref.R)  
[03_AJOL_analyze.R](03_AJOL_analyze.R)

Resulting dataset:  
[AJOL_OpenAlex_Crossref_2022-02-19.csv](data/2022-02-19/AJOL_OpenAlex_Crossref_2022-02-19.csv)


Limitations / next steps:  

- Two journals ([South African Family Practice](https://www.ajol.info/index.php/safp) (SAFP) and [South African Journal of Clinical Nutrition](https://www.ajol.info/index.php/sajcn) (SAJCN) have the same ISSN/eISSN. Both ISSNs resolve to SAFP in OpenAlex and Crossref. Currently, this is not corrected in the dataset, which therefore contains duplicate data for SAFP and SAJCN. 

- A small number of ISSNs retrieved from the AJOL website (4 out of 667 unique ISSNs) were found to contain typos/errors (e.g. additional or missing digits). No API results were returned for these ISSNs.

- No additional information was collected on e.g. type of publication or publication year to investigate differences in record count in OpenAlex and Crossref for journals included in both. 

- It was not checked whether OpenAlex includes additional AJOL journal titles when searched not by ISSN, but e.g. by journal name.

- OpenAlex is actively improving the quality of its coverage. OpenAlex metadata (included in [AJOL_OpenAlex_2022-02-19.csv](data/2022-02-19/AJOL_OpenAlex_2022-02-19.csv)) show that 237 of the 488 AJOL journals found in OpenAlex have been added as 'Venues' on February 3, 2022.
