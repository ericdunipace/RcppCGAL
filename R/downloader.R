
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

  # make conditions TRUE or FALSE
  force <- isTRUE(force)
  clean_files <- isTRUE(clean_files)
  cgal_exists <- cgal_is_installed()
  
  # remove previous auto install error file if exists
  .delete_error_file()
  
  if(cgal_exists  && !force ) {
    message("CGAL already installed. To reinstall, set force = TRUE.")
    return(invisible(NULL))
  } else if (cgal_exists && force) {
    warning("CGAL already exists. This will overwrite the current directory")
  }
  
  cgal_path <- .cgal_url(cgal_path, version)
  
  .cgal.downloader(cgal_path, force)
  if(clean_files) .cgal.cerr.remover()
  
  # reset warnings and such so if uninstalled will re-prompt to DL
  cgal_pkg_state$WARNED <- cgal_pkg_state$ASK_INSTALL <- FALSE
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
  
  # if need to download the files
  if ( missing(cgal_path) || is.null(cgal_path) || cgal_path == "" ) {
    
    # get info from GitHub
    all_gh <- gh::gh("GET /repos/{owner}/{repo}/releases", 
                     owner = "CGAL",
                     repo = "cgal")
    
    # choose proper release
    if (missing(version) || is.null(version)) {
      
      # don't select beta versions
      max_assets <- length(all_gh)
      non_beta_rel <- sapply(all_gh, function(a) !grepl("beta",a$assets[[1]]$name))
      
      # check can find non beta releases
      if (all(isFALSE(non_beta_rel))) {
        stop("Wasn't able to find any non-beta CGAL releases on the GitHub. This is likely a bug. Please report this.")
      }
      
      # try last stable release
      select_vers <- min((1:max_assets)[non_beta_rel])
      
    } else {
      
      # get desired version
      allvers <- sapply(all_gh, `[[`, "tag_name")
      select_vers <- grep(version, allvers)
      
    }
    
    # pull out selected asset version
    select_gh <- all_gh[[select_vers]]
    assets    <- select_gh$assets
    
    # select the proper download file (updated 6/2023 to include beta versions)
    which.as  <- which(sapply(assets, function(a) grepl("CGAL-([0-9][0-9.]*)(-beta[0-9]?)?\\.tar\\.xz",a$name)))
    
    # check that has selected a version properly
    if ( length(which.as) == 0 ) {
      names.to.print <- sapply(assets, function(a) a$name)
      error.desc <- paste0(c("Unable to find the latest GitHub release of the CGAL header files. Likely the regex failed to find the correct file. Please report this error. Here are the file names it did find:", names.to.print), collapse = "\n")
      stop(error.desc)
    }
    
    # get URL
    cgal_path <- assets[[which.as]]$browser_download_url
    
    # extract version
    cgal_vers <- gsub("v", "", select_gh[["tag_name"]])
    
    # save version number
    .save_cgal_version(version = cgal_vers, own = FALSE)
  } else {
    # save file path
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
  
  # increase timeout because of downloads
  old_options <- options(timeout = getOption("timeout"))
  on.exit(options(old_options))
  options(timeout = 1e4)
  
  # warn if overwrite
  if(!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) stop("`overwrite` must be TRUE or FALSE")
  
  is_url <- function(x) any(grepl("^(http|ftp)s?://", x), grepl("^(http|ftp)s://", x))
  
  pkg_path <- .rcppcgal_package_path()
  cgal_path_isdir <- isTRUE(nzchar(cgal_path) && !is_url(cgal_path))
  
  # Check for CGAL file in 'include' directory.
  if (! overwrite && ! cgal_path_isdir) {
    possible_file <- file.path(pkg_path, "include", "CGAL")
    
    if (file.exists(possible_file)) {
      cgal_pkg_state$VERSION <- cgal_pkg_state$OLD_VERSION
      message(sprintf("Found possible file at %s. To overwrite, set `force = TRUE` and run `cgal_install` again", possible_file))
      return(possible_file)
    }
  }
  
  # Check for CGAL file in 'inst/include' directory.
  # if (! overwrite && ! cgal_path_isdir) {
  #   possible_file <- file.path(pkg_path, "inst", "include", "CGAL")
  #   if (file.exists(possible_file)) {
  #     cgal_pkg_state$VERSION <- cgal_pkg_state$OLD_VERSION
  #     return(possible_file)
  #   }
  # }
  
  dest_folder <- file.path(pkg_path, "include")
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
  message(paste0("Performing one-time download of CGAL from\n    ", cgal_url, "\n"))
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
