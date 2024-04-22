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
