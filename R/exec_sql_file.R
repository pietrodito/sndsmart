#'@export
exec_sql_file <- function(sql_file, with_title = TRUE, with_results = TRUE) {

  dir.create("~/sasdata1/sasuser/.sql_logs/", showWarnings = FALSE)

  log_file <- glue::glue(
    "~/sasdata1/sasuser/.sql_logs/{Sys.time()}.{basename(sql_file)}.log")
  file.create(log_file)


  log_fn <- function(text, time = FALSE) {

    if(time) {
      (
        Sys.time()
        %>% lubridate::ymd_hms()
        %>% lubridate::with_tz("Europe/Paris")
        %>% substr(12, 19)
      ) -> time
      readr::write_file("----------------------------------------",
                        log_file, append = TRUE)
      readr::write_file(glue::glue("\n\n{time}\n\n"),
                        log_file, append = TRUE)
      readr::write_file("----------------------------------------",
                        log_file, append = TRUE)
    }
    if(is.data.frame(text)) {
      sink(log_file, append = TRUE)
      print(text, width = 80)
      sink()
    } else {

      readr::write_file(glue::glue("\n\n{text}\n\n"), log_file, append = TRUE)
    }
  }

  if(is_set_connection()) {

    if(with_title) cli::cli_h1("Éxecution du fichier {.emph {sql_file}}")

    cli::cli_alert_info(
      "NB: log dans le répretoire {.emph ~/sasdata1/sasuser/.sql_logs}")

    main <- function() {

      pre_tmp_sql_file  <- stringr::str_c(sql_file, ".pre.temp" )
      post_tmp_sql_file <- stringr::str_c(sql_file, ".post.temp")

      prepend_m4_setup_and_macros(sql_file, pre_tmp_sql_file)

      apply_m4_to_file(pre_tmp_sql_file, post_tmp_sql_file)

      queries <- parse_sql_queries(post_tmp_sql_file)

      file.remove(pre_tmp_sql_file)
      file.remove(post_tmp_sql_file)

      rss <- purrr::map2(queries, names(queries), ~ treat_query(.x, .y, log_fn))
      hack_for_insertions()
      query_results <- purrr::compact(rss)

      if(with_results) {
        present_results(query_results)
      }
      invisible(query_results)
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

#'@export
launch_sql_job <- function(sql_file) {

  temp_string <- floor(runif(1)*10000000)
  temp_path <- glue::glue(".temp/tempfile.{temp_string}.R")

  job_template <- system.file("extdata/templates/launch-sql-job-script.R",
                              package = "sndsmart")

  dir.create(".temp", showWarnings = FALSE)

  system(
    glue::glue(
      "sed 's:<path-to-file>:{sql_file}:' {job_template} > {temp_path}"
    ))
  rstudioapi::jobRunScript(
    path = temp_path,
    name = sql_file,
    importEnv = TRUE,
    exportEnv = "R_GlobalEnv")
}

#_______________________________________________________________________________
#### #### exec_sql_file herlers ________________________________________________
send_query <- function(query, log_fn) {


  begin <- Sys.time()
  rs <- tryCatch(
    ROracle::dbSendQuery(the$connection, query),
    error = function(e)  cat(e$message)
  )
  duration <- difftime(Sys.time(), begin)
  cli::cli_h3("Temps d'exécution : {format(duration)}.")
  log_fn(glue::glue("Temps d'exécution : {format(duration)}."))

  if(is.null(rs)) {
    cli::cli_alert_warning("-- ÉCHEC --\n"); line();
    log_fn("-- ÉCHEC --\n")
    return()
  }
  info <- ROracle::dbGetInfo(rs)
  if(info$completed) {
    cli::cli_alert_info("-- COMPLÉTÉE --\n")
    log_fn("-- COMPLÉTÉE --\n")
    cli::cli_alert_success(
      "{underline_3_digits_group(info$rowsAffected)} ligne(s) affectée(s).")
    log_fn(
      glue::glue(
        "{underline_3_digits_group(info$rowsAffected)} ligne(s) affectée(s)."
      )
    )
    NULL
  }
  else {
    cli::cli_h3("-- VALEUR RETOURNÉE --\n")
    log_fn("-- VALEUR RETOURNÉE --\n")
    f <- tibble::as_tibble(ROracle::fetch(rs))
    print(f)
    log_fn(f)
    return(f)
  }
}

present_query <- function(title, query, log_fn) {
  cli::cli_h2(title)
  log_fn(glue::glue("\n{title}\n"), time = TRUE)
  dashed_line()
  cli::cli_code(query, language = "sql")
  log_fn(query)
  dashed_line()
}

treat_query <- function(query, title, log_fn) {
  cat("\n")
  cat("\n")
  line()
  present_query(title, query, log_fn)
  rs <- send_query(query, log_fn)
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

hack_for_insertions <- function() {

  cli::cli_h3("Hack de sécurisation des insertions")

  tryCatch(
    fetch_result <-
      fetch(
        dbSendQuery(the$connection,
          glue::glue("drop table FLUSH_INSERTION_HACK"))),
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

print_one_result <- function(result, name) {
  cli::cli_h2(name)
  print(result)
}

present_results <- function(query_results) {

  cli::cli_h1("Rësultats des requêtes")

  if (length(query_results) > 0) {
    names(query_results) <- stringr::str_c("Résultat #",
                                           seq_along(query_results))

    purrr::iwalk(query_results, print_one_result)

    cli::cli_rule()
    cli::cli_alert_success(
      "Le fichier a produit {length(query_results)} résultat{?s} côté R.")
    cli::cli_alert_info(
      "Vous pouvez acceder aux résultats avec : `sndsmart::last_results()`.")
  } else {
    cli::cli_alert_success("Pas de résultat rappatrié côté R.")
  }
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

