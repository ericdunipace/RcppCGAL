# Reviewed patches for pristine CGAL headers. Each patch checks the
# expected upstream shape and stops before writing if that shape has changed.

.cgal_read_lines <- function(path) {
  readLines(path, warn = FALSE, encoding = "UTF-8")
}

.cgal_write_lines <- function(path, lines) {
  writeLines(lines, path, useBytes = TRUE)
}

.cgal_expect <- function(found, expected, label, path) {
  if (length(found) != expected) {
    stop(
      sprintf(
        "%s: expected %d %s; found %d",
        path,
        expected,
        label,
        length(found)
      ),
      call. = FALSE
    )
  }
  found
}

.cgal_count_matches <- function(lines, pattern) {
  matches <- gregexpr(pattern, paste(lines, collapse = "\n"), perl = TRUE)[[1L]]
  if (matches[[1L]] < 0L) 0L else length(matches)
}

.cgal_block_end <- function(lines, start, label, path) {
  candidates <- seq.int(start, length(lines))
  opening <- candidates[grepl("{", lines[candidates], fixed = TRUE)][1L]
  if (is.na(opening)) {
    stop(sprintf("%s: no opening brace for %s", path, label), call. = FALSE)
  }

  depth <- 0L
  for (line in seq.int(opening, length(lines))) {
    depth <- depth +
      lengths(regmatches(lines[line], gregexpr("{", lines[line], fixed = TRUE)))
    depth <- depth -
      lengths(regmatches(lines[line], gregexpr("}", lines[line], fixed = TRUE)))
    if (depth == 0L) return(line)
  }
  stop(sprintf("%s: no closing brace for %s", path, label), call. = FALSE)
}

.cgal_add_stdexcept <- function(lines, path) {
  if (any(grepl("^[[:space:]]*#include[[:space:]]*<stdexcept>", lines))) {
    return(lines)
  }
  namespace <- grep(
    "^[[:space:]]*namespace[[:space:]]+CGAL[[:space:]]*\\{",
    lines
  )
  if (!length(namespace)) {
    stop(sprintf("%s: no namespace CGAL for <stdexcept>", path), call. = FALSE)
  }
  append(lines, "#include <stdexcept>", after = namespace[[1L]] - 1L)
}

.cgal_add_compat <- function(lines) {
  include <- "#include <RcppCGAL/compat.h>"
  if (include %in% lines) lines else c(include, lines)
}

.cgal_replace <- function(lines, pattern, replacement, expected, label, path) {
  found <- .cgal_count_matches(lines, pattern)
  if (found != expected) {
    stop(
      sprintf("%s: expected %d %s; found %d", path, expected, label, found),
      call. = FALSE
    )
  }
  text <- gsub(
    pattern,
    replacement,
    paste(lines, collapse = "\n"),
    perl = TRUE
  )
  strsplit(text, "\n", fixed = TRUE)[[1L]]
}

.cgal_patch_assertions <- function(lines, path) {
  functions <- c("assertion", "precondition", "postcondition", "warning")
  exceptions <- c(
    "Assertion_exception",
    "Precondition_exception",
    "Postcondition_exception",
    "Warning_exception"
  )
  call_pattern <- "std::(?:abort|exit)[[:space:]]*\\([^;]*\\)[[:space:]]*;"

  for (i in seq_along(functions)) {
    function_name <- paste0(functions[[i]], "_fail")
    start <- .cgal_expect(
      grep(paste0("\\b", function_name, "[[:space:]]*\\("), lines, perl = TRUE),
      1L,
      paste0(function_name, " function"),
      path
    )
    end <- .cgal_block_end(lines, start, function_name, path)
    section <- lines[start:end]
    count <- .cgal_count_matches(section, call_pattern)
    if (count != 3L) {
      stop(
        sprintf(
          "%s: expected 3 abort/exit calls in %s; found %d",
          path,
          function_name,
          count
        ),
        call. = FALSE
      )
    }
    replacement <- sprintf(
      "throw %s(\"CGAL\", expr, file, line, msg);",
      exceptions[[i]]
    )
    lines[start:end] <- gsub(call_pattern, replacement, section, perl = TRUE)
  }
  lines
}

