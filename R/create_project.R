create_project <- function(project_name, open.project = TRUE) {

  RStudio_dir <- skeleton_dir <- project_dir <-
    Rproj_file <- template_dir <-  NULL

  set_up_path_variables <- function() {
    browser()
    RStudio_dir  <<- system("pwd", intern = TRUE)
    skeleton_dir <<- system.file(
      "extdata", "new_project_skeleton", package = "sndsmart"
      )
    project_dir  <<- stringr::str_c(RStudio_dir, "/", project_name)
    Rproj_file   <<- stringr::str_c(project_dir, "/", project_name, ".Rproj")
    template_dir <<- system.file("extdata", "templates", package = "sndsmart")
  }

  copy_skeleton_dir_to_new_project <- function() {
    if(dir.exists(project_dir))
      stop("Le répertoire projet existe déjà.")
    dir.create(project_dir)
    file_vector <- list.files(skeleton_dir, all.files = TRUE)[-(1:2)]
    path_vector <- stringr::str_c(skeleton_dir, "/", file_vector)
    file.copy(path_vector, project_dir, recursive = TRUE)
    file.copy(stringr::str_c(template_dir, "/template.Rproj"), Rproj_file)
  }

  main <- function() {
    set_up_path_variables()
    copy_skeleton_dir_to_new_project()
    if(open.project) rstudioapi::openProject(Rproj_file)
    invisible()
  }

  main()
}
