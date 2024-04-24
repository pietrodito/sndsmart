#'@export
connect <- function()  {


  library(ROracle)
  cli::cli_h1("Connexion au serveur {.emph ORACLE}")
  cli::cli_alert_info("Synchronisation des fuseaux horaires R / Oracle")
  Sys.setenv(TZ='UTC')
  Sys.setenv(ORA_SDTZ='UTC')
  cli::cli_alert_info("Tentative de connexion...")
  cli::cli_alert_warning("Cela peut prendre une quinzaine de secondes.")
  drv <- DBI::dbDriver("Oracle")
  the$connection <- ROracle::dbConnect(drv, dbname = "IPIAMPR2.WORLD")
  cli::cli_alert_success("Vous êtes connecté !")
  invisible(the$connection)
}

#'@export
current_connection <- function() {
  the$connection
}
