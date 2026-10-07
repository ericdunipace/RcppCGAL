# Compare CGAL file contents, ignoring tar metadata and compression differences.
bundle_manifest <- function(archive) {
  if (!file.exists(archive)) stop("Archive does not exist: ", archive)
  extracted <- tempfile("cgal-manifest-")
  dir.create(extracted)
  on.exit(unlink(extracted, recursive = TRUE), add = TRUE)
  utils::untar(archive, exdir = extracted)
  roots <- list.dirs(extracted, recursive = FALSE, full.names = TRUE)
  if (length(roots) != 1L ||
      !file.exists(file.path(roots[[1L]], "basic.h"))) {
    stop("Expected one CGAL header root containing basic.h in: ", archive)
  }
  root <- roots[[1L]]
  files <- sort(list.files(root, recursive = TRUE, all.files = TRUE))
  manifest <- setNames(unname(tools::md5sum(file.path(root, files))), files)
  if (!length(manifest) || anyNA(manifest)) {
    stop("Could not hash all CGAL files in: ", archive)
  }
  manifest
}

bundle_changed <- function(committed, candidate) {
  # A missing candidate is always an error, even when the old bundle is missing.
  new <- bundle_manifest(candidate)
  old <- if (file.exists(committed)) bundle_manifest(committed) else character()
  added <- setdiff(names(new), names(old))
  removed <- setdiff(names(old), names(new))
  common <- intersect(names(old), names(new))
  modified <- common[old[common] != new[common]]
  changed <- length(added) + length(removed) + length(modified) > 0L
  cat(sprintf("CGAL files: %d added, %d removed, %d modified\n",
              length(added), length(removed), length(modified)))
  cat(sprintf("changed=%s\n", if (changed) "true" else "false"))
  output <- Sys.getenv("GITHUB_OUTPUT")
  if (nzchar(output)) {
    cat(sprintf("changed=%s\n", if (changed) "true" else "false"),
        file = output, append = TRUE)
  }
  invisible(changed)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 2L) {
    stop("Usage: Rscript tools/ci/bundle-changed.R <committed archive> <candidate archive>")
  }
  bundle_changed(args[[1L]], args[[2L]])
}
