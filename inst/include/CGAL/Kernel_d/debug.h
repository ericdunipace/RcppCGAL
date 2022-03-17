#include <Rcpp.h>
// Copyright (c) 1997-2000
// Utrecht University (The Netherlands),
// ETH Zurich (Switzerland),
// INRIA Sophia-Antipolis (France),
// Max-Planck-Institute Saarbruecken (Germany),
// and Tel-Aviv University (Israel).  All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.4/Kernel_d/include/CGAL/Kernel_d/debug.h $
// $Id: debug.h 0779373 2020-03-26T13:31:46+01:00 Sébastien Loriot
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Michael Seel <seel@mpi-sb.mpg.de>
//
#ifndef CGAL_KERNEL_D_DEBUG_H
#define CGAL_KERNEL_D_DEBUG_H

#include <iostream>
#include <string>
#include <sstream>

#undef CGAL_KD_TRACE
#undef CGAL_KD_TRACEN
#undef CGAL_KD_TRACEV
#undef CGAL_KD_CTRACE
#undef CGAL_KD_CTRACEN
#undef CGAL_KD_ASSERT

#if CGAL_KD_DEBUG>0
namespace CGAL {
namespace Kernel_d_internal {
static int debugthread=3141592;
} // Kernel_d_internal
} // CGAL
#endif

#if CGAL_KD_DEBUG>0
#define CGAL_KD_SETDTHREAD(l) CGAL::Kernel_d_internal::debugthread=l
#else
#define CGAL_KD_SETDTHREAD(l)
#endif

#if CGAL_KD_DEBUG>0
#define CGAL_KD_TRACE(t)   if((CGAL::Kernel_d_internal::debugthread%CGAL_KD_DEBUG)==0)\
 Rcpp::Rcerr<<" "<<t;Rcpp::Rcerr.flush()
#else
#define CGAL_KD_TRACE(t)
#endif

#if CGAL_KD_DEBUG>0
#define CGAL_KD_TRACEV(t)  if((CGAL::Kernel_d_internal::debugthread%CGAL_KD_DEBUG)==0)\
 Rcpp::Rcerr<<" "<<#t<<" = "<<(t)<<std::endl;Rcpp::Rcerr.flush()
#else
#define CGAL_KD_TRACEV(t)
#endif

#if CGAL_KD_DEBUG>0
#define CGAL_KD_TRACEN(t)  if((CGAL::Kernel_d_internal::debugthread%CGAL_KD_DEBUG)==0)\
 Rcpp::Rcerr<<" "<<t<<std::endl;Rcpp::Rcerr.flush()
#else
#define CGAL_KD_TRACEN(t)
#endif

#if CGAL_KD_DEBUG>0
#define CGAL_KD_CTRACE(b,t)  if(b) Rcpp::Rcerr << " " << t; else Rcpp::Rcerr << " 0"
#else
#define CGAL_KD_CTRACE(b,t)
#endif

#if CGAL_KD_DEBUG>0
#define CGAL_KD_CTRACEN(b,t)  if(b) Rcpp::Rcerr<< " " <<t<<"\n"; else Rcpp::Rcerr<<" 0\n"
#else
#define CGAL_KD_CTRACEN(b,t)
#endif

#ifndef CGAL_KD__ASSERT
#define  CGAL_KD_ASSERT(cond,fstr)
#else
#define CGAL_KD_ASSERT(cond,fstr)   \
  if (!(cond)) {       \
    Rcpp::Rcerr << "   ASSERT:   " << #fstr << std::endl; \
    Rcpp::Rcerr << "   COND:     " << #cond << std::endl; \
    Rcpp::Rcerr << "   POSITION: " << __FILE__ << " at line "<< __LINE__ \
              << std::endl; \
    CGAL_error(); \
  }
#endif

#endif //CGAL_KERNEL_D_DEBUG_H
