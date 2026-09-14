#include <Rcpp.h>

// Core
#include <CGAL/basic.h>
#include <CGAL/Cartesian_d.h>
#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>

// Geometry
#include <CGAL/Point_2.h>
#include <CGAL/Point_3.h>
#include <CGAL/Segment_2.h>
#include <CGAL/Segment_3.h>
#include <CGAL/Triangle_2.h>
#include <CGAL/Triangle_3.h>
#include <CGAL/Polygon_2.h>

// Sorting
#include <CGAL/spatial_sort.h>
#include <CGAL/hilbert_sort.h>
#include <CGAL/Spatial_sort_traits_adapter_d.h>

// Hulls
#include <CGAL/convex_hull_2.h>
#include <CGAL/convex_hull_3.h>

// Triangulations
#include <CGAL/Triangulation_2.h>
#include <CGAL/Delaunay_triangulation_2.h>
#include <CGAL/Triangulation_3.h>
#include <CGAL/Delaunay_triangulation_3.h>

// Intersections
#include <CGAL/intersections.h>

// Misc
#include <CGAL/number_utils.h>
#include <CGAL/squared_distance_2.h>
#include <CGAL/squared_distance_3.h>

void rcppcgal_include_probe()
{
    // Intentionally empty.
    //
    // The purpose of this translation unit is to ensure that a broad set
    // of public CGAL headers can coexist and compile in an R package.
}