#!/usr/bin/env Rscript

# Maintainer entry point. Run from any directory:
#   Rscript tools/patch_cgal_semantics.R /path/to/extracted/include/CGAL

script_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (!length(script_argument)) stop("Cannot locate patch_cgal_semantics.R", call. = FALSE)
script_path <- normalizePath(sub("^--file=", "", script_argument[[1L]]), mustWork = TRUE)
source(file.path(dirname(script_path), "config", "semantic_patches.R"))

arguments <- commandArgs(trailingOnly = TRUE)
if (length(arguments) != 1L) {
  stop("Usage: patch_cgal_semantics.R CGAL_INCLUDE_ROOT", call. = FALSE)
}

.patch_cgal_headers(arguments[[1L]])
message("Applied the reviewed CGAL semantic patches.")
