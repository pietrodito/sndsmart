#'@export
connect <- function()  {
  library(ROracle)
  cat("Connecting to ORACLE...\n")
  drv <- DBI::dbDriver("Oracle")
  the$connection <- ROracle::dbConnect(drv, dbname = "IPIAMPR2.WORLD")
  cat("Connected!\n")
  invisible(the$connection)
}

#'@export
current_connection <- function() {
  the$connection
}
