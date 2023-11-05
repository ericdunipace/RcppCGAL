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

helper_path <- file.path("tools","config","downloader_functions.R")

# package environment variables. needs '' to be put in correctly
DEFAULT_URL <- "https://github.com/CGAL/cgal/releases/download/v5.6/CGAL-5.6.tar.xz"
DEFAULT_VERSION <- "5.6.0"
VERSION <- paste0("This is CGAL version ", DEFAULT_VERSION, ".")


if (file.exists(helper_path)) source_file(helper_path)

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
    VERSION  <- paste0("Supplied own CGAL from ", env_cgal)
  }
  source_file("R/cleaner.R")
  cgal_predownloader(env_cgal, "inst", DL)
  .cgal.cerr.remover("inst/include/CGAL")
  CLEANED <- TRUE
}

define(DEFAULT_URL = paste0("'",DEFAULT_URL,"'"))
define(DEFAULT_VERSION = paste0("'",DEFAULT_VERSION,"'"))
define(VERSION = paste0("'",VERSION,"'"))
define(CLEANED = CLEANED)






