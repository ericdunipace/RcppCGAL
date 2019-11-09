// Copyright (c) 2003,2004  INRIA Sophia-Antipolis (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/releases/CGAL-5.0/Apollonius_graph_2/include/CGAL/Parabola_segment_2.h $
// $Id: Parabola_segment_2.h 144f3a1 2019-10-29T15:23:33+01:00 Laurent Rineau
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
// 
//
// Author(s)     : Menelaos Karavelas <mkaravel@iacm.forth.gr>



#ifndef CGAL_PARABOLA_SEGMENT_2_H
#define CGAL_PARABOLA_SEGMENT_2_H

#include <CGAL/license/Apollonius_graph_2.h>


#include <CGAL/Parabola_2.h>

namespace CGAL {

namespace Qt {
  template <typename K> class PainterOstream;
}

template < class Gt >
class Parabola_segment_2 : public Parabola_2< Gt >
{
  typedef CGAL::Parabola_2<Gt>            Base;
  typedef typename Base::Site_2           Site_2;
  typedef typename Base::FT               FT;
  typedef typename Base::Point_2          Point_2;
  typedef typename Base::Segment_2        Segment_2;
  typedef typename Base::Line_2           Line_2;

  using Base::t;
  using Base::f;

protected:
  Point_2 p1, p2;

public:
  Parabola_segment_2() : Parabola_2< Gt >() {}

  template<class ApolloniusSite>
  Parabola_segment_2(const ApolloniusSite &p, const Line_2 &l,
		     const Point_2 &p1, const Point_2 &p2)
    : Parabola_2< Gt >(p, l)
  {
    this->p1 = p1;
    this->p2 = p2;
  }

  Parabola_segment_2(const Point_2 &p, const Line_2 &l,
		     const Point_2 &p1, const Point_2 &p2)
    : Parabola_2< Gt >(p, l)
  {
    this->p1 = p1;
    this->p2 = p2;
  }

  int compute_k(const FT& tt) const {
    return int(CGAL::sqrt(CGAL::to_double(tt) / 2));
  }

  void generate_points(std::vector<Point_2>& p,
                       const FT STEP = FT(2)) const
  {
    FT s0, s1;

    s0 = t(p1);
    s1 = t(p2);

    if (CGAL::compare(s0, s1) == LARGER) {
      std::swap(s0, s1);
    }

    p.clear();

    if ( !(CGAL::is_positive(s0)) &&
	 !(CGAL::is_negative(s1)) ) {
      FT tt;
      int k;

      p.push_back( this->o );
      k = -1;

      tt = - STEP;
      while ( CGAL::compare(tt, s0) == LARGER ) {
	p.insert( p.begin(), f(tt) );
	k--;
	tt = -FT(k * k) * STEP;
      }
      p.insert( p.begin(), f(s0) );

      k = 1;
      tt = STEP;
      while ( CGAL::compare(tt, s1) == SMALLER ) {
	p.push_back( f(tt) );
	k++;
	tt = FT(k * k) * STEP;
      }
      p.push_back( f(s1) );
    } else if ( !(CGAL::is_negative(s0)) &&
		!(CGAL::is_negative(s1)) ) {
      FT tt;
      int k;


      p.push_back( f(s0) );

      tt = s0;
      k = compute_k(tt);

      while ( CGAL::compare(tt, s1) == SMALLER ) {
	if ( CGAL::compare(tt, s0) != SMALLER )
	  p.push_back( f(tt) );
	k++;
	tt = FT(k * k) * STEP;
      }
      p.push_back( f(s1) );
    } else {
      FT tt;
      int k;

      p.push_back( f(s1) );

      tt = s1;
      k = -compute_k(-tt);

      while ( CGAL::compare(tt, s0) == LARGER ) {
	if ( CGAL::compare(tt, s1) != LARGER )
	  p.push_back( f(tt) );
	k--;
	tt = -FT(k * k) * STEP;
      }
      p.push_back( f(s0) );
    }
  }


  template< class Stream >
  void draw(Stream& W) const
  {
    std::vector< Point_2 > p;
    generate_points(p);

    for (unsigned int i = 0; i < p.size() - 1; i++) {
      W << Segment_2(p[i], p[i+1]);
    }
  }

  template< class K >
  void draw(CGAL::Qt::PainterOstream<K>& stream) const {
    stream.draw_parabola_segment(this->center(), this->line(), p1, p2);
  }
};



template< class Stream, class Gt >
inline
Stream& operator<<(Stream &s, const Parabola_segment_2<Gt> &P)
{
  P.draw(s);
  return s;
}

} //namespace CGAL

#endif // CGAL_PARABOLA_SEGMENT_2_H