.cgal_patch_cones <- function(lines, path) {
  guard_pattern <- paste0(
    "^[[:space:]]*if[[:space:]]*\\([[:space:]]*cone_number",
    "[[:space:]]*<[[:space:]]*2[[:space:]]*\\)[[:space:]]*\\{"
  )
  starts <- .cgal_expect(
    grep(guard_pattern, lines),
    2L,
    "invalid-cone guards",
    path
  )

  for (start in rev(starts)) {
    end <- .cgal_block_end(lines, start, "invalid-cone guard", path)
    body <- paste(lines[start:end], collapse = "\n")
    if (
      !grepl("CGAL_assertion|(?:std::)?exit[[:space:]]*\\(", body, perl = TRUE)
    ) {
      stop(
        sprintf("%s:%d: unrecognized invalid-cone guard", path, start),
        call. = FALSE
      )
    }
    indent <- sub("^(\\s*).*", "\\1", lines[[start]], perl = TRUE)
    replacement <- c(
      paste0(indent, "if (cone_number < 2) {"),
      paste0(indent, "    throw std::invalid_argument("),
      paste0(
        indent,
        "        \"The number of cones must be larger than 1!\");"
      ),
      paste0(indent, "}")
    )
    lines <- append(
      lines[-seq.int(start, end)],
      replacement,
      after = start - 1L
    )
  }
  .cgal_add_stdexcept(lines, path)
}

.cgal_patch_ogl <- function(lines, path) {
  callback <- .cgal_expect(
    grep(
      "^[[:space:]]*inline[[:space:]]+void[[:space:]]+CGAL_GLU_TESS_CALLBACK[[:space:]]+errorCallback",
      lines
    ),
    1L,
    "GLU errorCallback",
    path
  )
  callback_end <- .cgal_block_end(lines, callback, "GLU errorCallback", path)
  if (
    .cgal_count_matches(
      lines[callback:callback_end],
      "(?:std::)?exit[[:space:]]*\\("
    ) !=
      1L
  ) {
    stop(
      sprintf("%s: expected one exit call in GLU errorCallback", path),
      call. = FALSE
    )
  }

  indent <- sub("^(\\s*).*", "\\1", lines[[callback]], perl = TRUE)
  replacement <- c(
    paste0(
      indent,
      "static thread_local GLenum cgal_glu_tessellation_error = 0;"
    ),
    "",
    paste0(
      indent,
      "inline void CGAL_GLU_TESS_CALLBACK errorCallback(GLenum errorCode)"
    ),
    paste0(indent, "{ cgal_glu_tessellation_error = errorCode; }")
  )
  lines <- append(
    lines[-seq.int(callback, callback_end)],
    replacement,
    after = callback - 1L
  )

  new_tess <- .cgal_expect(
    grep(
      "GLUtesselator[[:space:]]*\\*[[:space:]]*tess_[[:space:]]*=[[:space:]]*gluNewTess[[:space:]]*\\([[:space:]]*\\)[[:space:]]*;",
      lines
    ),
    1L,
    "gluNewTess owner",
    path
  )
  delete_tess <- .cgal_expect(
    grep(
      "gluDeleteTess[[:space:]]*\\([[:space:]]*tess_[[:space:]]*\\)[[:space:]]*;",
      lines
    ),
    1L,
    "gluDeleteTess call",
    path
  )

  reset_indent <- sub("^(\\s*).*", "\\1", lines[[new_tess]], perl = TRUE)
  lines <- append(
    lines,
    paste0(reset_indent, "cgal_glu_tessellation_error = 0;"),
    after = new_tess
  )
  if (delete_tess > new_tess) {
    delete_tess <- delete_tess + 1L
  }

  throw_indent <- sub("^(\\s*).*", "\\1", lines[[delete_tess]], perl = TRUE)
  check <- c(
    paste0(throw_indent, "if (cgal_glu_tessellation_error != 0) {"),
    paste0(
      throw_indent,
      "  throw std::runtime_error(\"CGAL GLU tessellation error\");"
    ),
    paste0(throw_indent, "}")
  )
  lines <- append(lines, check, after = delete_tess)
  .cgal_add_stdexcept(lines, path)
}

.cgal_patch_expected <- function(lines, path) {
  fallback <- .cgal_expect(
    grep(
      "^[[:space:]]*#define[[:space:]]+CGAL_TL_EXPECTED_THROW_EXCEPTION\\(e\\)[[:space:]]+std::terminate\\(\\);",
      lines
    ),
    1L,
    "std::terminate fallback",
    path
  )
  lines[[fallback]] <- "#define CGAL_TL_EXPECTED_THROW_EXCEPTION(e) throw((e));"
  lines
}

