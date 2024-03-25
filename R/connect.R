#'@export
connect <- function()  {
  library(ROracle)
  cli::cli_alert_info("Connexion à ORACLE...\n")
  drv <- DBI::dbDriver("Oracle")
  the$connection <- ROracle::dbConnect(drv, dbname = "IPIAMPR2.WORLD")
  cli::cli_alert_success("Vous êtes connecté !\n")
  invisible(the$connection)
}

#'@export
current_connection <- function() {
  the$connection
}
