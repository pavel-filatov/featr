#' Extract Seasonality
#'
#' @return data frame with decomposed time series
#' @export
extract_seasonality <- function(...) {
  UseMethod("extract_seasonality")
}


extract_seasonality.default <- function(.x) {
  stop(paste("Don't know how to apply `extract_seasonality()` to object of class", class(.x)[1]))
}


#' Extract Seasonality from Vector
#'
#' Extract seasonality from numeric vector
#' 
#' @param .x numeric vector
#' @param .freq frequency for time series
#' @param .method method/methods to extract seasonality; could be "stl" (default), "additive", "multiplicative"
#' @param .part parts of decomposition to keep: "seasonal" (default), "trend", "remainder"
#'
#' @return data frame with \code{.part} parts of \code{.method} decompositions
#'
#' @examples 
#' x <- rep(c(1:6, 6:1), 10)
#' seasonalities <- extract_seasonality(x, .freq = 12, .method = c("stl", "additive"))
#' head(seasonalities)
#' #>   stl_seasonal additive_seasonal
#' #>          <dbl>             <dbl>
#' #> 1       -2.5              -2.50 
#' #> 2       -1.5              -1.5  
#' #> 3       -0.5              -0.5  
#' #> 4        0.500             0.500
#' #> 5        1.50              1.50 
#' #> 6        2.50              2.5 
extract_seasonality.numeric <- function(.x,
                                        .freq = 12,
                                        .method = "stl",
                                        .part = "seasonal") {
  
  if (length(.method) == 0) {
    stop("`.method` must contain at least one element: 'stl', 'additive', or 'multiplicative'")
  }
  
  if (length(.part) == 0) {
    stop("`.part` must contain at least one element: 'seasonal', 'trend', or 'remainder'")
  }
  
  .method <- sapply(.method, match.arg, c("stl", "additive", "multiplicative"))
  .part <- sapply(.part, match.arg, c("seasonal", "trend", "remainder"))
  
  .ts <- ts(.x, frequency = .freq)

  process_ts <- function(.ts_data, .ts_method, .ts_parts) {
    
    if (.ts_method == "stl") {
      .ts_decomposed <- stl(.ts_data, s.window = "periodic")$time.series
    }
    if (.ts_method %in% c("additive", "multiplicative")) {
      .ts_decomposed <- stats::decompose(.ts_data, .ts_method)[2:4]
    }
    
    as_tibble(.ts_decomposed) %>% 
      setNames(paste(.ts_method, c("seasonal", "trend", "remainder"), sep = "_")) %>% 
      dplyr::select(!!paste(.ts_method, .ts_parts, sep = "_"))
  }
  
  purrr::map(.method, ~ process_ts(.ts, .x, .part)) %>%
    dplyr::bind_cols()
}



extract_seasonality.data.frame <- function(.df, 
                                           ..., 
                                           .freq = 12, 
                                           .method = "stl", 
                                           .part = "seasonal") {
  .vars <- rlang::enquos(...)
  .vars_names <- purrr::map(.vars, rlang::quo_name)
  
  .seasonal_df <- 
    .vars %>% 
      purrr::set_names(.vars_names) %>% 
      purrr::imap(
        ~ dplyr::pull(.df, !!.x) %>% 
          extract_seasonality(.freq = .freq, .method = .method, .part = .part) %>% 
          dplyr::rename_all(function(..name) paste(.y, ..name, sep = "_"))
      ) %>% 
      dplyr::bind_cols()
  
  dplyr::bind_cols(.df, .seasonal_df)
}
