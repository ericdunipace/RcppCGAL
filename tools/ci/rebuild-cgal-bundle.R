# Rebuild the candidate archive before installation. Run from the package root:
# Rscript tools/ci/rebuild-cgal-bundle.R
rebuild_cgal_bundle <- function(pkg_path = ".", source_archive = NULL) {
  pkg_path <- normalizePath(pkg_path, mustWork = TRUE)
  config <- parse(file.path(pkg_path, "tools", "config", "configure.R"))
  defaults <- new.env(parent = baseenv())
  for (expression in config) {
    if (is.call(expression) && identical(expression[[1L]], as.name("<-")) &&
        as.character(expression[[2L]]) %in% c("DEFAULT_URL", "DEFAULT_VERSION")) {
      eval(expression, envir = defaults)
    }
  }
  stopifnot(is.character(defaults$DEFAULT_URL),
            length(defaults$DEFAULT_URL) == 1L,
            is.character(defaults$DEFAULT_VERSION),
            length(defaults$DEFAULT_VERSION) == 1L)

  work <- tempfile("cgal-pr-rebuild-")
  dir.create(work)
  on.exit(unlink(work, recursive = TRUE), add = TRUE)
  if (is.null(source_archive)) {
    source_archive <- file.path(work, "upstream.tar.xz")
    old_options <- options(timeout = max(300, getOption("timeout", 60)))
    on.exit(options(old_options), add = TRUE)
    message("Downloading pristine CGAL ", defaults$DEFAULT_VERSION,
            " from ", defaults$DEFAULT_URL)
    utils::download.file(defaults$DEFAULT_URL, source_archive, mode = "wb")
  }
  upstream <- file.path(work, "upstream")
  dir.create(upstream)
  utils::untar(source_archive, exdir = upstream)
  roots <- list.dirs(upstream, recursive = FALSE, full.names = TRUE)
  candidates <- file.path(roots, "include", "CGAL")
  candidates <- candidates[file.exists(file.path(candidates, "basic.h"))]
  stopifnot(length(candidates) == 1L)

  candidate <- file.path(work, "candidate")
  include <- file.path(candidate, "include")
  dir.create(include, recursive = TRUE)
  stopifnot(file.copy(candidates[[1L]], include, recursive = TRUE))
  patches <- file.path(pkg_path, "tools", "config", "semantic_patches.R")
  if (file.exists(patches)) {
    source(patches, local = TRUE)
    .patch_cgal_headers_for_R(candidate)
  } else {
    # Older branches use this same sanitizer in their download install path.
    source(file.path(pkg_path, "tools", "config", "downloader_functions.R"),
           local = TRUE)
    .cgal.cerr.remover(candidate)
  }

  # A single CGAL root is accepted by the existing bundled install path.
  archive <- file.path(work, "CGAL_zip.tar.xz")
  old_wd <- getwd()
  setwd(include)
  tryCatch(
    utils::tar(archive, files = "CGAL", compression = "xz", tar = "internal"),
    finally = setwd(old_wd)
  )
  destination <- file.path(pkg_path, "inst", "include", "CGAL_zip.tar.xz")
  stopifnot(file.copy(archive, destination, overwrite = TRUE))
  message("Candidate bundle written to ", destination)
  invisible(destination)
}

if (sys.nframe() == 0L) rebuild_cgal_bundle()
