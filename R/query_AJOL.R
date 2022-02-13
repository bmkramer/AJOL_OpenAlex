#function to get journal urls from AJOL website
#result is character vector, can use tibble() to convert into dataframe
getJournalData <- function(url){
  
  res <- read_html(url) %>%
    html_nodes(xpath="//a[contains(text(), 'View Journal')]") %>%
    html_attr("href")
}  


#function to get journal title and ISSNs from journal URL
getURLData <- function(url){
  
  Sys.sleep(1)
  
  url_about <- paste0(url, "/about")
  url_html <- read_html(url_about) 
  
  data_title <- url_html %>%
    html_nodes("title") %>%
    html_text() %>%
    #keep only Journal title
    str_squish() %>%
    str_remove("About the Journal") %>%
    str_remove("\\|") %>%
    str_squish()
  
  data_issns <- url_html %>%
    html_nodes("div.section") %>%
    html_text() %>%
    str_split("\n", simplify = TRUE) %>%
    map(str_squish)
  
  res <- tibble(journal = data_title,
                url = str_remove(url, "/about"),
                issns = data_issns)
  
}

#function to add progress bar
getURLData_progress <- function(x){
  pb$tick()$print()
  res <- getURLData(x)
  
  return(res)
}

#function to extract ISSN(s)
extractData <- function(df){
  df <- df %>%
    filter(issns != "Journal Identifiers") %>%
    distinct() %>%
    #split issn strings into columns
    separate(issns, 
             c("issn_type", "issn_value"), 
             sep = ":", 
             fill = "right") %>%
    #rename issn_type 
    mutate(issn_type = case_when(
      issn_type == "print ISSN" ~ "ISSN",
      issn_type == "eISSN" ~ "eISSN", 
      TRUE ~ "none")) %>%
    #replace empty values with NA
    mutate(issn_value = case_when(
      issn_value == "" ~ NA_character_,
      TRUE ~ issn_value)) %>%
    #transform into wide format
    pivot_wider(names_from = "issn_type", values_from = "issn_value") %>%
    #keep and order relevant columns 
    select(journal, url, ISSN, eISSN)
}


#define function to transform journal list with ISSNs into long format
transformISSN <- function(df){
  df <- df %>%
    mutate(ISSN2 = ISSN,
           eISSN2 = eISSN) %>%
    pivot_longer(cols = ends_with("ISSN2"),
                 names_to = "issn_type",
                 values_to = "issn_value",
                 values_drop_na = TRUE) %>%
    select(-issn_type) %>%
    distinct()
  
}