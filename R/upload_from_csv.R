upload_from_csv <- function(csv_file, table_name, csv2 = FALSE) {

  dir.create(".temp", showWarnings = FALSE)

  tmp_sql_file <- glue::glue("./.temp/tempfile.{floor(runif(1)*1000000)}.sql")
  df <- declare_vars <- NULL

  read_file_and_columns_size <- function() {
    if(csv2) {
      suppressMessages(df <<- readr::read_csv2(csv_file))
    } else {
      suppressMessages(df <<- readr::read_csv(csv_file))
    }
    max_length <- purrr::map(df, ~ max(stringr::str_length(.), na.rm = TRUE))
    declare_vars <<- stringr::str_c(names(df), " varchar (", max_length, ")",
                           collapse = ",\n")
  }

  replace_NA_by_NULL <- function() {
    df <<- replace(df, is.na(df), 'NULL')
  }

  replace_quotes_by_spaces <- function() {
    (
      df
      %>% dplyr::mutate(dplyr::across(
        .fns = ~ stringr::str_replace_all(., "'", " ")))
    ) ->> df
  }

  create_table <- function() {
    drop_table(table_name, confirm = FALSE)
    create_table_string <- glue::glue("create table {table_name} (\n",
                                      " {declare_vars})\n/\n\n")
    readr::write_file(create_table_string, tmp_sql_file)
  }

  insert_lines <- function() {

    slice_thickness <- 1000
    N <- nrow(df)
    number_of_slice <- ceiling(N / slice_thickness) - 1

    purrr::walk(0:number_of_slice, function(nb_of_t) {

      slice <- dplyr::slice(df, 1:slice_thickness + nb_of_t*slice_thickness)
      (
        slice
        %>% dplyr::mutate(into = glue::glue("into {table_name} values "),
                          .before = 1)
        %>% dplyr::mutate(values = purrr::reduce(.[2:ncol(.)],
                                                 stringr::str_c, sep = "','"))
        %>% dplyr::mutate(out = glue::glue("{into} ('{values}')"))
        %>% dplyr::pull(out)
        %>% stringr::str_c(collapse = "\n")
      ) -> lines_to_insert
      insert_into_string <- glue::glue("insert all \n{lines_to_insert}\n")
      readr::write_file(insert_into_string, tmp_sql_file, append = TRUE)
      readr::write_file("select * from dual \n/\n", tmp_sql_file, append = TRUE)
    })
  }

  print_title <- function() {
    cli::cli_h1(
      stringr::str_c(
        "Import du fichier {.emph {csv_file}} ",
        "vers la table {.emph {table_name}}")
    )
  }


  read_file_and_columns_size()
  replace_NA_by_NULL()
  replace_quotes_by_spaces()
  create_table()
  insert_lines()
  print_title()
  exec_sql_file(tmp_sql_file, with_title = FALSE)
  file.remove(tmp_sql_file)
}

upload_from_csv2 <- function(csv_file, table_name) {
  upload_from_csv(csv_file, table_name, csv2 = TRUE)
}

