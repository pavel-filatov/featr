#' Calculate the index of sameness for variables in the data frame
#'
#' @param .df data frame
#' @param .na_include if TRUE, \code{NA == NA} will return \code{TRUE}. 
#' Otherwise all observations with at least one \code{NA} will go to \code{other} column. 
#' Default if \code{FALSE}
#'
#' @return data frame with identity index.
#'   \code{identical} and \code{non_identical} columns contatin number of observations where
#'   \code{Var1 == Var2} and \code{Var1 != Var2} respectively.
#'   \code{other} column contains number of observations with neither \code{Var1 == Var2} nor \code{Var1 != Var2} 
#' conditions, i.e. \code{NaN}s, \code{NULL}s etc.
#' 
#' @export
#' @importFrom dplyr ungroup mutate arrange desc
#' @importFrom purrr map2_int
#' @importFrom tibble as_tibble
#' @importFrom magrittr "%>%"
#'
#' @examples
#' identity_index(mtcars)
identity_index <- function(.df, .na_include = FALSE) {
  if (!"data.frame" %in% class(.df)) {
    stop("`.df` must be a data frame")
  }
  
  if (!is.logical(.na_include)) {
    stop("`.na_include` must be a TRUE/FALSE condition")
  }
  
  if ("grouped_df" %in% class(.df)) .df <- dplyr::ungroup(.df)
  
  if (ncol(.df) == 0) {
    stop("Sorry, there are no any variables")
  } 
  if (ncol(.df) == 1) {
    stop("There are only one column in data frame. I cannot build an index with only 1 variable :(")
  }
  
  .temp <- utils::combn(names(.df), 2) %>%
    t() %>%
    tibble::as_tibble() %>%
    setNames(c("Var1", "Var2"))
  
  if (.na_include) {
    .temp <- .temp %>% 
      dplyr::mutate(
        identical = purrr::map2_int(
          Var1, Var2,
          ~ sum(.df[[.x]] == .df[[.y]] | is.na(.df[[.x]]) & is.na(.df[[.y]]), na.rm = TRUE)
        ),
        non_identical = purrr::map2_int(
          Var1, Var2,
          ~ sum(.df[[.x]] != .df[[.y]] | xor(is.na(.df[[.x]]), is.na(.df[[.y]])), na.rm = TRUE)
        )
      )
  } else {
    .temp <- .temp %>% 
      dplyr::mutate(
        identical = purrr::map2_int(
          Var1, Var2,
          ~ sum(.df[[.x]] == .df[[.y]], na.rm = TRUE)
        ),
        non_identical = purrr::map2_int(
          Var1, Var2,
          ~ sum(.df[[.x]] != .df[[.y]], na.rm = TRUE)
        )
      )
  }
  
  .temp %>% 
    dplyr::mutate(
      other = nrow(.df) - identical - non_identical,
      identity_index = ifelse(identical + non_identical > 0, identical / (identical + non_identical), 0)
    ) %>% 
    dplyr::arrange(dplyr::desc(identity_index))
}
