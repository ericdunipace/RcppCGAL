# Run from the package root with:
# Rscript -e 'testthat::test_file("tools/tests/test-semantic-patches.R")'

source_root <- testthat::test_path("..", "..")

source(
  file.path(source_root, "tools", "config", "semantic_patches.R"),
  local = TRUE
)
source(
  file.path(source_root, "tools", "config", "downloader_functions.R"),
  local = TRUE
)

write_fixture <- function(root, relative, lines) {
  path <- file.path(root, relative)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(lines, path)
}

assertion_fixture <- function() {
  exceptions <- c(
    "Assertion_exception",
    "Precondition_exception",
    "Postcondition_exception",
    "Warning_exception"
  )
  functions <- c("assertion", "precondition", "postcondition", "warning")
  bodies <- unlist(
    Map(
      function(kind, exception) {
        c(
          sprintf(
            "void %s_fail(const char* expr, const char* file, int line, const char* msg)",
            kind
          ),
          "{",
          "  switch (0) {",
          "  case ABORT: std::abort();",
          "  case EXIT: std::exit(1);",
          "  case EXIT_WITH_SUCCESS: std::exit(0);",
          sprintf(
            "  default: throw %s(\"CGAL\", expr, file, line, msg);",
            exception
          ),
          "  }",
          "}"
        )
      },
      functions,
      exceptions
    ),
    use.names = FALSE
  )
  declarations <- unlist(
    lapply(exceptions, function(exception) {
      sprintf(
        "struct %s { %s(const char*, const char*, const char*, int, const char*) {} };",
        exception,
        exception
      )
    }),
    use.names = FALSE
  )
  c(
    "#include <cstdlib>",
    "namespace CGAL {",
    "enum { ABORT, EXIT, EXIT_WITH_SUCCESS };",
    declarations,
    bodies,
    "}"
  )
}

cone_fixture <- function() {
  c(
    "namespace CGAL {",
    "void first(unsigned cone_number) {",
    "  if (cone_number < 2) {",
    "    CGAL_assertion(false);",
    "  }",
    "}",
    "void second(unsigned cone_number) {",
    "  if (cone_number<2) {",
    "    std::exit(1);",
    "  }",
    "}",
    "}"
  )
}

ogl_fixture <- function() {
  c(
    "#define CGAL_GLU_TESS_CALLBACK",
    "using GLenum = unsigned int;",
    "struct GLUtesselator {};",
    "inline GLUtesselator* gluNewTess() { return nullptr; }",
    "inline void gluDeleteTess(GLUtesselator*) {}",
    "namespace CGAL {",
    "inline void CGAL_GLU_TESS_CALLBACK errorCallback(GLenum errorCode)",
    "{",
    "  std::exit(0);",
    "}",
    "void draw() {",
    "  GLUtesselator* tess_ = gluNewTess();",
    "  gluDeleteTess(tess_);",
    "}",
    "}"
  )
}

expected_fixture <- function() {
  c(
    "#ifdef CGAL_TL_EXPECTED_EXCEPTIONS_ENABLED",
    "#define CGAL_TL_EXPECTED_THROW_EXCEPTION(e) throw((e));",
    "#else",
    "#define CGAL_TL_EXPECTED_THROW_EXCEPTION(e) std::terminate();",
    "#endif"
  )
}

iris_fixture <- function() {
  c(
    "int readIrisImage() {",
    "  if (!pic824) exit(-1);",
    "  if (!pic824)",
    "    exit(1);",
    "}",
    "byte *getimagedata() {",
    "  if (!starttab || !lengthtab || !rledat)",
    "    exit(1);",
    "  if (!base)",
    "    exit(1);",
    "  if (!base || !verdat)",
    "    exit(1);",
    "}"
  )
}

vertex_conflict_fixture <- function() {
  c(
    "namespace CGAL {",
    "void check() {",
    "  if (s != s_alt) {",
    "    CGAL_assertion(s == s_alt);",
    "    exit(1);",
    "  }",
    "}",
    "}"
  )
}

