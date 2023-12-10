# Book Recommender

## Application Link



## Dataset

The data for this application is sourced from the ["Goodbooks 10k Extended" GitHub repository](https://github.com/malcolmosh/goodbooks-10k-extended/tree/master), using the 'books.csv' file. This file contains 10,000 records of book data from Goodreads, as of September 2017. The dataset includes various columns, such as:

- `X`: Index of the book within the dataset, ranging from 1 to 10,000.
- `authors`: List of authors of the book.
- `average_rating`: The average user star rating out of five.
- `description`: Synopsis of the book.
- `genres`: Categories or genres the book belongs to.
- `image_url`: URL of the book cover image.
- `original_publication_year`: The year when the book was first published.
- `pages`: Total number of pages in the book.
- `ratings_5`: Number of five-star ratings the book received on Goodreads.
- `ratings_count`: Total number of Goodreads users who rated the book.

## Project Overview

The Book Recommender is an interactive web application designed to assist users in discovering books based on their preferences. Developed using the Shiny package in R(Studio), it offers a user-friendly interface to filter and select books from a comprehensive dataset of 10,000 titles from Goodreads.

Key features of the application include:

- **Dynamic Filtering**: Users can set preferences for minimum ratings, publication year, average rating, number of five-star reviews, genre, and author name.
- **Interactive Visualization**: The app presents a visual representation of books based on user-selected criteria, using ggvis plots.
- **Random Book Selection**: An exciting feature where the app suggests a random book based on the current filter settings.
- **Detailed Book Information**: Upon selection, the app displays detailed information about the book, including its cover, title, author, number of pages, average rating, total ratings, and a brief description.

The application aims to provide an engaging way for users to explore books, encouraging reading by making book discovery fun and personalized. The project's depth comes from its comprehensive data manipulation and interactive visualizations, offering users a unique and engaging way to explore and discover books.


## References

This project was inspired by and utilizes methodologies similar to those in [the Shiny Movie Explorer example](https://github.com/rstudio/shiny-examples/tree/main/051-movie-explorer). 