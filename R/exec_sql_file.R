#'@export
exec_sql_file <- function(sql_file, verbose = TRUE) {

  if(is.null(the$connection)) {
    warning("No connection has been set, you need to call `sndstyle::connect()`")
    return(invisible())
  }

  if (! verbose) {
    stdout <- vector('character')
    con    <- textConnection('stdout', 'wr', local = TRUE)
    sink(con)
  }

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

  if (! verbose) {
    sink()
    close(con)
  }
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
  cat("Execution time:", format(duration), "\n")
  if(is.null(rs)) { cat("-- FAILED --\n"); line(); return() }
  info <- ROracle::dbGetInfo(rs)
  if(info$completed) {
    cat("-- COMPLETED --\n")
    underline_3_digits_group(info$rowsAffected); cat(" rows affected.\n")
  }
  else {
    cat("-- RETURNED VALUE --\n")
    f <- tibble::as_tibble(ROracle::fetch(rs))
    print(f)
    return(f)
  }
}

present_query <- function(title, query) {
  cat(title); cat("\n"); dashed_line()
  cat(query); cat("\n"); dashed_line()
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
                                   "\n/", simplify = TRUE))
            ), V1 = stringr::str_trim(V1)
          ), stringr::str_length(V1) > 0
        ), V1)
    )) -> list_needs_numbering

  names(list_needs_numbering) <-
    stringr::str_c("Query #", seq_along(list_needs_numbering), ":")
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
  macro_directory <-system.file("extdata", "macros", package = "sndstyle")
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
    names(query_results) <- stringr::str_c("Result #",
                                           seq_along(query_results))

    cat("---------------------------------------\n")
    cat("|                        _ _          |\n")
    cat("|    _ __ ___  ___ _   _| | |_ ___    |\n")
    cat("|   | '__/ _ \\/ __| | | | | __/ __|   |\n")
    cat("|   | | |  __/\\__ \\ |_| | | |_\\__ \\   |\n")
    cat("|   |_|  \\___||___/\\__,_|_|\\__|___/   |\n")
    cat("|                                     |\n")
    cat("---------------------------------------\n")
    print(query_results)
    cat("-------------------------------------\n")
    cat(stringr::str_c("The file has produced ", length(query_results), " result(s).\n"))
    cat("Access results by calling `last_results()`.")
  } else {
    cat("No result \n")
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
  nbs <- str_split(nb, "") %>% unlist
  idx <- which(trunc((seq_along(nbs) - length(nbs)) / 3) %% 2 == 1)
  nbs[idx] <- crayon::underline(nbs[idx])
  cat(stringr::str_c(nbs, collapse = ""))  }

