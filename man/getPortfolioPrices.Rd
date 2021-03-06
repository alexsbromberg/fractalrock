\name{getPortfolioPrices}
\alias{getPortfolioPrices}
\alias{getTradingDates}
\title{ Generate portfolio prices using the fractal process }
\description{
  This function will construct a portfolio of asset returns based on the time
  range specified or the number of 'observations' requested. The resulting time
  series will be based on the specified calendar, as defined by getTradingDates
  that uses the timeDate package under the hood.
}
\usage{
getPortfolioPrices(symbols, obs = NULL, end = Sys.Date(), start = NULL, calendar = holidayNYSE, seeds = NULL, patterns = NULL, ..., type = "uniform")

getTradingDates(end, start = NULL, obs = NULL, calendar = holidayNYSE)
}
\arguments{
  \item{symbols}{ The names of the assets to generate prices for. This determines the total number of time series generated. }
  \item{end}{ The last date in the time series }
  \item{start}{ The starting date of the time series. All non-business days are removed in the resulting range. Either start or obs must be set. }
  \item{obs}{ The total number of points to generate. The dates will follow a business day calendar as defined by timeDate, defaulting to NYSE. Either start or obs must be set. }
  \item{calendar}{ The business day calendar to use. Defaults to NYSE. }
  \item{seeds}{ A list of initiators to use for generating the time series }
  \item{patterns}{ A list of generators to use for generating the time series }
  \item{\dots}{ Additional arguments to send to the fractal generator }
  \item{type}{ The type of fractal process to use. Defaults to uniform. }
}
\details{
  The main entry point is getPortfolioPrices, which generates a TxM xts object 
  based on the symbols provided. Prices generated by this function can be used
  in risk modeling, as a substitute for brownian motion in Monte Carlo
  simulations, and backtesting applications. Studying fractal generation of
  time series can be accomplished more directly by calling 
  \code{\link{fractal}}.

  In addition to the arguments above, it is necessary to pass the appropriate
  arguments to the the underlying fractal call. This includes passing in a seed
  and generator patterns. If none are provided predefined sets will be used,
  although users of this package are encouraged to create their own initiators
  and generators.

  The getTradingDates function is a utility to generate proper business days for
  a given calendar. This is used to be compatible with other applications that
  load actual asset data.
}
\value{
  An xts object with either obs rows or points in the range [start,end] and
  a time series for each symbol provided.
}
\author{ Brian Lee Yung Rowe }
\note{
  In the future, it may be possible to generate time series with an explicit
  R/S value or Hurst exponent.
}
\examples{
  data(generators)
  ps <- portfolio_prices('IBM', '2009-02-24',obs=10,
    seeds=sampleInitiators, patterns=sampleGenerators)

  trading_dates('2009-02-26', obs=10)
}
\keyword{ ts }
\keyword{ math }
