l <- function(prefixe) {
  prefixe <- rlang::quo_name(rlang::enquo(prefixe))
  list_tables(prefixe)
}
p <- function(table) {
  table <- rlang::quo_name(rlang::enquo(table))
  preview_table(table)
}
dl <- function(table) {
  table <- rlang::quo_name(rlang::enquo(table))
  download_table(table)
}
dr <- function(table) {
  table <- rlang::quo_name(rlang::enquo(table))
  drop_table(table)
}
tc <- function(table) {
  table <- rlang::quo_name(rlang::enquo(table))
  table_connection(table)
}
