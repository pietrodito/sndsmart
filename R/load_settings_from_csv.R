#'@export
load_settings_from_csv <- function(filepath) {
  cli::cli_h1("Chargement des paramètres RStudio {.emph {filepath}}")
  import_from_csv(filepath,
                            dest_path = "~/.config/",
                            project_name = "rstudio",
                            open_project = FALSE,
                            verbose = FALSE)
  cli::cli_alert_info("Restitution du fichier {.emph .Rprofile}")
  file.copy("~/.config/rstudio/Rprofile", "~/.Rprofile", overwrite = TRUE)
  cli::cli_alert_info(paste(
    "Vous devez redémarrer complètement RStudio",
    "pour que vos nouveaux paramètres s'appliquent.")
  )
}
