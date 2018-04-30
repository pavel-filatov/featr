#' @export
replace_na_with <- function(.x, .fun = mean) {
  .x[is.na(.x)] <- .fun(.x, na.rm = TRUE)
  .x
}