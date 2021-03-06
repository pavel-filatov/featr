% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract_seasonality.R
\name{extract_seasonality.numeric}
\alias{extract_seasonality.numeric}
\title{Extract Seasonality from Vector}
\usage{
\method{extract_seasonality}{numeric}(.x, .freq = 12, .method = "stl",
  .part = "seasonal")
}
\arguments{
\item{.x}{numeric vector}

\item{.freq}{frequency for time series}

\item{.method}{method/methods to extract seasonality; could be "stl" (default), "additive", "multiplicative"}

\item{.part}{parts of decomposition to keep: "seasonal" (default), "trend", "remainder"}
}
\value{
data frame with \code{.part} parts of \code{.method} decompositions
}
\description{
Extract seasonality from numeric vector
}
\examples{
x <- rep(c(1:6, 6:1), 10)
seasonalities <- extract_seasonality(x, .freq = 12, .method = c("stl", "additive"))
head(seasonalities)
#>   stl_seasonal additive_seasonal
#>          <dbl>             <dbl>
#> 1       -2.5              -2.50 
#> 2       -1.5              -1.5  
#> 3       -0.5              -0.5  
#> 4        0.500             0.500
#> 5        1.50              1.50 
#> 6        2.50              2.5 
}
