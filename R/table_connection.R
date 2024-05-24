table_connection <- function(table_name) {
  assign(table_name,
         dplyr::tbl(the$connection, table_name),
         .GlobalEnv)
}
