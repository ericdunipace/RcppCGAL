is_url <- function(x) {
  any(grepl("^(http|ftp)s?://", x), grepl("^(http|ftp)s://", x))
}

cgal_predownloader <- function(cgal_path, pkg_path, DL) {
  overwrite <- TRUE

  # increase timeout because of downloads
  old_options <- options(timeout = getOption("timeout"))
  on.exit(options(old_options))
  options(timeout = 1e4)

  # warn if overwrite
  if (!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) {
    stop("`overwrite` must be TRUE or FALSE")
  }

  cgal_path_isdir <- isTRUE(nzchar(cgal_path) && !is_url(cgal_path))

  dest_folder <- file.path(pkg_path, "inst", "include")
  dl_folder <- file.path(pkg_path, "inst")

  if (!file.exists(dest_folder)) {
    # create desitination folder
    dir.create(dest_folder, recursive = TRUE)
  } else if (overwrite) {
    # delete old files if overwriting
    unlink(dest_folder, recursive = TRUE)
    dir.create(dest_folder)
  }

  if (cgal_path_isdir) {
    if (!file.exists(cgal_path)) {
      stop(sprintf(
        "Environment variable CGAL_DIR is set to '%s' but file does not exists, unset environment variable or provide valid path to CGAL file.",
        cgal_path
      ))
    }
    file.copy(from = cgal_path, to = dest_folder, recursive = TRUE)

    # check if need to rename
    cgal_copy <- list.files(dest_folder)
    if (cgal_copy != "CGAL") {
      cur_file <- file.path(dest_folder, cgal_copy)
      final_file <- file.path(dest_folder, "CGAL")
      file.rename(from = cur_file, to = final_file)
    }

    return(cgal_path)
  }

  temp_file <- download_tarball(".", cgal_path, pkg_path, overwrite)

  target_file <- untar_tarball(temp_file, dest_folder)

  unlink(temp_file)
  return(target_file[file.exists(target_file)])
}

download_tarball <- function(
  dest_folder,
  cgal_path,
  pkg_path,
  overwrite = FALSE
) {
  # Check for CGAL file in 'inst/include' directory.
  # if (! overwrite && ! cgal_path_isdir) {
  #   possible_file <- file.path(pkg_path, "inst", "include", "CGAL")
  #   if (file.exists(possible_file)) {
  #     cgal_pkg_state$VERSION <- cgal_pkg_state$OLD_VERSION
  #     return(possible_file)
  #   }
  # }

  # buildnumFile <- file.path(pkg_path, "VERSION")
  # version <- readLines(buildnumFile)
  # cgal_pkg_state$CLEANED <- FALSE
  dest_file <- file.path(pkg_path, dest_folder, "CGAL_zip")

  # Download if CGAL doesn't already exist or user specifies force overwrite
  if (nzchar(cgal_path) && is_url(cgal_path)) {
    cgal_url <- cgal_path
  } else {
    stop("Path is not a valid character or URL. Please check your entry.")
  }

  # Save to temporary file first to protect against incomplete downloads
  temp_file <- paste(dest_file, "tar.xz", sep = ".")
  message(paste0(
    "Performing one-time download of CGAL from\n    ",
    cgal_url,
    "\n"
  ))
  utils::flush.console()
  utils::download.file(
    url = cgal_url,
    destfile = temp_file,
    mode = "wb",
    cacheOK = FALSE,
    quiet = TRUE
  )

  # Apply sanity checks
  if (!file.exists(temp_file)) {
    stop(
      "Error: Transfer failed. Please download ",
      cgal_url,
      " and place CGAL include directory in ",
      dest_folder
    )
  }

  return(temp_file)
}

untar_with_fallback <- function(
  tarfile,
  exdir = ".",
  tar = Sys.getenv("TAR"),
  ...
) {
  # Try using system tar first
  try_system_tar <- try(
    {
      utils::untar(tarfile, exdir = exdir, tar = tar, ...)
      return(TRUE)
    },
    silent = TRUE
  )

  # If system tar fails, fall back to R's internal tar
  if (inherits(try_system_tar, "try-error")) {
    message(
      "Informational message: System tar failed. Falling back to internal tar. Note: this is not an error."
    )
    try_internal_tar <- try(
      {
        utils::untar(tarfile, exdir = exdir, tar = "internal", ...)
        return(TRUE)
      },
      silent = TRUE
    )

    # Check if internal tar also fails
    if (inherits(try_internal_tar, "try-error")) {
      stop("Both system tar and internal tar failed to extract the archive.")
    }
  }

  message("Extraction completed successfully.")
}