.cgal_patch_iris <- function(lines, path) {
  exit_lines <- grep(
    "(?<![[:alnum:]_:])exit[[:space:]]*\\(",
    lines,
    perl = TRUE
  )
  .cgal_expect(exit_lines, 5L, "IRIS exit calls", path)

  starts <- c(
    gray = .cgal_expect(
      grep(
        "^[[:space:]]*if[[:space:]]*\\(!pic824\\)[[:space:]]+exit\\(-1\\);",
        lines
      ),
      1L,
      "grayscale allocation exit",
      path
    ),
    color = .cgal_expect(
      grep("^[[:space:]]*if[[:space:]]*\\(!pic824\\)[[:space:]]*$", lines),
      1L,
      "color allocation exit",
      path
    ),
    tables = .cgal_expect(
      grep(
        "^[[:space:]]*if[[:space:]]*\\(!starttab[[:space:]]*\\|\\|[[:space:]]*!lengthtab[[:space:]]*\\|\\|[[:space:]]*!rledat\\)",
        lines
      ),
      1L,
      "RLE table allocation exit",
      path
    ),
    base = .cgal_expect(
      grep("^[[:space:]]*if[[:space:]]*\\(!base\\)[[:space:]]*$", lines),
      1L,
      "RLE image allocation exit",
      path
    ),
    verbatim = .cgal_expect(
      grep(
        "^[[:space:]]*if[[:space:]]*\\(!base[[:space:]]*\\|\\|[[:space:]]*!verdat\\)",
        lines
      ),
      1L,
      "verbatim allocation exit",
      path
    )
  )

  replacements <- list(
    gray = c(
      "if (!pic824) {",
      "  ImageIO_free(rawdata);",
      "  if (im->data) ImageIO_free(im->data);",
      "  im->data = nullptr;",
      "  return 0;",
      "}"
    ),
    color = c(
      "if (!pic824) {",
      "  ImageIO_free(rawdata);",
      "  if (im->data) ImageIO_free(im->data);",
      "  im->data = nullptr;",
      "  return 0;",
      "}"
    ),
    tables = c(
      "if (!starttab || !lengthtab || !rledat) {",
      "  if (starttab) ImageIO_free(starttab);",
      "  if (lengthtab) ImageIO_free(lengthtab);",
      "  if (rledat) ImageIO_free(rledat);",
      "  return (byte *) nullptr;",
      "}"
    ),
    base = c(
      "if (!base) {",
      "  ImageIO_free(starttab);",
      "  ImageIO_free(lengthtab);",
      "  ImageIO_free(rledat);",
      "  return (byte *) nullptr;",
      "}"
    ),
    verbatim = c(
      "if (!base || !verdat) {",
      "  if (base) ImageIO_free(base);",
      "  if (verdat) ImageIO_free(verdat);",
      "  return (byte *) nullptr;",
      "}"
    )
  )

  for (name in names(sort(starts, decreasing = TRUE))) {
    start <- starts[[name]]
    end <- if (name == "gray") start else start + 1L
    if (
      !grepl("exit[[:space:]]*\\(", paste(lines[start:end], collapse = " "))
    ) {
      stop(
        sprintf(
          "%s:%d: expected exit immediately after allocation check",
          path,
          start
        ),
        call. = FALSE
      )
    }
    indent <- sub("^(\\s*).*", "\\1", lines[[start]], perl = TRUE)
    replacement <- paste0(indent, replacements[[name]])
    lines <- append(
      lines[-seq.int(start, end)],
      replacement,
      after = start - 1L
    )
  }
  lines
}

.cgal_patch_vertex_conflict <- function(lines, path) {
  exit_line <- .cgal_expect(
    grep(
      "^[[:space:]]*exit[[:space:]]*\\([[:space:]]*1[[:space:]]*\\);",
      lines
    ),
    1L,
    "incircle consistency exit",
    path
  )
  indent <- sub("^(\\s*).*", "\\1", lines[[exit_line]], perl = TRUE)
  lines[[exit_line]] <- paste0(
    indent,
    "throw std::logic_error(\"CGAL Segment Delaunay incircle consistency check failed\");"
  )
  .cgal_add_stdexcept(lines, path)
}

.cgal_patch_rng_trapezoid <- function(lines, path) {
  lines <- .cgal_replace(
    lines,
    paste0(
      "if[[:space:]]*\\(static_cast<unsigned long>\\(std::rand\\(\\)\\)[[:space:]]*>",
      "[[:space:]]*RAND_MAX[[:space:]]*/[[:space:]]*\\([[:space:]]*num_of_cv[[:space:]]*\\+[[:space:]]*1[[:space:]]*\\)\\)"
    ),
    "if (RcppCGAL::RCGAL_unif_rand() > 1.0 / (num_of_cv + 1))",
    1L,
    "trapezoidal update random test",
    path
  )
  .cgal_add_compat(lines)
}

.cgal_patch_rng_classifier <- function(lines, path) {
  lines <- .cgal_replace(
    lines,
    "rand\\(\\)[[:space:]]*%[[:space:]]*feature_train\\.size\\(\\)",
    "RcppCGAL::RCGAL_unif_index(feature_train.size())",
    1L,
    "classifier feature selection",
    path
  )
  lines <- .cgal_replace(
    lines,
    "rand\\(\\)[[:space:]]*/[[:space:]]*float\\(RAND_MAX\\)",
    "RcppCGAL::RCGAL_unif_rand()",
    1L,
    "classifier weight draw",
    path
  )
  .cgal_add_compat(lines)
}

