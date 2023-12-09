# load the required package
library(jsonlite)

get_books = function() {
  #'@description
    #'outputs the clean book data frame
  #'@return a dataframe with 10,000 rows of book data
  
  books = read.csv('https://raw.githubusercontent.com/malcolmosh/goodbooks-10k/master/books_enriched.csv')
  
  # Preprocess the 'genres' column to make it valid JSON
  books$genres = gsub("'", "\"",     books$genres)
  books$genres = gsub("\\[\\[", "[", books$genres)
  books$genres = gsub("\\]\\]", "]", books$genres)
  # Convert the 'genres' column to a list
  books$genres = lapply(books$genres, fromJSON)
  
  # Preprocess the 'authors' column to make it valid JSON
  books$authors = gsub(' "', ' \'', books$authors)
  books$authors = gsub('" ', '\' ', books$authors)
  books$authors = gsub("\\['\\[", "\\[\'", books$authors)
  books$authors = gsub("\\]'\\]", "\'\\]", books$authors)
  books$authors = gsub("\\['", "\\[\"", books$authors)
  books$authors = gsub("'\\]", "\"\\]", books$authors)
  books$authors = gsub("',", "\",", books$authors)
  books$authors = gsub(", '", ", \"", books$authors)
  # Convert the 'authors' column to a list
  books$authors = lapply(books$authors, fromJSON)
  
  # # Add Boolean genre columns
  all_books$is_nonfiction = sapply(all_books$genres, function(genres) 'nonfiction' %in% genres)
  
  return(books)
}