untar_tarball <- function(temp_file, dest_folder, own = FALSE) {
  # message("  Unzipping the CGAL file\n")
  if (!file.exists(dest_folder)) {
    dir.create(dest_folder)
  }

  target_file <- file.path(dest_folder, "CGAL")
  if (!file.exists(temp_file)) {
    stop("Error! Can't find the tar file!")
  }

  # tmp_dir_ <- file.path(tempdir(), "uz_tmp_90")
  # dir.create(tmp_dir_)
  tmp_dir_ <- file.path("uz_tmp90") # can add "~" for root file.path("~","uz_tmp90")
  dir.create(tmp_dir_)

  # using system TAR causes windwos server builds to hang
  whichtar <- if (.Platform$OS.type == "windows") {
    "internal" # windows server tar function hangs indefinitely for some reason on git actions
  } else {
    Sys.getenv("TAR")
  }
  untar_with_fallback(tarfile = temp_file, exdir = tmp_dir_, tar = whichtar)
  # utils::untar(tarfile = temp_file, exdir = tmp_dir_)
  # using error catching version of untar which defaults to internal R tar if system tar handle "xz" files

  unzip_file <- list.dirs(tmp_dir_, recursive = FALSE, full.names = FALSE)

  if (isTRUE(own)) {
    source_file <- file.path(tmp_dir_, unzip_file)
  } else {
    source_file <- file.path(tmp_dir_, unzip_file, "include", "CGAL")
  }

  # message("  Moving CGAL folder to its final location\n")
  # Move good file into final position
  # if (!file.exists(target_file)) dir.create(target_file)
  if (length(source_file) == 0 || !file.exists(source_file)) {
    stop(sprintf(
      "Error! The headerfiles were not decompressed properly! unzip file = '%s', temp file = '%s'",
      temp_file,
      tmp_dir_
    ))
  }
  file.rename(source_file, target_file)

  # Delete temp files
  unlink(tmp_dir_, recursive = TRUE)
  if (isFALSE(own)) {
    unlink(temp_file, recursive = TRUE)
  }

  return(target_file)
}

#' Legacy wrapper for rewriting CGAL output streams.
#'
#' @param pkg_path character giving path to the package
#'
#' @return None.
#'
#' @details Use `.rewrite_cgal_streams()` from `semantic_patches.R` instead.
#'
#' @keywords internal
.cgal.cerr.remover <- function(pkg_path = NULL) {
  .Deprecated(".rewrite_cgal_streams")
  if (!exists(".rewrite_cgal_streams", mode = "function")) {
    helper <- file.path("tools", "config", "semantic_patches.R")
    if (!file.exists(helper)) {
      stop("Cannot find tools/config/semantic_patches.R", call. = FALSE)
    }
    source(helper, local = environment(.cgal.cerr.remover))
  }
  .rewrite_cgal_streams(pkg_path)
}

read_bib <- function(path) {
  paste(readLines(path, encoding = "UTF-8"), collapse = "\n")
}

# --- Helper: Extract author field robustly (brace-depth aware) ---
extract_author_fields <- function(text) {
  m <- gregexpr("author\\s*=\\s*", text, ignore.case = TRUE, perl = TRUE)[[1]]
  if (m[1] == -1) {
    return(character())
  }
  vals <- character(length(m))
  for (i in seq_along(m)) {
    start_eq <- m[i] + attr(m, "match.length")[i] - 1
    j <- start_eq + 1
    while (
      j <= nchar(text) && substr(text, j, j) %in% c(" ", "\t", "\n", "\r")
    ) {
      j <- j + 1
    }
    ch <- substr(text, j, j)
    if (ch == "\"") {
      j <- j + 1
      brace_depth <- 0L
      start_val <- j
      while (j <= nchar(text)) {
        cch <- substr(text, j, j)
        if (cch == "{") {
          brace_depth <- brace_depth + 1L
        } else if (cch == "}") {
          brace_depth <- max(0L, brace_depth - 1L)
        } else if (cch == "\"" && brace_depth == 0L) {
          break
        }
        j <- j + 1
      }
      vals[i] <- substr(text, start_val, j - 1)
    } else if (ch == "{") {
      j <- j + 1
      brace_depth <- 1L
      start_val <- j
      while (j <= nchar(text) && brace_depth > 0L) {
        cch <- substr(text, j, j)
        if (cch == "{") {
          brace_depth <- brace_depth + 1L
        } else if (cch == "}") {
          brace_depth <- brace_depth - 1L
        }
        j <- j + 1
      }
      vals[i] <- substr(text, start_val, j - 2)
    } else {
      start_val <- j
      while (j <= nchar(text) && !substr(text, j, j) %in% c(",", "\n", "\r")) {
        j <- j + 1
      }
      vals[i] <- trimws(substr(text, start_val, j - 1))
    }
  }
  vals
}