.cgal_patch_rng_curve_renderer <- function(lines, path) {
  lines <- .cgal_replace(
    lines,
    "static_cast<double>\\(rand\\(\\)\\)[[:space:]]*/[[:space:]]*RAND_MAX",
    "RcppCGAL::RCGAL_unif_rand()",
    2L,
    "curve-renderer random offsets",
    path
  )
  .cgal_add_compat(lines)
}

.cgal_patch_rng_point_set <- function(lines, path) {
  lines <- .cgal_replace(
    lines,
    "rand\\(\\)[[:space:]]*%[[:space:]]*\\(current\\.second[[:space:]]*-[[:space:]]*current\\.first\\)",
    paste0(
      "static_cast<std::ptrdiff_t>(RcppCGAL::RCGAL_unif_index(",
      "static_cast<std::size_t>(current.second - current.first)))"
    ),
    1L,
    "point-set pivot selection",
    path
  )
  .cgal_add_compat(lines)
}

.cgal_patch_rng_polygonal_schema <- function(lines, path) {
  lines <- .cgal_replace(
    lines,
    "static_cast<std::size_t>\\(rand\\(\\)[[:space:]]*%[[:space:]]*100\\)",
    "RcppCGAL::RCGAL_unif_index(100)",
    1L,
    "polygon perforation selection",
    path
  )
  .cgal_add_compat(lines)
}

.cgal_patch_rng_scanlines <- function(lines, path) {
  lines <- .cgal_replace(
    lines,
    "rand\\(\\)[[:space:]]*%[[:space:]]*1000[[:space:]]*==[[:space:]]*0",
    "RcppCGAL::RCGAL_unif_index(1000) == 0",
    1L,
    "scanline debug sampling",
    path
  )
  .cgal_add_compat(lines)
}

.cgal_patch_rng_quaternion <- function(lines, path) {
  lines <- .cgal_replace(
    lines,
    "rand\\(\\)[[:space:]]*/[[:space:]]*\\(qreal\\)RAND_MAX",
    "RcppCGAL::RCGAL_unif_rand()",
    3L,
    "quaternion random draws",
    path
  )
  .cgal_add_compat(lines)
}

.cgal_patch_rng_variational <- function(lines, path) {
  lines <- .cgal_replace(
    lines,
    paste0(
      "std::size_t r = static_cast<std::size_t>\\([[:space:]]*",
      "static_cast<double>\\(std::rand\\(\\)\\)[[:space:]]*/[[:space:]]*",
      "static_cast<double>\\(RAND_MAX\\)[[:space:]]*\\*[[:space:]]*",
      "static_cast<double>\\(nb_nsf[[:space:]]*-[[:space:]]*1\\)\\);"
    ),
    "std::size_t r = RcppCGAL::RCGAL_unif_index(nb_nsf);",
    1L,
    "variational face selection",
    path
  )
  .cgal_add_compat(lines)
}

.cgal_patch_imageio_stdout <- function(lines, path) {
  function_start <- .cgal_expect(
    grep(
      "^[[:space:]]*void[[:space:]]+_openWriteImage[[:space:]]*\\(",
      lines
    ),
    1L,
    "_openWriteImage function",
    path
  )
  function_end <- .cgal_block_end(
    lines,
    function_start,
    "_openWriteImage function",
    path
  )
  section <- lines[function_start:function_end]
  guard <- .cgal_expect(
    grep(
      "^[[:space:]]*if[[:space:]]*\\([[:space:]]*name[[:space:]]*==[[:space:]]*nullptr",
      section
    ),
    1L,
    "standard-output filename guard",
    path
  ) +
    function_start -
    1L
  guard_end <- .cgal_block_end(
    lines,
    guard,
    "standard-output filename guard",
    path
  )
  guard_body <- lines[guard:guard_end]
  .cgal_expect(
    grep("fileno[[:space:]]*\\([[:space:]]*stdout", guard_body),
    1L,
    "zlib stdout handle",
    path
  )
  .cgal_expect(
    grep("\\(_ImageIO_file\\)[[:space:]]*stdout", guard_body),
    1L,
    "plain stdout handle",
    path
  )

  indent <- sub("^(\\s*).*", "\\1", lines[[guard]], perl = TRUE)
  replacement <- c(
    paste0(indent, "if (name == nullptr || name[0] == '\\0'"),
    paste0(indent, "    || (name[0] == '-' && name[1] == '\\0')"),
    paste0(indent, "    || (name[0] == '>' && name[1] == '\\0')) {"),
    paste0(indent, "  im->fd = nullptr;"),
    paste0(indent, "  im->openMode = OM_CLOSE;"),
    paste0(
      indent,
      "  REprintf(\"CGAL ImageIO cannot write binary data to standard output in R\\n\");"
    ),
    paste0(indent, "  return;"),
    paste0(indent, "}")
  )
  lines <- append(
    lines[-seq.int(guard, guard_end)],
    replacement,
    after = guard - 1L
  )
  .cgal_add_compat(lines)
}

