#' Build a List of Expressions (Rolling Max)
#'
#' @param ... variables to make \code{roll_max}s  
#' @param .n integer vector of window sizes to calculate rolling max
#' @param .align \code{right}, \code{left} or \code{center}. Default is \code{right}
#' @param na.rm are \code{NA}s need to be removed while calculating rolling max? Default is \code{FALSE}
#'
#' @return expression to unquote inside \code{mutate()} function
#' @export 
#' 
#' @importFrom rlang exprs expr 
#' @importFrom purrr map flatten
#' @importFrom RcppRoll roll_max
#' 
#'
#' @examples
make_rollmax <- function(..., .n = 3, .align = "right", na.rm = FALSE) {
  if (!.align %in% c("right", "left", "center")) {
    stop("`.align` must be one of 'right', 'left' or 'center'")
  }
  
  if (!any(is.numeric(.n) | is.logical(.n))) {
    stop("`.n` must be a numeric vector")
  }
  
  if (any((.n %% 1) > 0)) {
    stop("`.n` must be a vector of integers. There is at least one non-integer element")
  }
  
  if (all(.n <= 1)) {
    stop("All elements in `.n` less or equal than 1. Rolling max for this kind of elements makes no sense")
  }
  
  if (any(.n <= 1)) {
    message("There is at least one element less or equal than 1. Rolling max for this kind of elements makes no sense")
  }
  
  .n <- unique(.n[.n > 1])
  
  .dots <- rlang::exprs(...)
  
  q <- purrr::map(.dots, function(.var) {
    purrr::map(.n, function(.nn) {
      rlang::expr(RcppRoll::roll_max(!!.var, !!.nn, fill = NA, align = !!.align, na.rm = !!na.rm))
    }) %>% 
      setNames(paste0(as.character(.var), "_rollmax", .n))
  }) %>% purrr::flatten() 
  q
}