rng_fixtures <- function() {
  list(
    "Arr_point_location/Trapezoidal_decomposition_2.h" = c(
      "bool needs_update() {",
      "  unsigned long num_of_cv = number_of_curves();",
      "  if (static_cast<unsigned long>(std::rand()) >",
      "      RAND_MAX / ( num_of_cv + 1)) return false;",
      "}"
    ),
    "Classification/Sum_of_weighted_features_classifier.h" = c(
      "void train() {",
      "  std::size_t j = rand() % feature_train.size();",
      "  float weight = rand() / float(RAND_MAX);",
      "}"
    ),
    "Curved_kernel_via_analysis_2/gfx/Curve_renderer_internals.h" = c(
      "double x = static_cast<double>(rand()) / RAND_MAX;",
      "double y = static_cast<double>(rand()) / RAND_MAX;"
    ),
    "Point_set_3.h" = paste0(
      "std::ptrdiff_t p = current.first + (rand() % ",
      "(current.second - current.first));"
    ),
    "Polygonal_schema.h" = paste0(
      "if (static_cast<std::size_t>(rand()%100)<percentage_of_perforated) {}"
    ),
    "scanline_orient_normals.h" = paste0(
      "if (rand() % 1000 == 0 && std::distance(begin, end) > 10) {}"
    ),
    "Qt/quaternion_impl.h" = c(
      "qreal seed = rand() / (qreal)RAND_MAX;",
      "qreal t1 = rand() / (qreal)RAND_MAX;",
      "qreal t2 = rand() / (qreal)RAND_MAX;"
    ),
    "Variational_shape_approximation.h" = c(
      "std::size_t r = static_cast<std::size_t>(",
      "  static_cast<double>(std::rand()) / static_cast<double>(RAND_MAX) *",
      "  static_cast<double>(nb_nsf - 1));"
    )
  )
}

imageio_stdout_fixture <- function() {
  c(
    "void _openWriteImage(_image* im, const char *name)",
    "{",
    "  im->openMode = OM_CLOSE;",
    "  if( name == nullptr || name[0] == '\\0'",
    "      || (name[0] == '-' && name[1] == '\\0')",
    "      || (name[0] == '>' && name[1] == '\\0') ) {",
    "#ifdef CGAL_USE_ZLIB",
    "    im->fd = gzdopen(fileno(stdout), \"wb\");",
    "#else",
    "    im->fd = (_ImageIO_file) stdout;",
    "#endif",
    "    im->openMode = OM_STD;",
    "  }",
    "  else { im->fd = open_file(name); }",
    "}"
  )
}

color_output_fixture <- function() {
  c(
    "static bool detect_color_support(streambuf_type* buf) {",
    "  if(safe_getenv(\"NO_COLOR\").value_or(\"\").size() > 0) return false;",
    "  if(safe_getenv(\"CLICOLOR_FORCE\").value_or(\"\").size() > 0) return true;",
    "  if(buf == std::cout.rdbuf() || buf == std::clog.rdbuf()) {",
    "    int fd = CGAL_FILENO(stdout);",
    "  } else if(buf == std::cerr.rdbuf()) {",
    "    int fd = CGAL_FILENO(stderr);",
    "  } else { return false; }",
    "  return true;",
    "}"
  )
}

write_semantic_fixtures <- function(root) {
  write_fixture(root, "assertions_impl.h", assertion_fixture())
  write_fixture(root, "Compute_cone_boundaries_2.h", cone_fixture())
  write_fixture(root, "Nef_3/OGL_helper.h", ogl_fixture())
  write_fixture(root, "expected.h", expected_fixture())
  write_fixture(root, "ImageIO/Attic/iris_impl.h", iris_fixture())
  write_fixture(
    root,
    "Segment_Delaunay_graph_2/Vertex_conflict_C2.h",
    vertex_conflict_fixture()
  )
  fixtures <- rng_fixtures()
  for (relative in names(fixtures)) {
    write_fixture(root, relative, fixtures[[relative]])
  }
  write_fixture(root, "ImageIO_impl.h", imageio_stdout_fixture())
  write_fixture(
    root,
    "ImageIO/Attic/pnm_impl.h",
    c(
      "fprintf(stderr, \"writeInrimage: error: unable to open file '%s'\\n\", name );",
      "fprintf(stderr, \"writePgmImage: error: unable to open file '%s'\\n\", name );"
    )
  )
  write_fixture(
    root,
    "ImageIO/inr_impl.h",
    "fprintf(stderr, \"writeInrimage: error: unable to open file '%s'\\n\", name );"
  )
  write_fixture(root, "IO/Color_ostream.h", color_output_fixture())
}

