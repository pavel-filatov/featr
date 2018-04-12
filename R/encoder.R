#' R6 Class For One-Hot-Encoding
#'
#' @docType class
#' @importFrom R6 R6Class
#' @importFrom purrr map reduce set_names
#' @importFrom tibble as_tibble
#' @importFrom magrittr "%>%"
#' @export
#' @return An object of \code{\link{R6Class}}
#' @format An \code{\link{R6Class}} generator object
#' TODO add examples
#' @examples

encoder <- R6::R6Class(
  "OneHotEncoder",
  private = list(
    initial_features = NULL,
    encoded_features = NULL,
    features_wo_changing = NULL,
    features_to_change = NULL
  ),
  public = list(

    fit = function(df, exclude = NULL) {
      private$initial_features <- names(df)

      private$features_wo_changing <- unique(c(exclude, names(select_if(df, is_numeric))))
      private$features_to_change <- names(df)[!(names(df) %in% private$features_wo_changing)]

      df_wo_changing <- df[private$features_wo_changing]
      df_to_encoding <- df[private$features_to_change]

      private$encoded_features <-
        map(
          df_to_encoding,
          function(x) {
            nms <- table(x) %>% sort(decreasing = T) %>% names()
            ifelse(length(nms) > 1, head(nms, -1), nms)
          }
        )
      names(private$encoded_features) <- private$features_to_change
    },

    transform = function(df) {

      encode_feature <- function(.ftr, .values, .pred) {
        map(.values, function(value) as.numeric(.ftr == value)) %>%
          set_names(str_c(.pred, .values, sep = "_")) %>%
          as_tibble()
      }

      map(
        names(df),
        function(.ftr) {
          if (.ftr %in% private$features_to_change) {
            encode_feature(df[[.ftr]], private$encoded_features[[.ftr]], .ftr)
          } else {
            list(df[[.ftr]]) %>%
              set_names(.ftr) %>%
              as_tibble()
          }
        }
      ) %>% bind_cols()
    }
  )
)
