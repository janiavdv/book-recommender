library(shiny)
library(ggplot2)
library(ggvis)
library(dplyr)
library(stringr)
library(purrr)

library(bslib)
source("books.R")

# data frame containing all 10,000 books
all_books = get_books()

#### UI ####

ui = fluidPage(
  theme = bs_theme(version = 4, bootswatch = "minty"),
  # Application contents
  titlePanel("Book Recommender"),
  fluidRow(
    column(
      3,
      htmlOutput("goodreadslogo", align = "center", ),
      br(),
      wellPanel(
        h4("Filter"),
        sliderInput(
          "ratings",
          "Minimum number of ratings",
          3000,
          4000000,
          100000,
          step = 100000
        ),
        sliderInput(
          "year",
          "Year published (original)",
          1900,
          2017,
          value = c(1970, 2014),
          sep = ""
        ),
        checkboxInput("include_older_years", "Include years before 1900", FALSE),
        sliderInput("rating", "Minimum average rating",
                    1, 5, 2.5, step = 0.01),
        sliderInput(
          "fivestars",
          "Minimum number of five-star ratings",
          1000,
          3100000,
          100000,
          step = 100000
        ),
        selectInput(
          "genre",
          "Genre (most have multiple genres)",
          c("All", str_to_title(unique(
            unlist(all_books$genres)
          )))
        ),
        textInput("author", "Author name contains")
      ),
    ),
    
    column(
      9,
      p(
        "Welcome to the Book Recommender! This interactive tool is designed
to help you discover your next favorite read. Start by adjusting the
filters on the left to refine your search criteria. The main panel
will dynamically update to show all books that match your preferences.
Hover over the points in the plot to view brief details about each book.
Feeling adventurous? Click on 'Find me a book!' to get a random recommendation
based on your current filter settings. Happy reading!"
      ),
      ggvisOutput("plot1"),
      wellPanel(htmlOutput("n_books")),
      br(),
      wellPanel(
        actionButton("randombook", "Find me a book!"),
        br(),
        br(),
        fluidRow(
          column(
            3,
            
            htmlOutput("randombook_cover"),
            htmlOutput("randombook_title"),
            htmlOutput("randombook_author"),
            htmlOutput("randombook_pages"),
            htmlOutput("randombook_avgrate"),
            htmlOutput("randombook_ratings")
          ),
          column(9,
                 htmlOutput("randombook_descr"))
        )
      )
    )
  )
)



#### Server ####

server = function(input, output) {
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
      b = b %>% filter(((original_publication_year >= minyear) &
                          (original_publication_year <= maxyear)
      ) |
        (original_publication_year < 1900))
    } else {
      b = b %>% filter(original_publication_year >= minyear,
                       original_publication_year <= maxyear)
    }
    
    # Optional: filter by genre (drop down)
    if (input$genre != "All") {
      g = str_to_lower(input$genre)
      b = b %>% filter(map_lgl(genres, ~ g %in% .))
    }
    
    # Optional: filter by author name (text input)
    if (!is.null(input$author) & input$author != "") {
      author = tolower(input$author)
      b = b %>%
        # sub-string search for author
        filter(map_lgl(authors, ~ str_to_lower(.x[1]) %>% str_detect(author)))
    }
    
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
      book = all_books[row_index,]
      
      author = book$authors[[1]][1]
      
      book_tooltip = paste(
        "<b>",
        book$title,
        "</b><br>",
        author,
        " (",
        book$original_publication_year,
        ")",
        "<br>",
        book$pages,
        " pages"
      )
      
      return(book_tooltip)
    }
  }
  
  # A reactive expression with the ggvis plot
  vis = reactive({
    filtered_books() %>%
      ggvis(x = ~ average_rating, y = ~ ratings_count) %>%
      layer_points(
        size := 100,
        size.hover := 250,
        fill := "deeppink",
        fillOpacity := 0.5,
        fillOpacity.hover := 0.8,
        stroke := "white",
        strokeWidth := 2,
        key := ~ X
      ) %>%
      add_tooltip(book_tooltip, "hover") %>%
      add_axis("x", title = "Average Rating (out of 5)") %>%
      add_axis("y", title = "Number of Ratings", title_offset = 70) %>%
      set_options(width = 900, height = 600)
  })
  
  
  vis %>% bind_shiny("plot1")
  
  output$goodreadslogo = renderText({
    paste(
      '<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Goodreads_logo.svg/2560px-Goodreads_logo.svg.png"
                width="300"
                height="65">'
    )
  })
  
  output$n_books = renderText({
    paste("Number of books selected: ", nrow(filtered_books()))
  })
  
  # Reactive context for selecting a random book
  random_row = eventReactive(input$randombook, {
    # Check if there are any books after filtering
    if (nrow(filtered_books()) < 1) {
      return(NULL)
    }
    sample(1:nrow(filtered_books()), 1)
  })
  
  # Render outputs related to the random book
  output$randombook_title = renderText({
    if (is.null(random_row()))
      return(NULL)
    paste("<b>", filtered_books()[random_row(),]$title , "</b>")
  })
  
  output$randombook_author = renderText({
    if (is.null(random_row()))
      return(NULL)
    filtered_books()[random_row(),]$authors[[1]][1]
  })
  
  output$randombook_cover = renderText({
    if (is.null(random_row()))
      return(NULL)
    paste('<img src="', filtered_books()[random_row(),]$image_url, '">')
  })
  
  output$randombook_pages = renderText({
    if (is.null(random_row()))
      return(NULL)
    paste("Number of pages: ", filtered_books()[random_row(),]$pages)
  })
  
  output$randombook_descr = renderText({
    if (is.null(random_row()))
      return(NULL)
    filtered_books()[random_row(),]$description
  })
  
  output$randombook_ratings = renderText({
    if (is.null(random_row()))
      return(NULL)
    paste("Number of ratings: ", filtered_books()[random_row(),]$ratings_count)
  })
  
  output$randombook_avgrate = renderText({
    if (is.null(random_row()))
      return(NULL)
    paste("Average rating: ", filtered_books()[random_row(),]$average_rating)
  })
}

shinyApp(ui = ui, server = server)