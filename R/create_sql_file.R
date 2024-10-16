create_sql_file <- function(filename) {

  short_filepath <- glue::glue("./sql/{filename}.sql")
  filepath <- glue::glue("{getwd()}/{short_filepath}")

  if (file.exists(filepath)) {
    cli::cli_alert_warning("Le fichier existe déjà.")
  } else {
    isPro <- getOption("sndsmart_pro")
    template_path <- if(!is.null(isPro) && isPro) {
      "extdata/pro_templates/" } else { "extdata/templates/" }
    file.copy(
      system.file(template_path, "template.sql", package = "sndsmart"),
      filepath)
    cli::cli_alert_info(glue::glue("Fichier {short_filepath} créé."))
    update_sql_orchestration_file(short_filepath)
    file.edit(filepath)
  }
}

update_sql_orchestration_file <- function(short_filepath) {
    rstudioapi::documentSave()
    text_to_insert <-  glue::glue(
      "if(sys.nframe() == 0) file.edit(\"{short_filepath}\") \n",
      "if(sys.nframe() == 0) show_sql_after_macro(\"{short_filepath}\") \n",
      "if(sys.nframe() == 0) launch_sql_job(\"{short_filepath}\") \n",
      "exec_sql_file(\"{short_filepath}\")\n\n",
      "if(sys.nframe() == 0) create_sql_file(\"99-yyyyyyyyyy\")" )
    line_to_replace <-
      system(glue::glue(
        "grep -n create_sql_file ./R/01-sql-orchestration.R ",
        "  | cut -d ':' -f 1 ",
        "  | head -n 1"
      ), intern = T) %>% as.numeric()
    rstudioapi::insertText(
      location = rstudioapi::document_range(
        rstudioapi::document_position(line_to_replace, 1),
        rstudioapi::document_position(line_to_replace + 1, 1)),
      text_to_insert)
    rstudioapi::documentSave()
}
