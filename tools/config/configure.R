# Prepare your package for installation here.
# Use 'define()' to define configuration variables.
# Use 'configure_file()' to substitute configuration values.

dir_path    <- file.path("inst","include")
path_to_tar <- file.path(dir_path, "CGAL_zip.tar.xz")
tar_exists  <- file.exists(path_to_tar)
if (tar_exists) define(CGAL_TEMP_TAR_PATH = path_to_tar)

env_cgal    <- Sys.getenv("CGAL_DIR")
not_set     <- isTRUE(env_cgal  == "")

DL          <- isTRUE(Sys.getenv("CGAL_DOWNLOAD")  != "0")

# functions to clean and download if needed
helper_path <- file.path("tools","config","downloader_functions.R")
if (file.exists(helper_path)) {
  source_file(helper_path)
} else {
  stop("Configure helper functions not found!")
}

# package environment variables, set one time
DEFAULT_URL <- "https://github.com/CGAL/cgal/releases/download/v6.0.1/CGAL-6.0.1.tar.xz"
DEFAULT_VERSION <- "6.0.1"
HEADER_SOURCE <- paste0("This is CGAL version ", DEFAULT_VERSION, ".")

if (tar_exists && not_set) {
  CLEANED <- TRUE
  untar_tarball(path_to_tar, dir_path, TRUE)
  # unlink(path_to_tar)
  
} else {
  CLEANED <- FALSE
  if (not_set) {
    message(
      paste0("Default header bundle not found. Downloading default version ",
             DEFAULT_VERSION
      )
    )
    env_cgal <- DEFAULT_URL
  } else {
    message(paste0("Getting CGAL files from\n    ", env_cgal, "\n"))
    HEADER_SOURCE  <- paste0("Supplied own CGAL from ", env_cgal)
  }
  cgal_predownloader(env_cgal, ".", DL)
  .cgal.cerr.remover("inst") # automatically adds include/CGAL as of now
  CLEANED <- TRUE
}

if (isFALSE(CLEANED)) warning("Cleaning of CGAL header files failed!")

define(SOURCE = paste0("'",HEADER_SOURCE,"'"))