testthat::test_that("final validation ignores comments, literals, and member calls", {
  findings <- .cgal_header_findings(
    c(
      "// std::exit(1)",
      "/* abort();",
      "   std::terminate(); */",
      "const char* note = \"std::abort()\";",
      "const char* raw = R\"tag(std::terminate())tag\";",
      "object.exit();",
      "pointer->exit();",
      "object . exit();",
      "pointer -> exit();",
      "std::exit ( 1 );"
    ),
    "fixture.h"
  )
  expect_length(findings, 1L)
  expect_match(findings[[1L]]$detail, "std::exit")
  expect_equal(findings[[1L]]$line, 10L)
})

testthat::test_that("final validation reports unqualified calls and termination aliases", {
  findings <- .cgal_header_findings(
    c(
      "void fatal() { abort(); }",
      "#define CGAL_DIE std::quick_exit"
    ),
    "fixture.h"
  )
  testthat::expect_length(findings, 2L)
  testthat::expect_match(findings[[1L]]$detail, "abort")
  testthat::expect_match(findings[[2L]]$detail, "macro or alias")
})

testthat::test_that("final validation separates CRAN problem types", {
  findings <- .cgal_header_findings(
    c(
      "std::clog << message;",
      "fprintf(stderr, format, value);",
      "sprintf(buffer, format, value);",
      "std::rand();",
      "#undef NDEBUG"
    ),
    "fixture.h"
  )
  audit <- do.call(rbind, findings)
  testthat::expect_true(all(
    c(
      "output",
      "unsafe format",
      "rng",
      "assertion configuration"
    ) %in%
      audit$type
  ))
})

testthat::test_that("validation leaves ordinary file output alone", {
  findings <- .cgal_header_findings(
    c(
      "fprintf(file, \"value: %d\\n\", value);",
      "fwrite(data, 1, size, file);",
      "fread(data, 1, size, file);"
    ),
    "fixture.h"
  )
  testthat::expect_length(findings, 0L)
})

testthat::test_that("RNG scanning ignores CGAL objects and callable parameters", {
  findings <- .cgal_header_findings(
    c(
      "CGAL::Random random(seed);",
      "CGAL::Random rand(static_cast<unsigned int>(idx));",
      "RandomGenerator& random = generator;",
      "random(last - first);",
      "object.rand();",
      "pointer->random();",
      "rand();",
      "random();"
    ),
    "fixture.h"
  )
  audit <- do.call(rbind, findings)
  testthat::expect_equal(nrow(audit), 2L)
  testthat::expect_true(all(audit$type == "rng"))
  testthat::expect_equal(audit$line, c(7L, 8L))
})

test_that("RNG helpers follow R's seed and enforce valid ranges", {
  include <- normalizePath(
    testthat::test_path("..", "..", "inst", "include"),
    mustWork = TRUE
  )
  old_flags <- Sys.getenv("PKG_CPPFLAGS", unset = NA_character_)
  on.exit(
    {
      if (is.na(old_flags)) {
        Sys.unsetenv("PKG_CPPFLAGS")
      } else {
        Sys.setenv(PKG_CPPFLAGS = old_flags)
      }
    },
    add = TRUE
  )
  Sys.setenv(
    PKG_CPPFLAGS = paste(
      Sys.getenv("PKG_CPPFLAGS"),
      paste0("-I", shQuote(include))
    )
  )

  environment <- new.env(parent = globalenv())
  Rcpp::sourceCpp(
    code = paste(
      "// [[Rcpp::plugins(cpp17)]]",
      "#include <RcppCGAL/compat.h>",
      "// [[Rcpp::export]]",
      "Rcpp::NumericVector cgal_rng_probe() {",
      "  return Rcpp::NumericVector::create(",
      "    RcppCGAL::RCGAL_unif_rand(),",
      "    static_cast<double>(RcppCGAL::RCGAL_unif_index(7))",
      "  );",
      "}",
      "// [[Rcpp::export]]",
      "void cgal_empty_rng_probe() { RcppCGAL::RCGAL_unif_index(0); }",
      sep = "\n"
    ),
    env = environment,
    verbose = FALSE
  )

  set.seed(42)
  seed_before <- .Random.seed
  first <- environment$cgal_rng_probe()
  seed_after <- .Random.seed
  set.seed(42)
  second <- environment$cgal_rng_probe()
  expect_identical(first, second)
  expect_true(first[[1L]] >= 0 && first[[1L]] < 1)
  expect_true(first[[2L]] >= 0 && first[[2L]] < 7)
  expect_false(identical(seed_before, seed_after))
  expect_error(environment$cgal_empty_rng_probe(), "empty range")
})

