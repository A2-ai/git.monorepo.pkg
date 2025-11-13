#!/usr/bin/env Rscript

# Bootstrap script to copy shared code from monorepo into R package
# Based on tree-sitter-r pattern

files <- c("world.R")
upstream_directory <- file.path("..", "..", "src")
upstream <- file.path(upstream_directory, files)
destination <- file.path("R", files)

sync <- function(upstream_directory, upstream, destination) {
  upstream_directory <- normalizePath(upstream_directory, mustWork = FALSE)

  if (dir.exists(upstream_directory)) {
    # Development environment - copy from monorepo
    sync_with_upstream(upstream, destination)
  } else {
    # Installation from tarball - check files exist
    sync_without_upstream(destination)
  }

  invisible()
}

sync_with_upstream <- function(upstream, destination) {
  any_updated <- FALSE

  for (i in seq_along(upstream)) {
    updated <- sync_with_upstream_one(upstream[[i]], destination[[i]])
    any_updated <- any_updated || updated
  }

  if (any_updated) {
    message("Bootstrap: Files updated successfully.")
  } else {
    message("Bootstrap: All files were up to date.")
  }
}

sync_with_upstream_one <- function(upstream, destination) {
  upstream <- normalizePath(upstream, mustWork = TRUE)
  destination <- normalizePath(destination, mustWork = FALSE)

  # Ensure the R directory exists
  dir_destination <- dirname(destination)
  if (!dir.exists(dir_destination)) {
    message(sprintf("Bootstrap: Creating `%s` directory.", dir_destination))
    dir.create(dir_destination, recursive = TRUE)
  }

  update <- needs_update(upstream, destination)

  if (update) {
    message(sprintf("Bootstrap: Copying `%s` to `%s`.", upstream, destination))
    file.copy(upstream, destination, overwrite = TRUE)
  }

  update
}

sync_without_upstream <- function(destination) {
  message(paste0(
    "Bootstrap: Can't find parent source directory, ",
    "package has likely been moved to a temporary directory. ",
    "Checking if required files already exist from a previous bootstrap run."
  ))

  if (!all(file.exists(destination))) {
    stop(paste0(
      "Bootstrap: Can't find required files, ",
      "and can't find the parent source directory to copy from. ",
      "Do you need to run `bootstrap.R` before the package ",
      "is moved to the temporary directory?"
    ))
  }

  message("Bootstrap: Found required files, proceeding.")
  invisible()
}

needs_update <- function(upstream, destination) {
  if (!file.exists(destination)) {
    # First time ever
    return(TRUE)
  }

  upstream_modified <- file.info(upstream)$mtime
  destination_modified <- file.info(destination)$mtime

  isTRUE(upstream_modified > destination_modified)
}

# Run it!
sync(upstream_directory, upstream, destination)
