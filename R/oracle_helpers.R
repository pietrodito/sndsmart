#'@export
list_tables <- function(prefixe = "") {

  if( is_set_connection()) {

    fetch_result <- list_orauser_query(prefixe)

    tables <- fetch_result$TABLE_NAME

    title <- polish_title_with(prefixe)
    cli::cli_h1(title)

    proper_print_tables(tables)
  }

}

proper_print_tables <- function(tables) {
  if(length(tables) == 0) {
    cli::cli_alert_warning("Aucune table trouvée")
  } else {
    cat(tables %>% stringr::str_c(collapse = "\n"))
    cat("\n")
    cli::cli_rule()
  }
}

#'@export
drop_table <- function(prefixe = "", confirm = TRUE) {

  if( is_set_connection()) {
    fetch_result <- list_orauser_query(prefixe)
    tables <- fetch_result$TABLE_NAME
    answer <- FALSE

    if(confirm) {
      title <- polish_title_with(prefixe)
      cli::cli_h1(title)
      proper_print_tables(tables)
      if(length(tables) > 0) {
        cli::cli_alert_danger(
          "!!! ---- Voulez-vous effacer {length(tables)} table{?s} ? ---- !!!")
        answer <- askYesNo("> ", default = FALSE)
      }
    } else {
      answer <- TRUE
    }

    if(answer) {

      purrr::walk(tables, function(table) {
        tryCatch(
          dbSendQuery(the$connection, glue::glue('drop table "{table}"')),
          error = function(e)  cat(e$message)
        )
      })

      cli::cli_alert_success("{length(tables)} table{?s} effacée{?s}.")
    }
  }
}

#'@export
drop_all_orauser_tables <- function() {
  drop_table("")
}

#'@export
preview_table <- function(table_name) {

  template_path <- tempfile_path <- NULL

  copy_template_to_temp <- function() {

    template_path <<- system.file("extdata/templates/glimpse_helper.sql",
                                  package = "sndsmart")
    dir.create("~/sasdata1/sasuser/.temp_sql", showWarnings = FALSE)
    tempfile_path <<- glue::glue(
      "~/sasdata1/sasuser/.temp_sql/.tempfile{ ceiling(1e6*runif(1)) }.sql")
    system(glue::glue("cp {template_path} {tempfile_path}"))
  }

  update_table_name_in_temp_file <- function() {
    command <- glue::glue(
      "sed -i 's/<table-to-glimpse>/{table_name}/' {tempfile_path}"
      )
    system(command)
  }

  remove_temp_file <- function() system(glue::glue("rm -f {tempfile_path}"))

  copy_template_to_temp()
  update_table_name_in_temp_file()

  cli::cli_h1(
    "Requêtes nécessaires à la prévisualisation de {.emph {table_name}}")

  exec_sql_file(tempfile_path, with_title = FALSE, with_results = FALSE)
  remove_temp_file()
  line <- stringr::str_c(c(rep("_", 80), "\n"), collapse = "")
  cli::cli_rule()
  print(last_results()[[1]])
  cli::cli_rule()
  print(last_results()[[2]])
  cli::cli_rule()
  dplyr::glimpse(last_results()[[2]])
  cli::cli_rule()
}

#'@export
download_table <- function(table) {

  begin <- Sys.time()
  rs <- tryCatch(
    dbSendQuery(the$connection, glue::glue("select * from {table}")),
    error = function(e)  cat(e$message)
  )
  duration <- difftime(Sys.time(), begin)
  cli::cli_alert_info("Temps d'éxecution :", format(duration), "\n")
  f <- tibble::as_tibble(ROracle::fetch(rs))
  print(f)
  return(f)
}

is_set_connection <- function() {
  if(is.null(the$connection)) {
    cli::cli_alert_warning("Connexion ORACLE non définie.")
    cli::cli_alert_info("Tentez d'exécuter `sndsmart::connect()`...")
    FALSE
  } else {
    TRUE
  }
}

list_orauser_query <- function(prefixe) {
  fetch(dbSendQuery(the$connection, stringr::str_c("
                                 select table_name
                                 from user_tables
                                 where table_name like '", prefixe, "' || '%'
                                 order by table_name asc")))
}

polish_title_with <- function(prefixe) {
  title_detail <- ""

  if(prefixe != "") {
    title_detail <- " commençant par {prefixe}"
  }

  paste0("Liste des tables {.emph ORAUSER}", title_detail)
}
