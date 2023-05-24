
#' CGAL header file installer
#'
#' @param cgal_path Path to CGAL files on your machine, a URL. If NULL will downloaded latest version from GitHub. Default is NULL.
#' @param version Desired version to search for from the GitHub. If NULL, will download latest.
#' @param clean_files Whether to remove calls to C std::err from header files to avoid errors in R. Default is TRUE
#' @param force Whether to force downloading and install the header files if they're already found in the package. Default is FALSE
#'
#' @return NULL
#' @export
cgal_install <- function(cgal_path = NULL, version = NULL, clean_files = TRUE, force = FALSE) {
  force <- isTRUE(force)
  clean_files <- isTRUE(clean_files)
  cgal_exists <- cgal_is_installed()
  
  if(cgal_exists  && !force ) {
    return(invisible(NULL))
  } else if (cgal_exists && force) {
    warning("CGAL already exists. This will overwrite the current directory")
  }
  
  cgal_path <- .cgal_url(cgal_path, version)
  
  .cgal.downloader(cgal_path, force)
  if(clean_files) .cgal.cerr.remover()
  
  return(invisible(NULL))
}

#' Gets CGAL URL
#'
#' @param cgal_path Path to CGAL files on your machine, a URL. If NULL will downloaded latest version from GitHub. Default is NULL.
#' @param version Desired version to search for from the GitHub. If NULL, will download latest.
#'
#' @details to be used by [RcppCGAL::cgal_install()]
#' @return URL to use or path as a character vector
#'
#' @keywords internal
.cgal_url <- function(cgal_path, version) {
  if ( missing(cgal_path) || is.null(cgal_path) ) {
    cgal_path <- Sys.getenv("CGAL_DIR")
  }
  
  if ( missing(cgal_path) || is.null(cgal_path) || cgal_path == "" ) {
    
    all_gh <- gh::gh("GET /repos/{owner}/{repo}/releases", 
                     owner = "CGAL",
                     repo = "cgal")
    if (missing(version) || is.null(version)) {
      select_vers <- 1L
      
    } else {
      allvers <- sapply(all_gh, `[[`, "tag_name")
      select_vers <- grep(version, allvers)
    }
    select_gh <- all_gh[[select_vers]]
    assets    <- select_gh$assets
    which.as  <- which(sapply(assets, function(a) grepl("CGAL-([0-9][0-9.]*)\\.tar\\.xz",a$name)))
    cgal_path <- assets[[which.as]]$browser_download_url
    cgal_vers <- gsub("v", "", select_gh[["tag_name"]])
    
    .save_cgal_version(version = cgal_vers, own = FALSE)
  } else {
    .save_cgal_version(version = cgal_path, own = TRUE)
  }
  
  return(cgal_path)
  
}


#' Downloads CGAL files
#'
#' @param overwrite TRUE FALSE, default is FALSE
#'
#' @return file name
#' 
#' @details downloads the CGAL package from the web
#' 
#' @keywords internal
.cgal.downloader <- function(cgal_path, overwrite = FALSE) {
  old_options <- options(timeout = getOption("timeout"))
  on.exit(options(old_options))
  options(timeout = 1e4)
  if(!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) stop("`overwrite` must be TRUE or FALSE")
  
  is_url <- function(x) any(grepl("^(http|ftp)s?://", x), grepl("^(http|ftp)s://", x))
  
  pkg_path = dirname(system.file(".", package = "RcppCGAL"))
  cgal_path_isdir <- isTRUE(nzchar(cgal_path) && !is_url(cgal_path))
  
  # Check for CGAL file in 'include' directory.
  if (! overwrite && ! cgal_path_isdir) {
    possible_file <- file.path(pkg_path, "include", "CGAL")
    
    if (file.exists(possible_file)) {
      cgal_pkg_state$VERSION <- cgal_pkg_state$OLD_VERSION
      return(possible_file)
    }
  }
  
  # Check for CGAL file in 'inst/include' directory.
  if (! overwrite && ! cgal_path_isdir) {
    possible_file <- file.path(pkg_path, "inst", "include", "CGAL")
    if (file.exists(possible_file)) {
      cgal_pkg_state$VERSION <- cgal_pkg_state$OLD_VERSION
      return(possible_file)
    }
  }
  
  dest_folder <- file.path(pkg_path, "include")
  if (!file.exists(dest_folder)) {
    dir.create(dest_folder)
  } else if (overwrite) {
    unlink(dest_folder, recursive = TRUE)
    dir.create(dest_folder)
  }
  
  if (cgal_path_isdir) {
    if (!file.exists(cgal_path)) {
      stop(sprintf("Environment variable CGAL_DIR is set to '%s' but file does not exists, unset environment variable or provide valid path to CGAL file.", cgal_path))
    }
    file.copy(from = cgal_path, to = dest_folder, recursive = TRUE)
    return(cgal_path)
  }
  
  # buildnumFile <- file.path(pkg_path, "VERSION")
  # version <- readLines(buildnumFile)
  cgal_pkg_state$CLEANED <- FALSE
  dest_file <- file.path(dest_folder, "CGAL_zip")
  
  # Download if CGAL doesn't already exist or user specifies force overwrite
  if ( nzchar(cgal_path) && is_url(cgal_path) ) {
    cgal_url <- cgal_path
  } else {
    stop("Path is not a valid character or URL. Please report this bug.")
  }
  
  # Save to temporary file first to protect against incomplete downloads
  temp_file <- paste(dest_file, "tar.xz", sep = ".")
  cat("Performing one-time download of CGAL from\n")
  cat("    ", cgal_url, "\n")
  utils::flush.console()
  utils::download.file(url = cgal_url, destfile = temp_file, mode = "wb", cacheOK = FALSE, quiet = TRUE)
  
  # Apply sanity checks
  if ( !file.exists(temp_file) )
    stop("Error: Transfer failed. Please download ", cgal_url, " and place CGAL include directory in ", dest_folder)
  
  utils::untar(tarfile = temp_file, exdir = dest_folder)
  # unzip_file <- paste0("CGAL-",version)
  unzip_file  <- list.dirs(dest_folder, 
                           recursive = FALSE, full.names = FALSE)
  target_file <- file.path(dest_folder, "CGAL")
  source_file <- file.path(dest_folder, unzip_file, "include","CGAL")
  
  # Move good file into final position
  file.rename(source_file, target_file)
  unlink(temp_file)
  unlink(file.path(dest_folder, unzip_file), recursive = TRUE)
  
  
  return(target_file[file.exists(target_file)])
}
