library(tidyverse)
library(rlang)

make_interactions <- function(.df, .f, ...) {
  if (is.character(.f)) .f <- as.symbol(.f)
  
  .vars <- tidyselect::vars_select(names(.df), ...)
  f <- expr(!!.f)
  purrr::cross2(.vars, .vars, .filter = `==`) %>% 
    map(~ quo((!!f)(!!sym(.x[[1]]), !!sym(.x[[2]]))))
}



mutate(mtcars[1:2], !!!make_interactions(mtcars[1:2], function(x, y) lag(x, 1) * lead(y, 1), everything()))
make_interactions(mtcars, "-", am, cyl, mpg)