.cgal_patch_imageio_writer_errors <- function(lines, path) {
  expected <- if (grepl("pnm_impl\\.h$", path)) 2L else 1L
  diagnostics <- .cgal_expect(
    grep(
      paste0(
        "fprintf[[:space:]]*\\([[:space:]]*stderr[[:space:]]*,",
        "[[:space:]]*\"write(?:Inrimage|PgmImage): error: unable to open file .*%s.*\"",
        "[[:space:]]*,[[:space:]]*name[[:space:]]*\\);"
      ),
      lines,
      perl = TRUE
    ),
    expected,
    "null-safe ImageIO writer diagnostics",
    path
  )
  lines[diagnostics] <- sub(
    ",[[:space:]]*name[[:space:]]*\\);[[:space:]]*$",
    ", (name ? name : \"<standard output>\") );",
    lines[diagnostics],
    perl = TRUE
  )
  lines
}

.cgal_patch_color_output <- function(lines, path) {
  start <- .cgal_expect(
    grep(
      "^[[:space:]]*static[[:space:]]+bool[[:space:]]+detect_color_support[[:space:]]*\\(",
      lines
    ),
    1L,
    "detect_color_support function",
    path
  )
  end <- .cgal_block_end(lines, start, "detect_color_support function", path)
  section <- lines[start:end]
  probes <- c(
    "std::cout",
    "std::cerr",
    "std::clog",
    "CGAL_FILENO(stdout)",
    "CGAL_FILENO(stderr)"
  )
  for (token in probes) {
    .cgal_expect(
      grep(token, section, fixed = TRUE),
      1L,
      paste0(token, " color probe"),
      path
    )
  }

  indent <- sub("^(\\s*).*", "\\1", lines[[start]], perl = TRUE)
  replacement <- c(
    paste0(indent, "static bool detect_color_support(streambuf_type* buf) {"),
    paste0(
      indent,
      "  if (safe_getenv(\"NO_COLOR\").value_or(\"\").size() > 0)"
    ),
    paste0(indent, "    return false;"),
    "",
    paste0(
      indent,
      "  if (safe_getenv(\"CLICOLOR_FORCE\").value_or(\"\").size() > 0)"
    ),
    paste0(indent, "    return true;"),
    "",
    paste0(indent, "  (void)buf;"),
    paste0(indent, "  return false;"),
    paste0(indent, "}")
  )
  lines <- append(
    lines[-seq.int(start, end)],
    replacement,
    after = start - 1L
  )
  .cgal_add_compat(lines)
}

# Apply all reviewed patches in memory, then write them together.
.patch_cgal_headers <- function(cgal_root) {
  cgal_root <- normalizePath(cgal_root, mustWork = TRUE)
  targets <- c(
    "assertions_impl.h" = ".cgal_patch_assertions",
    "Compute_cone_boundaries_2.h" = ".cgal_patch_cones",
    "Nef_3/OGL_helper.h" = ".cgal_patch_ogl",
    "expected.h" = ".cgal_patch_expected",
    "ImageIO/Attic/iris_impl.h" = ".cgal_patch_iris",
    "Segment_Delaunay_graph_2/Vertex_conflict_C2.h" = ".cgal_patch_vertex_conflict",
    "Arr_point_location/Trapezoidal_decomposition_2.h" = ".cgal_patch_rng_trapezoid",
    "Classification/Sum_of_weighted_features_classifier.h" = ".cgal_patch_rng_classifier",
    "Curved_kernel_via_analysis_2/gfx/Curve_renderer_internals.h" = ".cgal_patch_rng_curve_renderer",
    "Point_set_3.h" = ".cgal_patch_rng_point_set",
    "Polygonal_schema.h" = ".cgal_patch_rng_polygonal_schema",
    "scanline_orient_normals.h" = ".cgal_patch_rng_scanlines",
    "Qt/quaternion_impl.h" = ".cgal_patch_rng_quaternion",
    "Variational_shape_approximation.h" = ".cgal_patch_rng_variational",
    "ImageIO_impl.h" = ".cgal_patch_imageio_stdout",
    "ImageIO/Attic/pnm_impl.h" = ".cgal_patch_imageio_writer_errors",
    "ImageIO/inr_impl.h" = ".cgal_patch_imageio_writer_errors",
    "IO/Color_ostream.h" = ".cgal_patch_color_output"
  )

  target_paths <- lapply(names(targets), function(relative) {
    path <- file.path(cgal_root, relative)
    .cgal_expect(path[file.exists(path)], 1L, relative, cgal_root)
  })
  names(target_paths) <- names(targets)
  contents <- lapply(target_paths, .cgal_read_lines)
  if (
    any(vapply(
      contents,
      function(x) any(grepl("RcppCGAL|Rcpp::", x)),
      logical(1)
    ))
  ) {
    stop("Semantic patching requires pristine CGAL headers", call. = FALSE)
  }

  patched <- Map(
    function(lines, path, patcher) {
      get(patcher, mode = "function")(lines, path)
    },
    contents,
    target_paths,
    unname(targets)
  )

  for (name in names(target_paths)) {
    .cgal_write_lines(target_paths[[name]], patched[[name]])
  }
  invisible(unname(unlist(target_paths)))
}

