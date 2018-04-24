# TODO apply cor_index() only to numeric columns
# TODO make an option of arranging `Cor` (abs (default), asc, desc)

#' Get Correlation Index of DataFrame
#'
#' @param .df object of class \code{data.frame}
#'
#' @return Object of class \code{data.frame} contained correlation index. (See example below.)
#'
#' @export
#' @importFrom magrittr %>%
#' @importFrom purrr map map2_dbl
#' @importFrom dplyr filter mutate arrange desc select ungroup
#' @importFrom tibble as_tibble
#'
#' @examples
#' cor_index(mtcars) %>% head()
#' # A tibble: 55 x 3
#'    Var1  Var2     Cor
#'    <chr> <chr>  <dbl>
#'  1 cyl   disp   0.902
#'  2 disp  wt     0.888
#'  3 mpg   wt    -0.868
#'  4 cyl   mpg   -0.852
#'  5 disp  mpg   -0.848
#'  6 cyl   hp     0.832
cor_index <- function(.df) {
  if ("grouped_df" %in% class(.df)) .df <- dplyr::ungroup(.df)
  
  .df <- dplyr::select_if(.df, is.numeric)
  
  if (ncol(.df) == 0) {
    stop("Sorry, there are no any numeric variables")
  } 
  if (ncol(.df) == 1) {
    stop("There are only one numeric variable. I cannot build a correlation index with only 1 variable :(")
  } 
  
  utils::combn(names(.df), 2) %>%
    t() %>%
    tibble::as_tibble() %>%
    setNames(c("var1", "var2")) %>%
    dplyr::mutate(
      cor = purrr::map2_dbl(
        var1, var2, ~ cor(.df[[.x]], .df[[.y]], use = "pairwise.complete.obs")
      )
    ) %>%
    dplyr::arrange(dplyr::desc(abs(cor)))
}
