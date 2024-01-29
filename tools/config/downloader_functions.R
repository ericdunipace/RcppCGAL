is_url <- function(x) any(grepl("^(http|ftp)s?://", x), grepl("^(http|ftp)s://", x))

cgal_predownloader <- function(cgal_path, pkg_path, DL) {
  overwrite <- TRUE
  
  # increase timeout because of downloads
  old_options <- options(timeout = getOption("timeout"))
  on.exit(options(old_options))
  options(timeout = 1e4)
  
  # warn if overwrite
  if(!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) stop("`overwrite` must be TRUE or FALSE")
  
  cgal_path_isdir <- isTRUE(nzchar(cgal_path) && !is_url(cgal_path))
  
  dest_folder <- file.path(pkg_path, "inst", "include")
  dl_folder <- file.path(pkg_path, "inst")
  
  if (!file.exists(dest_folder)) {
    # create desitination folder
    dir.create(dest_folder)
  } else if (overwrite) {
    # delete old files if overwriting
    unlink(dest_folder, recursive = TRUE)
    dir.create(dest_folder)
  }
  
  if (cgal_path_isdir) {
    if (!file.exists(cgal_path)) {
      stop(sprintf("Environment variable CGAL_DIR is set to '%s' but file does not exists, unset environment variable or provide valid path to CGAL file.", cgal_path))
    }
    file.copy(from = cgal_path, to = dest_folder, recursive = TRUE)
    
    # check if need to rename
    cgal_copy <- list.files(dest_folder)
    if(cgal_copy != "CGAL") {
      cur_file <- file.path(dest_folder, cgal_copy)
      final_file <- file.path(dest_folder, "CGAL")
      file.rename(from = cur_file, to = final_file)
    }
    
    return(cgal_path)
  }
  
  temp_file <- download_tarball(".", cgal_path, pkg_path, overwrite)
  
  
  target_file <- untar_tarball(temp_file,
                               dest_folder)
  
  unlink(temp_file)
  return(target_file[file.exists(target_file)])
}

download_tarball <- function(dest_folder, cgal_path, pkg_path, overwrite = FALSE) {
  
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
  if ( nzchar(cgal_path) && is_url(cgal_path) ) {
    cgal_url <- cgal_path
  } else {
    stop("Path is not a valid character or URL. Please check your entry.")
  }
  
  # Save to temporary file first to protect against incomplete downloads
  temp_file <- paste(dest_file, "tar.xz", sep = ".")
  message(paste0("Performing one-time download of CGAL from\n    ", cgal_url, "\n"))
  utils::flush.console()
  utils::download.file(url = cgal_url, destfile = temp_file, mode = "wb", cacheOK = FALSE, quiet = TRUE)
  
  # Apply sanity checks
  if ( !file.exists(temp_file) )
    stop("Error: Transfer failed. Please download ", cgal_url, " and place CGAL include directory in ", dest_folder)
  
  return(temp_file)
  
}

untar_tarball <- function(temp_file, dest_folder, own = FALSE) {
  # message("  Unzipping the CGAL file\n")
  if (!file.exists(dest_folder)) {
    dir.create(dest_folder)
  }
  
  target_file <- file.path(dest_folder, "CGAL")
  
  tmp_dir_ <- file.path("uz_tmp90") # can add "~" for root file.path("~","uz_tmp90")
  dir.create(tmp_dir_)
  
  # whichtar <- if (.Platform$OS.type == "windows") {
  #   "internal" #windows server tar function fails for some reason
  # } else {
  #   Sys.getenv("TAR")
  # }
  # utils::untar(tarfile = temp_file, exdir = tmp_dir_, tar = whichtar)
  
  # using system TAR causes windwos server builds to hang
  utils::untar(tarfile = temp_file, exdir = tmp_dir_, verbose = TRUE)
  unzip_file  <- list.dirs(tmp_dir_, 
                           recursive = FALSE, full.names = FALSE)
  
  if (isTRUE(own)) {
    source_file <- file.path(tmp_dir_, unzip_file)
  } else {
    source_file <- file.path(tmp_dir_, unzip_file, "include","CGAL")
  }
  
  # message("  Moving CGAL folder to its final location\n")
  # Move good file into final position
  if (!file.exists(target_file)) dir.create(target_file)
  file.rename(source_file, target_file)
  
  # Delete temp files
  unlink(tmp_dir_, recursive = TRUE)
  if(isFALSE(own))  unlink(temp_file, recursive = TRUE)
  
  return(target_file)
}

