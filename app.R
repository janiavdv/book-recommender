library(shiny)
library(ggplot2)
library(ggvis)
library(dplyr)
source("books.R")

#### UI ####

ui = fluidPage(
  titlePanel("Book recommender"),
  fluidRow(
    column(3,
           wellPanel(
             h4("Filter"),
             sliderInput("ratings", "Minimum number of ratings on Goodreads",
                         3000, 4000000, 1000000, step = 100000), 
             sliderInput("year", "Year published", 1900, 2017, value = c(1970, 2014), sep = ""),
             checkboxInput("include_older_years", "Include years before 1900", FALSE),
             sliderInput("rating", "Minimum average rating",
                         1, 5, 2.5, step = 0.01),
             sliderInput("fivestars", "Minimum number of five-star reviews on Goodreads",
                         1000, 3100000, 100000, step = 100000),
             selectInput("genre", "Genre (most have multiple genres)",
                         c("All", "Action", "Adventure", "Animation", "Biography", "Comedy",
                           "Crime", "Documentary", "Drama", "Family", "Fantasy", "History",
                           "Horror", "Music", "Musical", "Mystery", "Romance", "Sci-Fi",
                           "Short", "Sport", "Thriller", "War", "Western") # TODO: edit list
             ),
             textInput("author", "Author name contains"),
             selectInput("language", "Language",
                         c("All", "English") # TODO: edit list
             ),
           )
    ),
    column(9,  
           ggvisOutput("plot1"),
           wellPanel(
             span("Number of books selected:",
                  textOutput("n_books")
             )
           )
    )
  )
)


#### Server ####


server = function(input, output) {
  
  # data frame containing all 10,000 books
  all_books = get_books()
  
  # Filter the books, returning a data frame
  filtered_books = reactive({
    
    # Due to dplyr issue #318, we need temp variables for input values
    minratings = input$ratings
    minrating = input$rating
    minfivestars = input$fivestars
    
    
    # Apply filters
    b = all_books %>%
      filter(
        ratings_count >= minratings,
        average_rating >= minrating,
        ratings_5 >= minfivestars
      )
    
    minyear = input$year[1]
    maxyear = input$year[2]
    
    # Get books for a specific year based on if we're including <1900
    if (input$include_older_years) {
      b = b %>% filter(
        ((original_publication_year >= minyear) & (original_publication_year <= maxyear)) |
        (original_publication_year < 1900)
      )
    } else {
      b = b %>% filter(
        original_publication_year >= minyear, 
        original_publication_year <= maxyear
      )
    }
    
    # TODO: add genre filtering
    # Optional: filter by genre
    # if (input$genre != "All") {
    #   genre = paste0("%", input$genre, "%")
    #   b = b %>% filter(Genre %like% genre)
    # } 
    
    # TODO: add author filtering
    # # Optional: filter by director
    # if (!is.null(input$director) && input$director != "") {
    #   director = paste0("%", input$director, "%")
    #   m = m %>% filter(Director %like% director)
    # }
    
    b$is_nonfiction <- character(nrow(b))
    b$is_nonfiction[b$is_nonfiction == 0] <- "Fiction"
    b$is_nonfiction[b$is_nonfiction == 1] <- "Nonfiction"
    
    as.data.frame(b)
  })
  
  book_tooltip = function(x) {
    #'@description
        #'generates the tooltip description for a book point
        #'includes the book title, authors, year published, and pages
    #'@param x the point the user is currently hovering over
    #'@return the tooltip text for a book
    
    # Find the row where X matches x$X
    row_index = which(all_books$X == x$X)
    
    # Check if a matching row was found
    if (length(row_index) > 0) {
      book = all_books[row_index, ]
      
      author = book$authors[[1]][1]
      
      book_tooltip = paste("<b>", book$title, "</b><br>",
            author, " (",
            book$original_publication_year, ")", "<br>",
            book$pages, " pages")
    
      return(book_tooltip)
    }
  }
  
  # A reactive expression with the ggvis plot
  vis = reactive({
    filtered_books %>%
      ggvis(x = ~average_rating, y = ~ratings_count) %>%
      layer_points(size := 50, size.hover := 200,
                   fillOpacity := 0.2, fillOpacity.hover := 0.5,
                   stroke = ~is_nonfiction, key := ~X) %>%
      add_tooltip(book_tooltip, "hover") %>%
      add_axis("x", title = "Average Rating (out of 5)") %>%
      add_axis("y", title = "Number of Ratings", title_offset = 70) %>%
      add_legend("stroke", title = "", values = c("Fiction", "Nonfiction")) %>%
      scale_nominal("stroke", domain = c("Fiction", "Nonfiction"),
                    range = c("pink", "darkgrey")) %>%
      set_options(width = 500, height = 500)
    # TODO: change output when no books meet criteria
  })


  vis %>% bind_shiny("plot1")
  
  output$n_books = renderText({ nrow(filtered_books()) })
}

# run app!
shinyApp(ui = ui, server = server)
