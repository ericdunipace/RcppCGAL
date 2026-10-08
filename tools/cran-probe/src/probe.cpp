#include <Rcpp.h>

// Core
#include <CGAL/basic.h>
#include <CGAL/Cartesian_d.h>
#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>

// Sorting
#include <CGAL/spatial_sort.h>
#include <CGAL/hilbert_sort.h>
#include <CGAL/Spatial_sort_traits_adapter_d.h>

// 2D geometry
#include <CGAL/Point_2.h>
#include <CGAL/Segment_2.h>
#include <CGAL/Triangle_2.h>

// Triangulation
#include <CGAL/Triangulation_2.h>
#include <CGAL/Delaunay_triangulation_2.h>

// Convex hull
#include <CGAL/convex_hull_2.h>

// Polygon
#include <CGAL/Polygon_2.h>

// -----------------------------------------------------------------------------
// d-dimensional sorting probe
// -----------------------------------------------------------------------------

using Kernel_d = CGAL::Cartesian_d<double>;
using Point_d = Kernel_d::Point_d;

void probe_hilbert_sort_d()
{
    std::vector<Point_d> points;

    const double x1[] = {0.0, 0.0};
    const double x2[] = {1.0, 1.0};
    const double x3[] = {0.5, 0.25};

    points.emplace_back(2, x1, x1 + 2);
    points.emplace_back(2, x2, x2 + 2);
    points.emplace_back(2, x3, x3 + 2);

    CGAL::hilbert_sort(points.begin(), points.end());
}

// -----------------------------------------------------------------------------
// Standard 2D kernel
// -----------------------------------------------------------------------------

using Kernel_2 =
    CGAL::Exact_predicates_inexact_constructions_kernel;

using Point_2 = Kernel_2::Point_2;
using Segment_2 = Kernel_2::Segment_2;

// -----------------------------------------------------------------------------
// Basic geometry probe
// -----------------------------------------------------------------------------

void probe_basic_geometry()
{
    Point_2 p(0.0, 0.0);
    Point_2 q(1.0, 1.0);

    Segment_2 segment(p, q);

    volatile double length =
        CGAL::to_double(segment.squared_length());

    (void) length;
}

// -----------------------------------------------------------------------------
// Delaunay triangulation probe
// -----------------------------------------------------------------------------

void probe_delaunay()
{
    CGAL::Delaunay_triangulation_2<Kernel_2> dt;

    dt.insert(Point_2(0.0, 0.0));
    dt.insert(Point_2(1.0, 0.0));
    dt.insert(Point_2(0.0, 1.0));
    dt.insert(Point_2(1.0, 1.0));

    volatile std::size_t n =
        dt.number_of_vertices();

    (void) n;
}

// -----------------------------------------------------------------------------
// Convex hull probe
// -----------------------------------------------------------------------------

void probe_convex_hull()
{
    std::vector<Point_2> points = {
        Point_2(0.0, 0.0),
        Point_2(1.0, 0.0),
        Point_2(1.0, 1.0),
        Point_2(0.0, 1.0),
        Point_2(0.5, 0.5)
    };

    std::vector<Point_2> hull;

    CGAL::convex_hull_2(
        points.begin(),
        points.end(),
        std::back_inserter(hull)
    );
}

// -----------------------------------------------------------------------------
// Polygon probe
// -----------------------------------------------------------------------------

void probe_polygon()
{
    CGAL::Polygon_2<Kernel_2> polygon;

    polygon.push_back(Point_2(0.0, 0.0));
    polygon.push_back(Point_2(1.0, 0.0));
    polygon.push_back(Point_2(1.0, 1.0));
    polygon.push_back(Point_2(0.0, 1.0));

    volatile bool simple = polygon.is_simple();

    (void) simple;
}

// -----------------------------------------------------------------------------
// Single entry point
// -----------------------------------------------------------------------------

// [[Rcpp::export]]
bool rcppcgal_probe()
{
    probe_hilbert_sort_d();
    probe_basic_geometry();
    probe_delaunay();
    probe_convex_hull();
    probe_polygon();

    return true;
}