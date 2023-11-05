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
  
  temp_file <- download_tarball(dest_folder, cgal_path, pkg_path, overwrite)
  
  
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
  dest_file <- file.path(dest_folder, "CGAL_zip")
  
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
  
  utils::untar(tarfile = temp_file, exdir = dest_folder)
  # unzip_file <- paste0("CGAL-",version)
  unzip_file  <- list.dirs(dest_folder, 
                           recursive = FALSE, full.names = FALSE)
  target_file <- file.path(dest_folder, "CGAL")
  source_file <- if (isTRUE(own)) {
    file.path(dest_folder, unzip_file)
  } else {
    file.path(dest_folder, unzip_file, "include","CGAL")
  }
  
  
  # Move good file into final position
  file.rename(source_file, target_file)
  
  # Delete temp files
  unlink(file.path(dest_folder, unzip_file), recursive = TRUE)
  
  return(target_file)
}