.patch_cgal_semantics <- function(pkg_path = NULL) {
  if (is.null(pkg_path)) {
    pkg_path <- dirname(system.file(".", package = "RcppCGAL"))
  }
  pkg_path <- normalizePath(pkg_path, mustWork = TRUE)
  message("\nApplying reviewed CGAL semantic patches...\n")
  .patch_cgal_headers(file.path(pkg_path, "include", "CGAL"))
}

.cgal_replace_active <- function(lines, pattern, replacement) {
  masked <- .cgal_mask_comments_and_strings(lines)
  if (length(masked) < length(lines)) {
    masked <- c(masked, rep("", length(lines) - length(masked)))
  }
  for (line in seq_along(lines)) {
    matches <- gregexpr(pattern, masked[[line]], perl = TRUE)[[1L]]
    if (matches[[1L]] < 0L) {
      next
    }

    lengths <- attr(matches, "match.length")
    for (i in rev(seq_along(matches))) {
      start <- matches[[i]]
      end <- start + lengths[[i]] - 1L
      lines[[line]] <- paste0(
        substr(lines[[line]], 1L, start - 1L),
        replacement,
        substr(lines[[line]], end + 1L, nchar(lines[[line]]))
      )
    }
  }
  lines
}

.cgal_rewrite_output <- function(lines) {
  rules <- list(
    list("std::cout", "Rcpp::Rcout"),
    list("std::cerr", "Rcpp::Rcerr"),
    list("std::clog", "Rcpp::Rcerr"),
    list(
      paste0(
        "(?<![[:alnum:]_])(?:std::)?fprintf[[:space:]]*\\(",
        "[[:space:]]*stderr[[:space:]]*,"
      ),
      "REprintf("
    ),
    list(
      paste0(
        "(?<![[:alnum:]_])(?:std::)?fprintf[[:space:]]*\\(",
        "[[:space:]]*stdout[[:space:]]*,"
      ),
      "Rprintf("
    ),
    list(
      "(?<![[:alnum:]_])(?:std::)?printf[[:space:]]*\\(",
      "Rprintf("
    )
  )
  for (rule in rules) {
    lines <- .cgal_replace_active(lines, rule[[1L]], rule[[2L]])
  }
  lines
}

.rewrite_cgal_streams <- function(pkg_path = NULL) {
  if (is.null(pkg_path)) {
    pkg_path <- dirname(system.file(".", package = "RcppCGAL"))
  }
  dest_folder <- file.path(pkg_path, "include", "CGAL")
  files <- list.files(dest_folder, full.names = TRUE, recursive = TRUE)
  staged <- list()

  message("\nChanging CGAL's message output to R's output...\n")
  for (path in files) {
    lines <- readLines(path, warn = FALSE)
    if (!any(grepl("std::cout|std::cerr|std::clog|printf", lines))) {
      next
    }

    rewritten <- .cgal_rewrite_output(lines)
    if (!identical(rewritten, lines)) {
      staged[[path]] <- .cgal_add_compat(rewritten)
    }
  }
  for (path in names(staged)) {
    writeLines(staged[[path]], path, useBytes = TRUE)
  }
  invisible(NULL)
}

.ensure_cgal_final_newlines <- function(pkg_path = NULL) {
  if (is.null(pkg_path)) {
    pkg_path <- dirname(system.file(".", package = "RcppCGAL"))
  }

  cgal_root <- file.path(pkg_path, "include", "CGAL")
  files <- list.files(
    cgal_root,
    pattern = "\\.(h|hh|hpp|hxx|ipp|tpp|cpp|cc|cxx)$",
    full.names = TRUE,
    recursive = TRUE,
    ignore.case = TRUE
  )

  has_final_newline <- function(path) {
    size <- file.info(path)$size
    if (is.na(size) || size == 0) {
      return(FALSE)
    }

    connection <- file(path, open = "rb")
    on.exit(close(connection))
    seek(connection, where = size - 1, origin = "start")

    identical(readBin(connection, "raw", n = 1L), charToRaw("\n"))
  }

  missing <- files[!vapply(files, has_final_newline, logical(1))]

  for (path in missing) {
    connection <- file(path, open = "ab")
    writeBin(charToRaw("\n"), connection)
    close(connection)
  }

  message(sprintf(
    "Added final newlines to %d CGAL header(s).",
    length(missing)
  ))
  invisible(missing)
}

