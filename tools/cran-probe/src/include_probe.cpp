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

// Optional polygon mesh processing and Eigen-based simplification
#include <CGAL/Polygon_mesh_processing/repair_polygon_soup.h>
#include <CGAL/Polyhedron_3.h>
#include <CGAL/boost/graph/graph_traits_Polyhedron_3.h>
#include <CGAL/boost/graph/properties_Polyhedron_3.h>
#include <CGAL/Surface_mesh.h>
#include <CGAL/Surface_mesh_simplification/Policies/Edge_collapse/GarlandHeckbert_plane_policies.h>

// Misc
#include <CGAL/number_utils.h>
#include <CGAL/squared_distance_2.h>
#include <CGAL/squared_distance_3.h>

// Not probed here: Polygon_mesh_processing/autorefinement.h. CGAL 6.2.1's
// constrained triangulations need boost/stl_interfaces, which BH 1.90.0-1
// does not ship, so that header cannot compile against BH at all.

void rcppcgal_include_probe()
{
    // Compile the actual short-polygon template paths, not just their header.
    using Kernel = CGAL::Exact_predicates_inexact_constructions_kernel;
    std::vector<Kernel::Point_3> points{Kernel::Point_3(0, 0, 0)};
    std::vector<std::size_t> empty_polygon;
    std::vector<std::size_t> singleton_polygon{0};
    bool reversed = true;
    auto empty = CGAL::Polygon_mesh_processing::internal::
        construct_canonical_polygon(points, empty_polygon, reversed, Kernel());
    auto singleton = CGAL::Polygon_mesh_processing::internal::
        construct_canonical_polygon(points, singleton_polygon, reversed, Kernel());
    (void) empty;
    (void) singleton;

    // Instantiate the Eigen-backed property-map initialization, on both a
    // Surface_mesh and a HalfedgeDS mesh (dynamic property overloads differ).
    using Mesh = CGAL::Surface_mesh<Kernel::Point_3>;
    Mesh mesh;
    CGAL::Surface_mesh_simplification::
        GarlandHeckbert_plane_policies<Mesh, Kernel> policy(mesh);
    (void) policy;

    using Polyhedron = CGAL::Polyhedron_3<Kernel>;
    Polyhedron polyhedron;
    CGAL::Surface_mesh_simplification::
        GarlandHeckbert_plane_policies<Polyhedron, Kernel> polyhedron_policy(polyhedron);
    (void) polyhedron_policy;
}