# --- Helper: Convert LaTeX accent codes to Unicode ---
latex_to_unicode <- function(x) {
  conv <- c(
    "\\\\\"{a}" = "ä",
    "\\\\\"{A}" = "Ä",
    "\\\\\"{o}" = "ö",
    "\\\\\"{O}" = "Ö",
    "\\\\\"{u}" = "ü",
    "\\\\\"{U}" = "Ü",
    "\\\\\"a" = "ä",
    "\\\\\"A" = "Ä",
    "\\\\\"o" = "ö",
    "\\\\\"O" = "Ö",
    "\\\\\"u" = "ü",
    "\\\\\"U" = "Ü",
    "\\\\\"e" = "ë",
    "\\\\\"E" = "Ë",
    "\\\\\"i" = "ï",
    "\\\\\"I" = "Ï",
    "\\\\~a" = "ã",
    "\\\\~A" = "Ã",
    "\\\\-d" = "đ",
    "\\\\-D" = "Đ",
    "\\\\'a" = "á",
    "\\\\'A" = "Á",
    "\\\\'e" = "é",
    "\\\\'E" = "É",
    "\\\\'i" = "í",
    "\\\\'I" = "Í",
    "\\\\'o" = "ó",
    "\\\\'O" = "Ó",
    "\\\\'u" = "ú",
    "\\\\'U" = "Ú",
    "\\\\`a" = "à",
    "\\\\`e" = "è",
    "\\\\`i" = "ì",
    "\\\\`o" = "ò",
    "\\\\`u" = "ù",
    "\\\\~n" = "ñ",
    "\\\\~N" = "Ñ",
    "\\\\c{c}" = "ç",
    "\\\\c{C}" = "Ç",
    "\\\\c{S}" = "Ş",
    "\\\\c{s}" = "ş",
    "\\\\i" = "ı",
    "\\\\I" = "İ",
    "\\\\^a" = "â",
    "\\\\^e" = "ê",
    "\\\\^i" = "î",
    "\\\\^o" = "ô",
    "\\\\^u" = "û",
    "\\\\ss" = "ß",
    "\\\\ae" = "æ",
    "\\\\AE" = "Æ",
    "\\\\oe" = "œ",
    "\\\\OE" = "Œ",
    "\\\\o" = "ø",
    "\\\\O" = "Ø"
  )
  for (pat in names(conv)) {
    x <- gsub(pat, conv[[pat]], x, perl = TRUE)
  }
  # remove any remaining braces used for grouping
  gsub("[{}]", "", x)
}

clean_name <- function(x) {
  x <- trimws(x)
  if (startsWith(x, "{") && endsWith(x, "}")) {
    x <- substr(x, 2, nchar(x) - 1)
  }
  x <- gsub("\\s+", " ", x)
  latex_to_unicode(x)
}

# --- Main extraction function ---
extract_all_authors <- function(bib_path, out_unique = "authors_unique.txt") {
  txt <- read_bib(bib_path)
  fields <- extract_author_fields(txt)
  parts <- unlist(
    strsplit(fields, "\\s+and\\s+", perl = TRUE),
    use.names = FALSE
  )
  parts <- parts[nzchar(trimws(parts))]
  parts <- vapply(parts, clean_name, character(1))
  # writeLines(parts, out_full, useBytes = TRUE)
  writeLines(sort(unique(parts)), out_unique, useBytes = TRUE)
  cat(sprintf(
    "Wrote to %s (%d unique authors)\n",
    out_unique,
    length(unique(parts))
  ))
}
