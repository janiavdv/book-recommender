# load the required package
library(jsonlite)

get_books = function() {
  #### Data Cleaning ####
  books = read.csv('https://raw.githubusercontent.com/malcolmosh/goodbooks-10k/master/books_enriched.csv')
  
  # Preprocess the 'genres' column to make it valid JSON
  books$genres <- gsub("'", "\"",     books$genres)
  books$genres <- gsub("\\[\\[", "[", books$genres)
  books$genres <- gsub("\\]\\]", "]", books$genres)
  
  # Convert the 'genres' column to a list
  books$genres <- lapply(books$genres, fromJSON)
  
  # Preprocess the 'genres' column to make it valid JSON
  books$authors <- gsub(' "', ' \'', books$authors)
  books$authors <- gsub('" ', '\' ', books$authors)
  books$authors <- gsub("\\['\\[", "\\[\'", books$authors)
  books$authors <- gsub("\\]'\\]", "\'\\]", books$authors)
  
  books$authors <- gsub("\\['", "\\[\"", books$authors)
  books$authors <- gsub("'\\]", "\"\\]", books$authors)
  books$authors <- gsub("',", "\",", books$authors)
  books$authors <- gsub(", '", ", \"", books$authors)
  
  # Convert the 'genres' column to a list
  books$authors <- lapply(books$authors, fromJSON)
  
  # # Add Boolean genre columns
  # books$is_ya <- sapply(books$genres, function(genre_list) 'young-adult' %in% genre_list)
  # books$is_fiction <- sapply(books$genres, function(genre_list) 'fiction' %in% genre_list)
  
  return(books)
}


