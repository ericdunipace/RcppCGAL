# Base-R regression checks for content comparison (no package dependencies).
source("tools/ci/bundle-changed.R")
test_bundle_comparison <- function() {
  work <- tempfile("test-cgal-bundles-")
  dir.create(work)
  on.exit(unlink(work, recursive = TRUE), add = TRUE)
  old_output <- Sys.getenv("GITHUB_OUTPUT", unset = NA_character_)
  on.exit(if (is.na(old_output)) Sys.unsetenv("GITHUB_OUTPUT") else
    Sys.setenv(GITHUB_OUTPUT = old_output), add = TRUE)
  output <- file.path(work, "output")
  Sys.setenv(GITHUB_OUTPUT = output)

  make_archive <- function(label, contents, date) {
    stage <- file.path(work, label)
    root <- file.path(stage, "CGAL")
    dir.create(root, recursive = TRUE)
    for (name in names(contents)) {
      path <- file.path(root, name)
      dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
      writeLines(contents[[name]], path)
    }
    Sys.setFileTime(list.files(root, recursive = TRUE, all.files = TRUE,
                              full.names = TRUE), as.POSIXct(date, tz = "UTC"))
    archive <- file.path(work, paste0(label, ".tar"))
    old_wd <- getwd()
    setwd(stage)
    tryCatch(utils::tar(archive, files = "CGAL", tar = "internal"),
             finally = setwd(old_wd))
    archive
  }

  contents <- c("basic.h" = "// basic", "nested/a.h" = "// a",
                ".hidden" = "// hidden")
  original <- make_archive("original", contents, "2000-01-01")
  same <- make_archive("same", contents, "2020-01-01")
  stopifnot(unname(tools::md5sum(original)) != unname(tools::md5sum(same)))
  text <- capture.output(changed <- bundle_changed(original, same))
  stopifnot(!changed, any(grepl("0 added, 0 removed, 0 modified", text)),
            tail(readLines(output), 1L) == "changed=false")

  edited <- contents
  edited[[".hidden"]] <- "// modified"
  edited <- edited[names(edited) != "nested/a.h"]
  edited[["nested/b.h"]] <- "// added"
  candidate <- make_archive("changed", edited, "2020-01-01")
  text <- capture.output(changed <- bundle_changed(original, candidate))
  stopifnot(changed, any(grepl("1 added, 1 removed, 1 modified", text)),
            tail(readLines(output), 1L) == "changed=true")
  capture.output(changed <- bundle_changed(file.path(work, "missing"), same))
  stopifnot(changed)
  # Repeating the comparison still reports unchanged: archive bytes are irrelevant.
  capture.output(changed <- bundle_changed(original, same))
  stopifnot(!changed)
  stopifnot(inherits(try(bundle_changed(original, file.path(work, "missing")),
                        silent = TRUE), "try-error"))
  malformed <- make_archive("malformed", c("other.h" = "// no basic.h"), "2000-01-01")
  stopifnot(inherits(try(bundle_changed(original, malformed), silent = TRUE),
                     "try-error"))
  message("Bundle content comparison regression checks passed.")
}
test_bundle_comparison()