test_that("NDEBUG compiles ordinary assertions out", {
  compiler <- Sys.which("c++")
  skip_if(!nzchar(compiler), "No C++ compiler available")
  probe <- tempfile(fileext = ".cpp")
  writeLines(
    c(
      "#include <cassert>",
      "int assertion_probe() { assert(false); return 1; }"
    ),
    probe
  )
  output <- system2(compiler, c("-DNDEBUG", "-E", probe), stdout = TRUE)
  expect_false(any(grepl("assert(false)", output, fixed = TRUE)))
})

test_that("final validation ignores traverser member functions named exit", {
  findings <- .cgal_header_findings(
    c(
      "void exit(Locate_type& lt, int& li, int& lj) const",
      "std::tuple<Locate_type, int, int> exit() const"
    ),
    "Triangulation_segment_traverser_3.h"
  )
  expect_length(findings, 0L)
})

test_that("each reviewed patch makes its explicit semantic change", {
  assertion <- .cgal_patch_assertions(assertion_fixture(), "assertions_impl.h")
  expect_equal(sum(grepl("throw Assertion_exception", assertion)), 4L)
  expect_equal(sum(grepl("throw Precondition_exception", assertion)), 4L)
  expect_equal(sum(grepl("throw Postcondition_exception", assertion)), 4L)
  expect_equal(sum(grepl("throw Warning_exception", assertion)), 4L)

  cones <- .cgal_patch_cones(cone_fixture(), "Compute_cone_boundaries_2.h")
  expect_equal(sum(grepl("std::invalid_argument", cones)), 2L)
  expect_equal(sum(grepl("#include <stdexcept>", cones, fixed = TRUE)), 1L)

  ogl <- .cgal_patch_ogl(ogl_fixture(), "OGL_helper.h")
  throw_line <- which(grepl("throw std::runtime_error", ogl))
  delete_line <- tail(which(grepl("gluDeleteTess", ogl)), 1L)
  expect_equal(
    sum(grepl("thread_local GLenum cgal_glu_tessellation_error", ogl)),
    1L
  )
  expect_gt(throw_line, delete_line)
  expect_equal(sum(grepl("#include <stdexcept>", ogl, fixed = TRUE)), 1L)

  expected <- .cgal_patch_expected(expected_fixture(), "expected.h")
  expect_false(any(grepl("std::terminate", expected, fixed = TRUE)))
  expect_equal(sum(grepl("throw((e))", expected, fixed = TRUE)), 2L)

  iris <- .cgal_patch_iris(iris_fixture(), "iris_impl.h")
  expect_false(any(grepl("exit(", iris, fixed = TRUE)))
  expect_equal(sum(grepl("return 0;", iris, fixed = TRUE)), 2L)
  expect_equal(sum(grepl("return (byte *) nullptr;", iris, fixed = TRUE)), 3L)

  vertex <- .cgal_patch_vertex_conflict(
    vertex_conflict_fixture(),
    "Vertex_conflict_C2.h"
  )
  expect_true(any(grepl("throw std::logic_error", vertex, fixed = TRUE)))
  expect_equal(sum(grepl("#include <stdexcept>", vertex, fixed = TRUE)), 1L)

  fixtures <- rng_fixtures()
  patchers <- c(
    "Arr_point_location/Trapezoidal_decomposition_2.h" = ".cgal_patch_rng_trapezoid",
    "Classification/Sum_of_weighted_features_classifier.h" = ".cgal_patch_rng_classifier",
    "Curved_kernel_via_analysis_2/gfx/Curve_renderer_internals.h" = ".cgal_patch_rng_curve_renderer",
    "Point_set_3.h" = ".cgal_patch_rng_point_set",
    "Polygonal_schema.h" = ".cgal_patch_rng_polygonal_schema",
    "scanline_orient_normals.h" = ".cgal_patch_rng_scanlines",
    "Qt/quaternion_impl.h" = ".cgal_patch_rng_quaternion",
    "Variational_shape_approximation.h" = ".cgal_patch_rng_variational"
  )
  for (relative in names(fixtures)) {
    patched <- get(patchers[[relative]])(fixtures[[relative]], relative)
    expect_true("#include <RcppCGAL/compat.h>" %in% patched)
    expect_true(any(grepl("RcppCGAL::RCGAL_unif_", patched, fixed = TRUE)))
    expect_false(any(grepl("std::rand()", patched, fixed = TRUE)))
  }

  imageio <- .cgal_patch_imageio_stdout(
    imageio_stdout_fixture(),
    "ImageIO_impl.h"
  )
  expect_true(any(grepl("cannot write binary data", imageio, fixed = TRUE)))
  expect_false(any(grepl("fileno(stdout)", imageio, fixed = TRUE)))
  expect_false(any(grepl("(_ImageIO_file) stdout", imageio, fixed = TRUE)))

  pnm <- .cgal_patch_imageio_writer_errors(
    c(
      "fprintf(stderr, \"writeInrimage: error: unable to open file '%s'\\n\", name );",
      "fprintf(stderr, \"writePgmImage: error: unable to open file '%s'\\n\", name );"
    ),
    "ImageIO/Attic/pnm_impl.h"
  )
  expect_equal(sum(grepl("name ? name", pnm, fixed = TRUE)), 2L)

  color <- .cgal_patch_color_output(
    color_output_fixture(),
    "IO/Color_ostream.h"
  )
  expect_true(any(grepl("NO_COLOR", color, fixed = TRUE)))
  expect_true(any(grepl("CLICOLOR_FORCE", color, fixed = TRUE)))
  expect_false(any(grepl("CGAL_FILENO", color, fixed = TRUE)))
  expect_true(any(grepl("return false", color, fixed = TRUE)))
})

