#' Sum Over Selected Vars
#'
#' Function builds an expression to sum over selected variables.
#' You can select variables with tidyverse way.
#'
#' @param .data data frame
#' @param ... variables to sum
#'
#' @return
#' @export
#' @importFrom tidyselect vars_select
#' @importFrom rlang quo quos as_quosures caller_env eval_tidy
#' @importFrom purrr map reduce
#'
#' @examples
#' # Sum all vars from `mpg` to `carb` except `cyl` to `am`
#' mutate(mtcars, ss = sum_over(mtcars, mpg:carb, -(cyl:am)))
sum_over <- function(.data, ...) {
  .vars <- tidyselect::vars_select(names(.data), !!!rlang::quos(...))
  .vars_quoted <- rlang::as_quosures(purrr::map(.vars, as.symbol), env = rlang::caller_env())
  .expr <- purrr::reduce(.vars_quoted, ~ rlang::quo(!!.x + !!.y))
  rlang::eval_tidy(.expr)
}