#' Removes std::cerr references from files.
#'
#' @param pkg_path character giving path to the package
#'
#' @return None.
#' 
#' @details changes the downloaded files to R outputs
#' 
#' @keywords internal
.cgal.cerr.remover <- function(pkg_path = NULL) {
  
  if (is.null(pkg_path)) {
    pkg_path <- dirname(system.file(".", package = "RcppCGAL"))
  }
  dest_folder <- file.path(pkg_path, "include", "CGAL")
  
  
  # change files
  message("\nChanging CGAL's message output to R's output...\n")
  files <- list.files(path = dest_folder, all.files = TRUE,
                      full.names = TRUE, recursive = TRUE)
  tx <- first <- search <- NULL
  for (f in files) {
    
    # append new line to all files
    cat("\n", file = f, append = TRUE) # only two files are problematic but easier than searching in R
    
    # read in header file to search for problems
    tx  <- readLines(f, warn = TRUE)
    
    # # test code to avoid having to add new line to all files...may not be worth it.
    # # setup warning environment
    # warnlist <- list2env(list(w = FALSE))
    # no_endline <- FALSE
    # 
    # # check for warning AND get file
    # tx <- withCallingHandlers(
    #   tryCatch(readLines(f, warn = TRUE)),
    #   warning = function(w){warnlist$w <- TRUE; invokeRestart("muffleWarning")})
    # if (isTRUE(warnlist$w)) {
    #  no_endline <- TRUE
    # }
    
    # search for problem functions
    search  <- grep(pattern = "std::cerr|std::cout|abort\\(|exit\\(", x = tx)
    abn_end <- length(search) > 0 # returns true if any found
    
    if(!abn_end) next
    
    # search for problematic functions if present
    tx[1] <- paste0("#include <Rcpp.h>\n", tx[1])
    tx[search]  <- gsub(pattern = "std::tuple<Locate_type, int, int> exit\\(\\) const", 
                        replacement="std::tuple<Locate_type, int, int\\> exit_tmp\\(\\) const", 
                        x = tx[search])
    tx[search]  <- gsub(pattern = "std::cerr", replacement = "Rcpp::Rcerr", x = tx[search])
    tx[search]  <- gsub(pattern = "std::cout", replacement = "Rcpp::Rcout", x = tx[search])
    tx[search]  <- gsub(pattern = "std::abort\\(\\)", replacement = 'Rcpp::stop("Error")', x = tx[search])
    tx[search]  <- gsub(pattern = " abort\\(\\)", replacement = 'Rcpp::stop("Error")', x = tx[search])
    tx[search]  <- gsub(pattern = "std::exit\\(\\)", replacement = 'Rcpp::stop("Error")', x = tx[search])
    tx[search]  <- gsub(pattern = " exit\\(\\)", replacement = 'Rcpp::stop("Error")', x = tx[search])
    tx[search]  <- gsub(pattern = "std::exit\\(0\\)", replacement = 'Rcpp::stop("Success")', x = tx[search])
    tx[search]  <- gsub(pattern = "std::exit\\(1\\)", replacement = 'Rcpp::stop("Error")', x = tx[search])
    tx[search]  <- gsub(pattern = "std::tuple<Locate_type, int, int> exit_tmp\\(\\) const", 
                        replacement="std::tuple<Locate_type, int, int\\> exit\\(\\) const", 
                        x = tx[search])
    writeLines(tx, con=f)
    
  }
  return(invisible(NULL))
}

