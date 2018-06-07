#' Make Interactions Over Selected Variables With Given Function
#'
#' For now the problem with naming new columns exists.
#' It will be solving in the future.
#' But the main functionality seems to work well.
#' If you stuck with a bug please create a new issue here 
#' \url{https://github.com/pavel-filatov/featr/issues}.
#'
#' @param .df data frame
#' @param .f function
#' @param ... variables to interact, symbols and tidyselect functions allowed
#'
#' @return
#' @export
#' @importFrom rlang sym quo UQ
#' @importFrom purrr cross2 map
#' @importFrom tidyselect vars_select
#' @importFrom magrittr "%>%"
#' 
#'
#' @examples
#' mtcars %>% 
#'   select(am, cyl, mpg) %>% 
#'   mutate(
#'     !!!make_interactions(., "-", 1, 2),
#'     !!!make_interactions(., "+", am, cyl),
#'     !!!make_interactions(., "/", everything())
#'   )
#' 
make_interactions <- function(.df, .f, ...) {
  if (is.character(.f)) .f <- rlang::sym(.f)
  
  .vars <- tidyselect::vars_select(names(.df), ...)
  # f <- expr(!!.f)
  purrr::cross2(.vars, .vars, .filter = `==`) %>% 
    purrr::map(
      ~ rlang::quo(rlang::UQ(.f)(!!rlang::sym(.x[[1]]), !!rlang::sym(.x[[2]])))
    )
}

