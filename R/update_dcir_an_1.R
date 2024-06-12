update_dcir_an_1 <- function() {


  if(is_set_connection()) {

    cli::cli_h1(
      stringr::str_c(
        "Mise à jour de la variable DCIR_AN_1 : ",
        "{.emph Avant quelle date les tables sont-elles archivées par année ?}"))

    construct_query <- function(year) {
      cli::cli_alert_info(
        glue::glue("

                Est-ce que la table ", glue::glue("ER_PRS_F_{year} existe ? ")
        ))

      glue::glue("select distinct 1 as ONE from ER_PRS_F_{year} where rownum <= 1")
    }

    is_query_correct <- function(query) {
      rs <- tryCatch(
        ROracle::dbSendQuery(the$connection, query),
        error = function(e)  cat(e$message)
      )
      (! purrr::is_null(rs))
    }

    year_table_exists <- function(year) {
      answer <- is_query_correct(construct_query(year))
      if(answer) cli::cli_alert_info("Elle existe.")
      answer
    }

    cli::cli_h2(
      "Vérfication que votre accès SNDS n'est pas {.emph restreint à 10 ans}")
    cli::cli_h3(
      "On vérifie que la synonyme ER_PRS_F_2012 est valide...")
    if(! is_query_correct("
                      select distinct 1 as ONE
                      from ER_PRS_F_2012
                      where rownum <= 1
                      ")) {
      cli::cli_alert_danger("Votre accès semble reistreint à 10 ans")
    } else {


      cli::cli_alert_success("Accès non restreint, êtes-vous un chercheur ?")

      cli::cli_h2(
        "Première année pour laquelle il n'existe pas de table archivée ?")
      year <- 2013
      while(year_table_exists(year)) year <- year + 1

      pattern <- "\\(define(\\[DCIR_AN1\\], \\[\\)[[:digit:]]\\+"
      pattern <- "\\(define(\\[DCIR_AN1], \\[\\)[[:digit:]]\\+"
      replacement <- glue::glue("\\1{year}0101")
      sed_operation <- glue::glue("sed -i 's|{pattern}|{replacement}|'")
      target_file <- system.file("extdata/macros/dcir_an_1.m4",
                                 package = "sndsmart")
      command <- glue::glue("{sed_operation} {target_file}")
      system(command)
      cli::cli_alert_success(glue::glue(
        "La variable DCIR_AN_1 a maintenant la valeur {year}0101",
        " pour votre installation locale du package."))
      cli::cli_alert_warning("Pensez à la mettre à jour l'année prochaine...")
    }
  }
}
