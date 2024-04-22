#'@export
exec_sql_file <- function(sql_file, with_title = TRUE) {

  if(is_set_connection()) {

    if(with_title) cli::cli_h1("Éxecution du fichier {.emph {sql_file}}")

    main <- function() {

      pre_tmp_sql_file  <- stringr::str_c(sql_file, ".pre.temp" )
      post_tmp_sql_file <- stringr::str_c(sql_file, ".post.temp")

      prepend_m4_setup_and_macros(sql_file, pre_tmp_sql_file)

      apply_m4_to_file(pre_tmp_sql_file, post_tmp_sql_file)

      queries <- parse_sql_queries(post_tmp_sql_file)

      file.remove(pre_tmp_sql_file)
      file.remove(post_tmp_sql_file)

      rss <- purrr::map2(queries, names(queries), ~ treat_query(.x, .y))
      secure_flush_for_insertions()
      query_results <- purrr::compact(rss)

      present_results(query_results)
    }

    the$last_results <- main()

  }
}

#'@export
show_sql_after_macro <- function(sql_file) {

  cli::cli_h1("Application des macros au fichier {.emph {sql_file}}")

  pre_tmp_sql_file  <- stringr::str_c(sql_file, ".pre.temp" )
  post_tmp_sql_file <- stringr::str_c(sql_file, ".post.temp")

  prepend_m4_setup_and_macros(sql_file, pre_tmp_sql_file)

  apply_m4_to_file(pre_tmp_sql_file, post_tmp_sql_file)
  file.remove(pre_tmp_sql_file)

  queries <- parse_sql_queries(post_tmp_sql_file)
  file.remove(post_tmp_sql_file)

  purrr::walk2(queries, names(queries), function(q, n) {
    cli::cli_h2(n)
    cli::cli_code(q, language = "sql")
  })
}

#'@export
last_results <- function() {
  the$last_results
}

#_______________________________________________________________________________
#### #### exec_sql_file herlers ________________________________________________
send_query <- function(query) {
  begin <- Sys.time()
  rs <- tryCatch(
    ROracle::dbSendQuery(the$connection, query),
    error = function(e)  cat(e$message)
  )
  duration <- difftime(Sys.time(), begin)
  cli::cli_h3("Temps d'exécution : {format(duration)}.")
  if(is.null(rs)) {
    cli::cli_alert_warning("-- ÉCHEC --\n"); line(); return()
  }
  info <- ROracle::dbGetInfo(rs)
  if(info$completed) {
    cli::cli_alert_info("-- COMPLÉTÉE --\n")
    cli::cli_alert_success(
      "{underline_3_digits_group(info$rowsAffected)} ligne(s) affectée(s).")
    NULL
  }
  else {
    cli::cli_h3("-- VALEUR RETOURNÉE --\n")
    f <- tibble::as_tibble(ROracle::fetch(rs))
    print(f)
    return(f)
  }
}

present_query <- function(title, query) {
  cli::cli_h2(title)
  dashed_line()
  cli::cli_code(query, language = "sql")
  dashed_line()
}

treat_query <- function(query, title) {
  cat("\n")
  cat("\n")
  line()
  present_query(title, query)
  rs <- send_query(query)
  line()
  return(rs)
}

parse_sql_queries <- function(sql_file) {

  suppressWarnings(
    as.list(
      dplyr::pull(
        dplyr::filter(
          dplyr::mutate(
            tibble::as_tibble(
              t(
                stringr::str_split(readr::read_file(sql_file),
                                   "\n/\n", simplify = TRUE))
            ), V1 = stringr::str_trim(V1)
          ), stringr::str_length(V1) > 0
        ), V1)
    )) -> list_needs_numbering

  names(list_needs_numbering) <-
    stringr::str_c("Requête #", seq_along(list_needs_numbering), ":")
  list_needs_numbering
}

secure_flush_for_insertions <- function() {

  tryCatch(
    fetch_result <- fetch(dbSendQuery(oracle_connection, stringr::str_c("
                                    drop table FLUSH_INSERTIONS"))),
    error = function(e) return()
  )
}

prepend_m4_setup_and_macros <- function(sql_file, pre_tmp_sql_file) {

  m4_setup <- "changequote(\\`[\\', \\`]\\')"
  macro_directory <-system.file("extdata", "macros", package = "sndsmart")
  macro_files <- list.files(macro_directory, pattern = "*.m4")
  macro_paths <- paste0(macro_directory, "/", macro_files)
  include_strings <- paste0("include(", macro_paths, ")", collapse = " \\n")

  m4_intro <- paste0(m4_setup, "\\n", include_strings)

  command <- stringr::str_c(
    'sed "1s;^;', m4_intro, '\\n;" ', sql_file, " > ", pre_tmp_sql_file)
  system(command)
}

apply_m4_to_file <- function(pre_tmp_sql_file, post_tmp_sql_file) {
  system(stringr::str_c("m4 ", pre_tmp_sql_file, " > ", post_tmp_sql_file))
}

present_results <- function(query_results) {

  if (length(query_results) > 0) {
    names(query_results) <- stringr::str_c("Résultat #",
                                           seq_along(query_results))

    cli::cli_h1("Liste des résultats")
    print(query_results)
    cat("-------------------------------------\n")
    cli::cli_alert_success(
      "Le fichier a produit {length(query_results)} résultat{?s} côté R.")
    cli::cli_alert_info(
      "Vous pouvez acceder aux résultats avec : `sndsmart::last_results()`.")
  } else {
    cli::cli_alert_success("Pas de résultat rappatrié côté R.")
  }
  invisible(query_results)
}

#_______________________________________________________________________________
#### #### Cosmetic helpers _____________________________________________________
line_of_char <- function(char, length = 81) {
  cat(stringr::str_c(
    stringr::str_c(rep(char, length), collapse = ""), "\n")) }

line <- function() line_of_char("_")

dashed_line <- function() line_of_char("-")

underline_3_digits_group <- function(nb) {
  nbs <- stringr::str_split(nb, "") %>% unlist
  idx <- which(trunc((seq_along(nbs) - length(nbs)) / 3) %% 2 == 1)
  nbs[idx] <- crayon::underline(nbs[idx])
  stringr::str_c(nbs, collapse = "")
}

