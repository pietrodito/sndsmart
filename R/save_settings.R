#'@export
save_settings <- function() {

  cli::cli_alert_info("Sauvegarde du fichier {.emph .Rprofile}")
  file.copy("~/.Rprofile", "~/.config/rstudio/Rprofile", overwrite = TRUE)

  export("~/.config/rstudio")

  dwnld_dir <- "~/sasdata1/download"

  from_file <- glue::glue("{dwnld_dir}/rstudio.csv")
  to_file <- glue::glue(
    "{dwnld_dir}/rstudio-settings-{user_details_string()}.csv")

  file.rename(from_file, to_file)
  cli::cli_alert_success("Le fichier final a été renommé {.emph {to_file}}")
}