test_that("recognized semantic patches compile as C++11 exceptions", {
  compiler <- Sys.which("c++")
  skip_if(!nzchar(compiler), "No C++ compiler available")
  root <- tempfile("cgal-semantic-compile-")
  dir.create(root)
  write_semantic_fixtures(root)
  .patch_cgal_headers(root)
  probe <- file.path(root, "probe.cpp")
  writeLines(
    c(
      "#include \"assertions_impl.h\"",
      "#include \"Compute_cone_boundaries_2.h\"",
      "#include \"Nef_3/OGL_helper.h\"",
      "int main() { return 0; }"
    ),
    probe
  )
  expect_equal(system2(compiler, c("-std=c++11", "-fsyntax-only", probe)), 0L)
})

test_that("the patch stage only changes the reviewed headers", {
  root <- tempfile("cgal-semantic-")
  dir.create(root)
  write_semantic_fixtures(root)
  write_fixture(root, "unrelated.h", "void leave_me_alone() {}")

  changed <- .patch_cgal_headers(root)
  expect_length(changed, 18L)
  expect_true(any(grepl(
    "throw Assertion_exception",
    readLines(file.path(root, "assertions_impl.h"))
  )))
  expect_identical(
    readLines(file.path(root, "unrelated.h")),
    "void leave_me_alone() {}"
  )
})

test_that("unknown calls do not block patches but fail final validation", {
  pkg <- tempfile("cgal-semantic-")
  root <- file.path(pkg, "include", "CGAL")
  dir.create(root, recursive = TRUE)
  write_semantic_fixtures(root)
  write_fixture(
    root,
    "new_failure.h",
    c(
      "#define CGAL_DIE std::quick_exit",
      "void fatal() { std::quick_exit(2); }"
    )
  )
  .patch_cgal_headers(root)
  .rewrite_cgal_streams(pkg)
  expect_true(any(grepl(
    "throw Assertion_exception",
    readLines(file.path(root, "assertions_impl.h"))
  )))

  audit_path <- file.path(pkg, "audit.csv")
  expect_error(.validate_cgal_headers(pkg, audit_path), "require review")
  audit <- utils::read.csv(audit_path, stringsAsFactors = FALSE)
  expect_true(any(audit$type == "termination"))
  expect_true(any(grepl("quick_exit", audit$detail)))
})

test_that("changed or duplicated anchors fail before mutation", {
  root <- tempfile("cgal-semantic-")
  dir.create(root)
  write_semantic_fixtures(root)
  path <- file.path(root, "assertions_impl.h")
  changed <- c(readLines(path), "void assertion_fail();")
  writeLines(changed, path)

  expect_error(.patch_cgal_headers(root), "expected 1 assertion_fail function")
  expect_identical(readLines(path), changed)
})

test_that("a changed RNG anchor prevents every staged write", {
  root <- tempfile("cgal-semantic-")
  dir.create(root)
  write_semantic_fixtures(root)
  assertion_path <- file.path(root, "assertions_impl.h")
  assertion_before <- readLines(assertion_path)
  rng_path <- file.path(root, "Variational_shape_approximation.h")
  rng_changed <- sub("std::rand", "upstream_random", readLines(rng_path))
  writeLines(rng_changed, rng_path)

  expect_error(.patch_cgal_headers(root), "variational face selection")
  expect_identical(readLines(assertion_path), assertion_before)
  expect_identical(readLines(rng_path), rng_changed)
})

