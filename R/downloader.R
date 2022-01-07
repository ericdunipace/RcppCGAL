#' Downloads CGAL files
#'
#' @param overwrite TRUE FALSE, default is FALSE
#'
#' @return file name
#' 
#' @details downloads the CGAL package from the web to not piss off picky CRAN
#' 
#' @keywords internal
.cgal.downloader <- function(overwrite = FALSE) {
  old_options <- options(timeout = getOption("timeout"))
  on.exit(options(old_options))
  options(timeout = 1e4)
  if(!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) stop("`overwrite` must be TRUE or FALSE")
  
  own_cgal <- Sys.getenv("CGAL_DIR")
  is_url <- function(x) any(grepl("^(http|ftp)s?://", x), grepl("^(http|ftp)s://", x))
  
  pkg_path = dirname(system.file(".", package = "RcppCGAL"))
  
  # Check for CGAL file in 'include' directory.
  if (! overwrite) {
    possible_file <- file.path(pkg_path, "include", "CGAL")
    if (file.exists(possible_file)) {
      return(possible_file)
    }
  }
  
  # Check for CGAL file in 'inst/include' directory.
  if (! overwrite) {
    possible_file <- file.path(pkg_path, "inst", "include", "CGAL")
    if (file.exists(possible_file)) {
      return(possible_file)
    }
  }
  
  dest_folder <- file.path(pkg_path, "include")
  if (!file.exists(dest_folder)) {
    dir.create(dest_folder)
  }
  
  if (nzchar(own_cgal) && !is_url(own_cgal)) {
    if (!file.exists(own_cgal))
      stop(sprintf("Environment variable CGAL_DIR is set to '%s' but file does not exists, unset environment variable or provide valid path to CGAL file.", own_cgal))
    file.rename(from = own_cgal, to = dest_folder)
    return(own_cgal)
  }
  
  buildnumFile <- file.path(pkg_path, "VERSION")
  version <- readLines(buildnumFile)
  
  dest_file <- file.path(dest_folder, "CGAL_zip")
  
  # Download if CGAL doesn't already exist or user specifies force overwrite
  if (nzchar(own_cgal) && is_url(own_cgal)) {
    cgal_url <- own_cgal
  } else {
    cgal_url <- paste0("https://github.com/CGAL/cgal/releases/download/v",version,"/CGAL-",version,"-library.tar.xz")
  }
  
  # Save to temporary file first to protect against incomplete downloads
  temp_file <- paste(dest_file, "tar.xz", sep = ".")
  cat("Performing one-time download of CGAL from\n")
  cat("    ", cgal_url, "\n")
  utils::flush.console()
  utils::download.file(url = cgal_url, destfile = temp_file, mode = "wb", cacheOK = FALSE, quiet = TRUE)
  
  # Apply sanity checks
  if(!file.exists(temp_file))
    stop("Error: Transfer failed. Please download ", cgal_url, " and place CGAL include directory in ", dest_folder)
  
  utils::untar(tarfile = temp_file, exdir = dest_folder)
  unzip_file <- paste0("CGAL-",version)
  target_file <- file.path(dest_folder, "CGAL")
  source_file <- file.path(dest_folder, unzip_file,"include","CGAL")
  
  # Move good file into final position
  file.rename(source_file, target_file)
  unlink(temp_file)
  unlink(file.path(dest_folder, unzip_file), recursive = TRUE)
  
  
  return(target_file[file.exists(target_file)])
}

#' Removes std::cerr references from files.
#'
#' @param overwrite TRUE FALSE, default is FALSE
#'
#' @return None.
#' 
#' @details downloads the CGAL package from the web to not piss off picky CRAN
#' 
#' @keywords internal
.cgal.cerr.remover <- function(pkg_path = NULL) {
  
  if (is.null(pkg_path)) {
    pkg_path <- dirname(system.file(".", package = "RcppCGAL"))
  }
  dest_folder <- file.path(pkg_path, "include", "CGAL")
  
  # check to see if changes have already been done before
  stored_change_log <- file.path(pkg_path, "saveCheck", "OUTPUT_CHANGED")
  
  if(!file.exists(stored_change_log)) {
    file.create(stored_change_log)
  }
  CHANGED <- readLines(stored_change_log)
  if(isTRUE(CHANGED == "TRUE")) {
    return(invisible())
  }
  
  # change files
  cat("\nChanging CGAL's message output to R's output...")
  files <- list.files(path = dest_folder, all.files = TRUE,
                      full.names = TRUE, recursive = TRUE)
  tx <- first <- search <- NULL
  for (f in files) {
    tx  <- readLines(f, warn = FALSE)
    search <- grep(pattern = "std::cerr|std::cout|abort\\(\\)|exit\\(\\)", x = tx)
    if (length(search)==0) next
    first <- grep("#include", tx)[1]
    tx[first]  <- sub(pattern = "#include",   replacement = "#include <Rcpp.h>\n#include", x = tx[first])
    tx[search]  <- gsub(pattern = "std::cerr", replacement = "Rcpp::Rcerr", x = tx[search])
    tx[search]  <- gsub(pattern = "std::cout", replacement = "Rcpp::Rcout", x = tx[search])
    tx[search]  <- gsub(pattern = "abort\\(\\)", replacement = "Rcpp::Rstop()", x = tx[search])
    tx[search]  <- gsub(pattern = "exit\\(\\)", replacement = "Rcpp::Rstop()", x = tx[search])
    writeLines(tx, con=f)
  }
  CHANGED <- "TRUE"
  writeLines(CHANGED, con = stored_change_log)
}

# for use on my machine to change files uploaded to github
.cgal.cerr.remover.github <- function() {
  path <- file.path(getwd(), "inst")
  .cgal.cerr.remover(path)
}