.cgal_blank_matches <- function(text, pattern) {
  matches <- gregexpr(pattern, text, perl = TRUE)[[1L]]
  if (matches[[1L]] < 0L) {
    return(text)
  }

  characters <- strsplit(text, "", fixed = TRUE)[[1L]]
  match_lengths <- attr(matches, "match.length")
  for (i in seq_along(matches)) {
    positions <- seq.int(matches[[i]], length.out = match_lengths[[i]])
    non_newlines <- positions[characters[positions] != "\n"]
    characters[non_newlines] <- " "
  }
  paste(characters, collapse = "")
}

.cgal_mask_comments_and_strings <- function(lines) {
  text <- paste(lines, collapse = "\n")
  pattern <- paste(
    'R"([^ ()\\\\[:space:]]{0,16})\\((?s:.*?)\\)\\1"',
    '"(?:\\\\.|[^"\\\\])*"|\'(?:\\\\.|[^\'\\\\])*\'',
    '//[^\n]*|/\\*(?s:.*?)(?:\\*/|\\z)',
    sep = "|"
  )
  text <- .cgal_blank_matches(text, pattern)
  strsplit(text, "\n", fixed = TRUE)[[1L]]
}

.cgal_header_findings <- function(lines, file) {
  candidate_pattern <- paste(
    c(
      "abort",
      "exit",
      "_Exit",
      "terminate",
      "rand",
      "random",
      "drandom48",
      "std::cerr",
      "std::cout",
      "std::clog",
      "stdout",
      "stderr",
      "printf",
      "puts",
      "putchar",
      "NDEBUG",
      "assert"
    ),
    collapse = "|"
  )
  if (!any(grepl(candidate_pattern, lines, fixed = FALSE))) {
    return(list())
  }

  masked <- .cgal_mask_comments_and_strings(lines)
  findings <- list()
  add_finding <- function(type, line, detail) {
    findings[[length(findings) + 1L]] <<- data.frame(
      type = type,
      file = file,
      line = line,
      detail = detail,
      stringsAsFactors = FALSE
    )
  }
  nonmember_calls <- function(text, pattern) {
    calls <- gregexpr(pattern, text, perl = TRUE)[[1L]]
    if (calls[[1L]] < 0L) {
      return(character())
    }
    member_call <- vapply(
      calls,
      function(start) {
        prefix <- substr(text, 1L, start - 1L)
        grepl("(?:\\.|->)[[:space:]]*$", prefix, perl = TRUE)
      },
      logical(1)
    )
    trimws(regmatches(text, list(calls))[[1L]][!member_call])
  }

  termination_pattern <- paste0(
    "(?<![[:alnum:]_])((?:(?:std)?::)?(?:abort|exit|quick_exit|",
    "_Exit|_exit|terminate))[[:space:]]*\\("
  )
  rng_pattern <- paste0(
    "(?<![[:alnum:]_])((?:(?:std)?::)?(?:rand|random|drandom48))",
    "[[:space:]]*\\([[:space:]]*\\)|",
    "(?<![[:alnum:]_])((?:(?:std)?::)?(?:srand|srandom))",
    "[[:space:]]*\\("
  )
  output_pattern <- paste0(
    "(?<![[:alnum:]_])(?:std::)?(?:printf|puts|putchar)[[:space:]]*\\(",
    "|(?<![[:alnum:]_])(?:std::)?(?:fprintf|vfprintf)[[:space:]]*",
    "\\([[:space:]]*(?:stdout|stderr)[[:space:]]*,",
    "|(?<![[:alnum:]_])(?:std::)?(?:fputs|fputc)[[:space:]]*",
    "\\([^,]*,[[:space:]]*(?:stdout|stderr)[[:space:]]*\\)"
  )
  format_pattern <- paste0(
    "(?<![[:alnum:]_])(?:sprintf|vsprintf)[[:space:]]*\\("
  )

  for (line in seq_along(masked)) {
    if (
      grepl(
        "^[[:space:]]*#[[:space:]]*undef[[:space:]]+NDEBUG\\b",
        masked[[line]],
        perl = TRUE
      )
    ) {
      add_finding(
        "assertion configuration",
        line,
        paste0("assertions re-enabled: ", trimws(lines[[line]]))
      )
    }
    if (
      grepl(
        "^[[:space:]]*#[[:space:]]*define[[:space:]]+assert\\b",
        masked[[line]],
        perl = TRUE
      )
    ) {
      add_finding(
        "assertion configuration",
        line,
        paste0("assert macro redefined: ", trimws(lines[[line]]))
      )
    }

    streams <- regmatches(
      masked[[line]],
      gregexpr("std::(?:cerr|cout|clog)", masked[[line]], perl = TRUE)
    )[[1L]]
    for (stream in streams) {
      add_finding("output", line, stream)
    }

    output_calls <- nonmember_calls(masked[[line]], output_pattern)
    for (value in output_calls) {
      add_finding("output", line, paste0("call: ", value))
    }
    if (!length(output_calls)) {
      output_tokens <- regmatches(
        masked[[line]],
        gregexpr(
          "(?<![[:alnum:]_])(?:stdout|stderr)\\b",
          masked[[line]],
          perl = TRUE
        )
      )[[1L]]
      for (token in output_tokens) {
        add_finding("output", line, trimws(token))
      }
    }
    for (value in nonmember_calls(masked[[line]], format_pattern)) {
      add_finding("unsafe format", line, paste0("call: ", value))
    }

    traversal_exit <- identical(file, "Triangulation_segment_traverser_3.h") &&
      grepl(
        "^[[:space:]]*(?:void|std::tuple<Locate_type,[[:space:]]*int,[[:space:]]*int>)[[:space:]]+exit[[:space:]]*\\([^;]*\\)[[:space:]]*const[[:space:]]*$",
        masked[[line]],
        perl = TRUE
      )
    if (traversal_exit) {
      next
    }

    termination_macro <- paste0(
      "^[[:space:]]*#[[:space:]]*define\\b.*",
      "(?<![.>[:alnum:]_])(?:(?:std)?::)?(?:abort|exit|quick_exit|",
      "_Exit|_exit|terminate)\\b"
    )
    is_termination_macro <- grepl(
      termination_macro,
      masked[[line]],
      perl = TRUE
    )
    if (is_termination_macro) {
      add_finding(
        "termination",
        line,
        paste0("macro or alias: ", trimws(lines[[line]]))
      )
    }
    rng_macro <- paste0(
      "^[[:space:]]*#[[:space:]]*define\\b.*",
      "(?<![.>[:alnum:]_])(?:(?:std)?::)?(?:rand|srand|random|",
      "srandom|drandom48)\\b"
    )
    is_rng_macro <- grepl(rng_macro, masked[[line]], perl = TRUE)
    if (is_rng_macro) {
      add_finding(
        "rng",
        line,
        paste0("macro or alias: ", trimws(lines[[line]]))
      )
    }
    if (!is_termination_macro) {
      for (value in nonmember_calls(masked[[line]], termination_pattern)) {
        add_finding("termination", line, paste0("call: ", value))
      }
    }
    if (!is_rng_macro) {
      for (value in nonmember_calls(masked[[line]], rng_pattern)) {
        add_finding("rng", line, paste0("call: ", value))
      }
    }
  }
  findings
}