test_that("Rcpp-modified headers are rejected before mutation", {
  root <- tempfile("cgal-semantic-")
  dir.create(root)
  write_semantic_fixtures(root)
  write_fixture(root, "assertions_impl.h", "// Rcpp::stop")
  expect_error(.patch_cgal_headers(root), "pristine CGAL headers")
})

test_that("the package-path wrapper accepts inst", {
  pkg <- tempfile("cgal-semantic-wrapper-")
  root <- file.path(pkg, "inst", "include", "CGAL")
  dir.create(root, recursive = TRUE)
  write_semantic_fixtures(root)

  .patch_cgal_semantics(file.path(pkg, "inst"))
  expect_true(any(grepl(
    "throw Assertion_exception",
    readLines(file.path(root, "assertions_impl.h"))
  )))
})

test_that("stream rewriting is defined once and only changes matching files", {
  pkg <- tempfile("cgal-streams-")
  root <- file.path(pkg, "include", "CGAL")
  dir.create(root, recursive = TRUE)
  write_fixture(
    root,
    "output.h",
    c(
      "void f() { std::cout << 1; std::cerr << 2; std::clog << 3; }",
      "void a() { printf(\"value: %d\\n\", 1); }",
      "void b() { std::printf (\"value: %d\\n\", 2); }",
      "void c() { fprintf(stderr, \"error: %s\\n\", message); }",
      "void d() { fprintf ( stdout , \"value: %d\\n\", 3); }",
      "void e() { fprintf(file, \"value: %d\\n\", 4); }",
      "// printf(\"leave comment alone\");",
      "const char* text = \"fprintf(stderr, leave string alone)\";",
      "const char* raw = R\"tag(printf(leave raw string alone))tag\";"
    )
  )
  write_fixture(root, "quiet.h", "void quiet() {}")

  .rewrite_cgal_streams(pkg)
  output <- readLines(file.path(root, "output.h"))
  expect_equal(
    sum(grepl("#include <RcppCGAL/compat.h>", output, fixed = TRUE)),
    1L
  )
  expect_true(any(grepl("Rcpp::Rcout", output, fixed = TRUE)))
  expect_true(any(grepl("Rcpp::Rcerr", output, fixed = TRUE)))
  expect_false(any(grepl("std::clog", output, fixed = TRUE)))
  expect_equal(sum(grepl("Rprintf", output, fixed = TRUE)), 3L)
  expect_equal(sum(grepl("REprintf", output, fixed = TRUE)), 1L)
  expect_true(any(grepl("fprintf(file", output, fixed = TRUE)))
  expect_true(any(grepl("leave comment alone", output, fixed = TRUE)))
  expect_true(any(grepl("fprintf(stderr, leave string", output, fixed = TRUE)))
  expect_true(any(grepl("printf(leave raw string", output, fixed = TRUE)))
  expect_identical(readLines(file.path(root, "quiet.h")), "void quiet() {}")
})

test_that("successful final validation writes an empty CSV audit", {
  pkg <- tempfile("cgal-semantic-validation-")
  root <- file.path(pkg, "include", "CGAL")
  dir.create(root, recursive = TRUE)
  write_semantic_fixtures(root)
  .patch_cgal_headers(root)
  .rewrite_cgal_streams(pkg)

  audit_path <- .validate_cgal_headers(pkg)
  audit <- utils::read.csv(audit_path, stringsAsFactors = FALSE)
  expect_named(audit, c("type", "file", "line", "detail"))
  expect_equal(nrow(audit), 0L)
})

test_that("the maintainer command patches the requested CGAL root", {
  root <- tempfile("cgal-semantic-cli-")
  dir.create(root)
  write_semantic_fixtures(root)
  script <- testthat::test_path("..", "..", "tools", "patch_cgal_semantics.R")

  output <- system2(
    file.path(R.home("bin"), "Rscript"),
    c(shQuote(script), shQuote(root)),
    stdout = TRUE,
    stderr = TRUE
  )
  status <- attr(output, "status")
  expect_true(is.null(status) || status == 0L)
  expect_true(any(grepl(
    "throw Assertion_exception",
    readLines(file.path(root, "assertions_impl.h"))
  )))
})
