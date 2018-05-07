#' @export
replace_na_with <- function(.x, .with = "mean") {
  .x[is.na(.x)] <- mean(.x, na.rm = TRUE)
  .x
}