.validate_cgal_headers <- function(pkg_path = NULL, audit_path = NULL) {
  if (is.null(pkg_path)) {
    pkg_path <- dirname(system.file(".", package = "RcppCGAL"))
  }
  pkg_path <- normalizePath(pkg_path, mustWork = TRUE)
  dest_folder <- file.path(pkg_path, "include", "CGAL")
  if (!dir.exists(dest_folder)) {
    stop("CGAL include directory not found: ", dest_folder)
  }
  if (is.null(audit_path)) {
    audit_path <- file.path(pkg_path, "cgal-header-audit.csv")
  }

  message("\nValidating the final CGAL headers...\n")
  files <- list.files(
    dest_folder,
    pattern = "\\.(h|hh|hpp|hxx|ipp|tpp|cpp|cc|cxx)$",
    full.names = TRUE,
    recursive = TRUE,
    ignore.case = TRUE
  )
  findings <- unlist(
    lapply(files, function(path) {
      relative <- substring(path, nchar(dest_folder) + 2L)
      .cgal_header_findings(readLines(path, warn = FALSE), relative)
    }),
    recursive = FALSE
  )
  audit <- if (length(findings)) {
    do.call(rbind, findings)
  } else {
    data.frame(
      type = character(),
      file = character(),
      line = integer(),
      detail = character(),
      stringsAsFactors = FALSE
    )
  }
  utils::write.csv(audit, audit_path, row.names = FALSE, na = "")

  if (nrow(audit)) {
    message(sprintf("Found %d problematic occurrence(s):\n", nrow(audit)))
    for (kind in unique(audit$type)) {
      message(sprintf("%s (%d):", kind, sum(audit$type == kind)))
      print(
        audit[audit$type == kind, c("file", "line", "detail")],
        row.names = FALSE
      )
      message("")
    }
    message("\nFull audit written to: ", audit_path)
    stop("CGAL headers contain calls that require review.", call. = FALSE)
  }

  message("No problematic calls found. Audit written to: ", audit_path)
  invisible(audit_path)
}


.patch_cgal_headers_for_R <- function(pkg_path = NULL) {
  .patch_cgal_semantics(pkg_path)
  .rewrite_cgal_streams(pkg_path)
  .ensure_cgal_final_newlines(pkg_path)
  .validate_cgal_headers(pkg_path)
}
