#' @export
`%+=%` <- function(lhs, rhs) {
  assign(deparse(match.call()[[2]]), eval(lhs) + rhs, envir = parent.env(environment()))
}

#' @export
`%*=%` <- function(lhs, rhs) {
  assign(deparse(match.call()[[2]]), eval(lhs) * rhs, envir = parent.env(environment()))
}
