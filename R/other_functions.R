#'





multi_encoder <- R6Class(
  "MultiOneHotEncoder",
  private = list(
    initial_features = NULL,
    encoded_features = NULL
  ),
  public = list(

    fit = function(list_df, exclude = NULL, thresh = 0.01) {

      encode_single_feature <- function(x, thresh) {
        unqs <- table(x) %>% sort(decreasing = T) %>% names()
        unqs <- unqs[map_lgl(unqs, ~ mean(x == .x) >= thresh)]
        if (length(unqs) > 1) head(unqs, -1) else unqs
      }

      quietly(
        map2(
          list_df,
          names(list_df),
          function(df, df_name) {
            # private$initial_features[[df_name]] <- names(df)

            unchanging_features <- unique(c(exclude, names(select_if(df, is_numeric))))
            changing_features <- names(df)[!names(df) %in% unchanging_features]

            private$encoded_features[[df_name]] <-
              map(df[changing_features], encode_single_feature, thresh)
          }
        )
      )

    },

    transform = function(list_df) {

      transform_single_feature <- function(x, values, pred) {
        map(values, ~ as.numeric(x == .x)) %>%
          set_names(str_c(pred, values, sep = "_")) %>%
          as_tibble()
      }

      map2(
        list_df,
        names(list_df),
        function(df, df_name) {
          map(
            names(df),
            function(x) {
              if (x %in% names(private$encoded_features[[df_name]])) {
                transform_single_feature(df[[x]], private$encoded_features[[df_name]][[x]], x)
              } else {
                list(df[[x]]) %>%
                  `names<-`(x) %>%
                  as_tibble()
              }
            }
          ) %>% reduce(bind_cols)
        }
      )
    }
  )
)








scaler <- R6Class(
  "Scaler",
  private = list(
    params = NULL
  ),
  public = list(
    fit = function(df) {
      private$params <- map(df, function(x) c(min = min(x), max = max(x)))
      names(private$params) <- names(df)
    },
    rescale01 = function(df) {
      scaler01 <- function(x, x_range) {
        if (length(unique(x)) == 1) {
          x
        } else {
          (x - x_range["min"]) / (x_range["max"] - x_range["min"])
        }
      }
      map2_df(df, private$params[names(df)], scaler01)
    }
  )
)


multi_scaler <- R6Class(
  "MultiScaler",
  private = list(
    params = NULL
  ),
  public = list(
    fit = function(list_df) {
      quietly(
        imap(
          list_df,
          function(df, df_id) {
            private$params[[df_id]] <-
              map(
                df,
                ~ c(quantile(.x, .01, na.rm = T), max = max(.x, .99, na.rm = T)) %>%
                  set_names(c("min", "max"))
              )
          }

        )

        # map2(
        #   list_df,
        #   names(list_df),
        #   function(df, df_name) {
        #     # private$params[[df_name]] <- map(df, function(x) c(min = min(x), max = max(x)))
        #     private$params[[df_name]] <-
        #       map(df, ~ c(min = quantile(.x, 0.01, na.rm = T), max = quantile(.x, 0.99, na.rm = T)))
        #   }
        # )
      )
    },

    rescale01 = function(list_df) {

      scaler01 <- function(x, x_range) {
        x[x > x_range["max"]] <- x_range["max"]
        x[x < x_range["min"]] <- x_range["min"]

        if (x_range[1] == x_range[2]) {
          rep(1, length(x))
        } else {
          (x - x_range["min"]) / (x_range["max"] - x_range["min"])
        }
      }

      imap(list_df, ~ map2_df(.x, private$params[[.y]], scaler01))

      # map2(
      #   list_df,
      #   names(list_df),
      #   function(df, df_name) {
      #     map2_df(df, private$params[[df_name]], scaler01)
      #   }
      # )
    }
  )
)
