#' Separate Data Frame With Any Variable
#'
#' Turn data frame into the list of data frames by unique entries of any variable
#'
#' @param .data data frame
#' @param .var variable to separate by
#'
#' @return
#' @export
#' @importFrom purrr map set_names
#' @importFrom dplyr filter
#' @importFrom magrittr "%>%"
#' @importFrom rlang enquo quo_name
#'
#'
#' @examples
#' separate_with(mtcars, cyl)
separate_with <- function(.data, .var) {
  .var <- rlang::enquo(.var)
  .var_name <- rlang::quo_name(.var)
  .var_entries <- unique(.data[[.var_name]])
  purrr::map(.var_entries, ~ dplyr::filter(.data, !!.var == .x)) %>%
    purrr::set_names(paste(.var_name, .var_entries, sep = "_"))
}
