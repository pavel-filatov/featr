#' @export

MultiRenameator <- R6::R6Class(
  "MultiRenameator",
  private = list(
    names = list(),
    new_names = list(),
    encoded_features = list()
  ),

  public = list(
    fit = function(df_list, preds, exclude_vars = NULL) {
      purrr::quietly(
        purrr::map2(
          df_list,
          preds,
          function(df, pred) {
            private$names[[pred]] <- names(df)
            private$new_names[[pred]] <- names(df)
            private$new_names[[pred]][!private$names[[pred]] %in% exclude_vars] <-
              str_c(pred, seq_along(private$names[[pred]][!private$names[[pred]] %in% exclude_vars]))
          }
        )
      )
      message("All names fitted")
    },
    rename = function(df_list) {
      purrr::map2(
        df_list,
        names(df_list),
        function(df, df_name) {
          names(df) <- private$new_names[[df_name]][private$names[[df_name]] %in% names(df)]
          df
        }
      )
    }
  )
)
