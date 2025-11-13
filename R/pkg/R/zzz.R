.onLoad <- function(libname, pkgname) {
  if (Sys.getenv("DEVTOOLS_LOAD") == "pkg") {
    # Support syncing with `load_all()`
    path <- file.path(".", "bootstrap.R")
    if (file.exists(path)) {
      path <- normalizePath(path, mustWork = TRUE)
      source(path)
    }
  }
}