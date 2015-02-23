# :vim set ft=R

DAILY <- 60 * 24


#' Simulate intraday prices
#'
#' Note that trading hours are based on GMT, so be sure that your timezone
#' is specified as GMT.
#' Sys.setenv(TZ='GMT')
#'
#' @examples
#' th <- function(x) trading_hours(x,'cme')
#' myou <- function(x) ou(x, 40, 3/24, 45, .03/1440)
#' x <- rintraday(myou, obs=60)

#' mygbm <- function(x) gbm(x, 40, .03/1440)
#' y <- rintraday(mygbm, start='2014-01-01', end='2014-06-30', hours.fn=th)
rintraday(process, start, ohlc, volume, ...) %::% Function:.:logical:logical:...:xts
rintraday(process, start=Sys.Date(), ohlc=FALSE, volume=FALSE, ...) %as% {
  dates <- trading_dates(start=start, ...)
  n <- length(dates)
  prices <- as.xts(process(n), order.by=dates)
  #rownames(prices) <- format(dates)
  colnames(prices) <- 'close'

  if (ohlc) prices <- .add_ohlc(prices, ohlc)
  if (volume) prices <- .add_volume(prices, volume)
  prices
}


#' Create correlated intraday prices
#'
#' @examples
#' th <- function(x) trading_hours(x,'cme')
#' mygbm <- function(x) gbm(x, 40, .03/1440)
#' seed <- rintraday(mygbm, obs=60, th)
#' cmat <- matrix(c(1,0,0, .8,1,0, .6,.4,1), ncol=3)
#' z <- rintraday(seed, cmat)
rintraday(series, rho) %::% xts : matrix : xts
rintraday(series, rho) %as% {
  if (all(rho[lower.tri(rho)] == 0))
    rho[lower.tri(rho)] <- rho[upper.tri(rho)]

  cd <- chol(nearPD(rho)$mat)
  u <- mean(series)
  s <- sd(series)
  num.cols <- ncol(rho) - 1
  r <- cbind((series - u)/s, 
    matrix(rnorm(nrow(series) * num.cols), ncol=num.cols))
  rc <- r %*% cd
  out <- as.xts(u + rc * s, order.by=index(series))
  colnames(out) <- colnames(rho)
  out
}

#' Create correlated intraday OHLC bars with optional volume.
#'
#' @examples
#' th <- function(x) trading_hours(x,'cme')
#' mygbm <- function(x) gbm(x, 40, .03/1440)
#' seed <- rintraday(mygbm, obs=60, th)
#' cmat <- matrix(c(1,0,0, .8,1,0, .6,.4,1), ncol=3)
#' z <- rintraday(seed, cmat, ohlc=1, volume=100)
rintraday(series, rho, ohlc, volume) %::% xts : matrix : . : . : list
rintraday(series, rho, ohlc=FALSE, volume=FALSE) %as% {
  prices <- rintraday(series, rho)
  colnames(prices) <- rep('close',ncol(prices))
  out <- lapply(1:ncol(prices), function(x) prices[,x])

  if (ohlc) out <- lapply(out, function(x) .add_ohlc(x, ohlc))
  if (volume) out <- lapply(out, function(x) .add_volume(x, volume))
  out
}



.add_ohlc <- function(series, sd) {
  n <- nrow(series)
  open <- as.numeric(series$close[1]) + rnorm(1) # This is totally a kludge
  series$open <- c(open,series$close[1:(n-1)])
  series$low <- pmin(series$open,series$close) - abs(rnorm(n, sd=sd))
  series$high <- pmax(series$open,series$close) + abs(rnorm(n, sd=sd))
  series
}

.add_volume <- function(series, mean, sd=mean/4) {
  n <- nrow(series)
  series$volume <- as.integer(abs(rnorm(n, mean=mean, sd=sd)))
  series
}




#' Compatible with POSIXct
#' @param period In minutes
#' @return Vector of seconds used to offset a date
intraday_ticks <- function(period, hours) {
  if (all(is.na(hours))) return(numeric())

  open <- as.numeric(hours$open * 60)
  close <- as.numeric(hours$close * 60)
  if (close < open) close <- close + 24 * 60
  seq(open,close, by=period) * 60
}




holidays(ds,exchange) %::% Date: character: Date
holidays(ds,'cbt') %as% as.Date(holidayNYSE(unique(year(ds))))
holidays(ds,'cme') %as% as.Date(holidayNYSE(unique(year(ds))))
holidays(ds,'eux') %as% as.Date(holidayNYSE(unique(year(ds))))
holidays(ds,'nyse') %as% as.Date(holidayNYSE(unique(year(ds))))
holidays(ds,'nasdaq') %as% as.Date(holidayNYSE(unique(year(ds))))

# Ignore short trading days for now
trading_hours(ds,exchange) %::% timeDate: character: xts
trading_hours(ds,exchange) %as% trading_hours(as.Date(ds), exchange)

trading_hours(ds,exchange) %::% Date: character: xts
trading_hours(ds,'cbt') %as% trading_hours(ds,c(23,22.25), holidays(ds,'cbt'))
trading_hours(ds,'cme') %as% trading_hours(ds,c(23,22.25), holidays(ds,'cme'))
trading_hours(ds,'eux') %as% trading_hours(ds,c(6.833,21), holidays(ds,'eux'))
trading_hours(ds,'nyse') %as% trading_hours(ds,c(14.5,21), holidays(ds,'nyse'))
trading_hours(ds,'nsdq') %as% trading_hours(ds,c(14.5,21), holidays(ds,'nsdq'))

trading_hours(dates, hours, holidays) %::% Date: numeric: Date: xts
trading_hours(dates, hours, holidays) %as% {
  fn <- function(d) {
    if (d %in% holidays) c(NA,NA)
    else hours
  }
  o <- t(sapply(dates, fn))
  o <- xts(o, order.by=dates)
  colnames(o) <- c('open','close')
  o
}