the <- new.env(parent = emptyenv())

.onAttach <-function(libname, pkgname) {

  version_file <- system.file("extdata", "version", package = "sndsmart")
  version <- read.delim(version_file, colClasses = c("character"), header = F)

  packageStartupMessage("               _                          _       ")
  packageStartupMessage(" ___ _ __   __| |___ _ __ ___   __ _ _ __| |_     ")
  packageStartupMessage("/ __| '_ \\ / _` / __| '_ ` _ \\ / _` | '__| __| ")
  packageStartupMessage("\\__ \\ | | | (_| \\__ \\ | | | | | (_| | |  | |_")
  packageStartupMessage(glue::glue("|___/_| |_|\\__,_|___/_| |_| |_|\\__,_|_|",
                                   " \\__| version {version}"))
  packageStartupMessage("")
  packageStartupMessage("Commencez par la commande `orchestration()`")
  packageStartupMessage("")
}



