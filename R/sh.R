#' Launch a linux bash shell
#'
#' @param command call system and returns
#' @param current_dir dir of execution
#' @param complete_path prompts the absolute path of current directory
#' @param intern returns shell output (see system)
#'
#' @return nothing or shell ouput
#' @export
#'
#' @examples
#' sh()
sh <- function(command = NULL,
               current_dir = getwd(),
               complete_path = FALSE,
               intern = FALSE) {
  if (!is.null(command)) {
    system(command, intern = intern)
  } else {
    while (TRUE) {
      r <- readline(format_prompt(complete_path, current_dir))
      if (r == "exit")
        return(invisible())
      if (   stringr::str_starts(r, "cd ")
          || stringr::str_trim(r) == "cd")
        current_dir <- treat_cd_case(r, current_dir)
      else
        system(stringr::str_c("cd ", current_dir, " && ", r))
    }
  }
}

parent_dir <- function(dir) {
  if (dir == "/")
    return("/")
  else
    stringr::str_replace(dir, "/[^/]*$", "")
}

treat_cd_case <- function(r, current_dir) {
  new_directory_name <-
    stringr::str_trim(stringr::str_remove(r, "cd "))

  # if (new_directory_name == "") {
  #   new_directory_name <- "~"
  # }

 new_directory <- paste0(current_dir, "/", new_directory_name)

 if (   stringr::str_starts(new_directory_name, "/")
     || stringr::str_detect(new_directory_name, "$")) {
   new_directory <- new_directory_name
 }

  current_dir <-
    system(stringr::str_c("cd ", current_dir, " && ",
                          r , " && pwd"),
           intern = T)
  system(stringr::str_c("cd ", current_dir, " && ls"))
  return(current_dir)
}

format_prompt <- function(complete_path, current_dir) {

  short_name <- function(dir) stringr::str_extract(dir, "[^/]*$")

  if (complete_path) {
    path <- current_dir
  } else {
    path <- short_name(current_dir)
  }

  stringr::str_c(path, " $ ")
}
