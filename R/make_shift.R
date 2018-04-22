#' Build a List of Expressions (Lags and Leads)
#'
#' This function builds an expression to make multiple lags and/or leads.
#' \bold{NOTE: For use inside \code{dplyr::mutate()} only!}
#'
#' Unquotation is needed inside the \code{mutate()} with \code{!!!} (bang-bang-bang) like this:
#' 
#' \code{mutate(mtcars, !!!make_shift(am, mpg))}
#' 
#' @param ... variables
#' @param .n integer vector with steps to shift:  
#' 
#'     - positive for \code{lag()}  
#'     
#'     - negative for \code{lead()}  
#'     
#'     - 0 automaticly excluded (so you may use colon notation \code{-2:2})  
#'
#' 
#' @return expression to unquote inside \code{mutate()} function
#' @export
#'
#' @importFrom rlang exprs expr 
#' @importFrom purrr map set_names flatten
#' @importFrom dplyr lag lead
#'
#' @examples
#' make_shift(am, mpg)
#' #> $am_lag1
#' #> dplyr::lag(am, 1)
#' #> 
#' #> $mpg_lag1
#' #> dplyr::lag(mpg, 1)
#' 
#' mutate(mtcars[c("am", "mpg")], !!!make_shift(am, mpg, .n = c(-1, 1, 2)))
#' #>    am  mpg am_lead1 am_lag1 am_lag2 mpg_lead1 mpg_lag1 mpg_lag2
#' #> 1   1 21.0        1      NA      NA      21.0       NA       NA
#' #> 2   1 21.0        1       1      NA      22.8     21.0       NA
#' #> 3   1 22.8        0       1       1      21.4     21.0     21.0
#' #> 4   0 21.4        0       1       1      18.7     22.8     21.0
#' #> 5   0 18.7        0       0       1      18.1     21.4     22.8
#' #> 6   0 18.1        0       0       0      14.3     18.7     21.4
make_shift <- function(..., .n = 1) {
  .n <- .n[.n != 0]
  
  .dots <- rlang::exprs(...)
  .funs <- ifelse(.n < 0, "_lead", "_lag")
  
  q <- purrr::map(.dots, function(.var) {
    purrr::map(.n, function(.nn) {
      if (.nn < 0) {
        rlang::expr(dplyr::lead(!!.var, !!(-.nn)))
      } else {
        rlang::expr(dplyr::lag(!!.var, !!.nn))
      }
    }) %>% 
      purrr::set_names(paste0(as.character(.var), .funs, abs(.n)))
  }) %>% purrr::flatten() 
  q
}