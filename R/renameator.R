#' Rename all features in data frame
#'
#' R6 class for renaming dataframes
#'
#' @param df input data frame
#' @param pred string that will form new variables name,
#' e.g. "Var1" for `pred = "Var"` or "Question_5" for `pred = "Question_`
#' @param exclude_vars which variables should be exclude from renaming process?
#'
#' @return data frame with renamed features

Renameator <- R6::R6Class(
  "Renameator",
  private = list(
    names = NULL,
    new_names = NULL,
    encoded_features = NULL
  ),

  public = list(
    fit = function(df, pred = "Var", exclude_vars = NULL) {
      private$names <- names(df)
      private$new_names <- names(df)
      private$new_names[!(private$names %in% exclude_vars)] <-
        str_c(pred, seq_along(private$names[!(private$names %in% exclude_vars)]))
      # message("All names fitted")
    },
    rename = function(df) {
      new_names <- names(df)
      for (i in seq_along(df)) {
        new_names[i] <- private$new_names[which(private$names == names(df)[i])]
      }
      names(df) <- new_names
      df
    }
  )
)
