the <- new.env(parent = emptyenv())

.onAttach <-function(libname, pkgname) {

  version_file <- system.file("extdata", "version", package = "sndsmart")
  version <- read.delim(version_file, colClasses = c("character"), header = F)

  packageStartupMessage("Bienvenue dans le package sndsmart !")
  packageStartupMessage(glue::glue("Vous uilisez la version {version}"))
}


