#' Sum Over Selected Vars
#'
#' Function builds an expression to sum over selected variables.
#' You can select variables with tidyverse way.
#'
#' @param .df data frame
#' @param ... variables to sum
#'
#' @return
#' @export
#' @importFrom tidyselect vars_select
#' @importFrom rlang quo quos as_quosure caller_env eval_tidy
#' @importFrom purrr map reduce
#'
#' @examples
#' # Sum all vars from `mpg` to `carb` except `cyl` to `am`
#' mutate(mtcars, ss = sum_over(mtcars, mpg:carb, -(cyl:am)))
sum_over <- function(.df, ...) {
  .vars <- tidyselect::vars_select(names(.df), ...)
  .vars_symbols <- purrr::map(.vars, as.symbol)
  .vars_quoted <- purrr::map(.vars_symbols, rlang::as_quosure, env = rlang::caller_env())
  .expr <- purrr::reduce(.vars_quoted, ~ rlang::quo(!!.x + !!.y))
  rlang::eval_tidy(.expr)
}


