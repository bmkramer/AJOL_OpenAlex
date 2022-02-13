# Coverage of AJOL journals in OpenAlex and Crossref

This repository contains code and data querying the OpenAlex and Crossref APIs to check for presence of [African Journals Online (AJOL)](https://www.ajol.info/index.php/ajol) journals in OpenAlex and Crossref by ISSN.

The current check was done on February 13, 2022.

ISSNs were retrieved for **532 of 545 journals** from the AJOL website.
Of these, **466 journals were found in Crossref**, and **464 in OpenAlex**. All titles retrieved from OpenAlex were also present in Crossref. 

The two AJOL journals in Crossref, but not found by ISSN in OpenAlex are [Caliphate Journal of Science and Technology](https://www.ajol.info/index.php/cajost) and [South Sudan Medical Journal](https://www.ajol.info/index.php/ssmj).

Of the 464 titles present in Crossref and OpenAlex, OpenAlex has more records than Crossref for **243 titles**, while Crossref has more records for **105 titles**.

Scripts:  
[00_AJOL_journals.R](00_AJOL_issns.R)  
[01_AJOL_OpenAlex.R](01_AJOL_OpenAlex.R)  
[02_AJOL_Crossref.R](02_AJOL_Crossref.R)  
[03_AJOL_analyze.R](03_AJOL_analyze.R)

Resulting dataset:  
[AJOL_OpenAlex_Crossref_2022-02-13.csv](data/2022-02-13/AJOL_OpenAlex_Crossref_2022-02-13.csv)


Limitations / next steps:

- Two journals ([South African Family Practice](https://www.ajol.info/index.php/safp) (SAFP) and [South African Journal of Clinical Nutrition](https://www.ajol.info/index.php/sajcn) (SAJCN) have the same ISSN/eISSN. Both ISSNs resolve to SAFP in OpenAlex and Crossref. Currently, this is not corrected in the dataset, which therefore contains duplicate data for SAFP and SAJCN. 

- A small number of ISSNs retrieved from the AJOL website (4 out of 665 unique ISSNs) were found to contained typos/errors (e.g. additional or missing digits). No API results were returned for these ISSNs.

- No additional information was collected on e.g. type of publication or publication year to investigate differences in record count in OpenAlex and Crossref for journals included in both. 

- It was not checked whether OpenAlex includes additional AJOL journal titles when searched not by ISSN, but e.g. by journal name.
