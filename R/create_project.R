create_project <- function(project_name, open.project = TRUE, pro = FALSE) {

  RStudio_dir <- skeleton_dir <- project_dir <-
    Rproj_file <- template_dir <-  NULL

  set_up_path_variables <- function() {
    RStudio_dir  <<- system("pwd", intern = TRUE)
    skeleton_dir <<- system.file(
      "extdata", "new_project_skeleton", package = "sndsmart"
      )
    pro_templates_path <- system.file("extdata/pro_templates",
                                      package = "sndsmart")
    pro.orchestration_filepath <<- paste0(pro_templates_path, "/01-sql-orchestration.R")
    pro.Rprofile_filepath <<- paste0(pro_templates_path, "/.Rprofile")
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

  copy_pro_files <- function() {
    file.copy(pro.Rprofile_filepath, project_dir, overwrite = TRUE)
    file.copy(pro.orchestration_filepath,
              paste0(project_dir, "/R/"), overwrite = TRUE)
  }

  main <- function() {
    set_up_path_variables()
    copy_skeleton_dir_to_new_project()
    if(pro) copy_pro_files()
    if(open.project) rstudioapi::openProject(Rproj_file)
    invisible()
  }

  main()
}
