cmake_minimum_required(VERSION 3.0)
project(pvfmm)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

set(MPI_CXX_SKIP_MPICXX true)
find_package(MPI REQUIRED)
include_directories(${MPI_INCLUDE_PATH})

find_package(OpenMP REQUIRED)

find_package(FFTW)
set(PVFMM_HAVE_FFTW ${FFTW_FOUND})

find_package(FFTWf)
set(PVFMM_HAVE_FFTWF ${FFTWF_FOUND})

if (ENABLE_CUDA)
  find_package(CUDA)
else()
  message(STATUS "CUDA support disabled")
  set(CUDA_FOUND NO)
endif()

if (CUDA_FOUND)
  set(PVFMM_HAVE_CUDA)
endif()

find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)

set(ALLTOALLV_FIX YES) # Simply does not build without
set(PVFMM_PRECOMP_DATA_PATH "\"\"")
configure_file("include/pvfmm_config.h.in" "${CMAKE_CURRENT_BINARY_DIR}/include/pvfmm_config.h" @ONLY)
include_directories("${CMAKE_CURRENT_BINARY_DIR}/include")

include_directories("include")
add_definitions("-std=c++11")

set(pvfmm_SOURCES
  src/cheb_utils.cpp
  src/device_wrapper.cpp
  src/legendre_rule.cpp
  src/math_utils.cpp
  src/mat_utils.cpp
  src/mem_mgr.cpp
  src/mortonid.cpp
  src/profile.cpp
  src/tree_node.cpp
  )

if (CUDA_FOUND)
  list(APPEND pvfmm_SOURCES src/fmm_pts_gpu.cu)
  cuda_add_library(pvfmm STATIC ${pvfmm_SOURCES})
else()
  add_library(pvfmm SHARED ${pvfmm_SOURCES})
  add_library(pvfmm_static STATIC ${pvfmm_SOURCES})
endif()

if (MPI_COMPILE_FLAGS)
  set_target_properties(pvfmm PROPERTIES COMPILE_FLAGS "${MPI_COMPILE_FLAGS}")
  set_target_properties(pvfmm_static PROPERTIES COMPILE_FLAGS "${MPI_COMPILE_FLAGS}")
endif()

if (OpenMP_CXX_FLAGS)
  set_target_properties(pvfmm PROPERTIES COMPILE_FLAGS "${OpenMP_CXX_FLAGS}")
  set_target_properties(pvfmm_static PROPERTIES COMPILE_FLAGS "${OpenMP_CXX_FLAGS}")
endif()

set_target_properties(pvfmm PROPERTIES PUBLIC_HEADER "\
${CMAKE_CURRENT_BINARY_DIR}/include/pvfmm_config.h;\
include/blas.h;\
include/cheb_node.hpp;\
include/cheb_node.txx;\
include/cheb_utils.hpp;\
include/cheb_utils.txx;\
include/device_wrapper.hpp;\
include/device_wrapper.txx;\
include/dtypes.h;\
include/fft_wrapper.hpp;\
include/fmm_cheb.hpp;\
include/fmm_cheb.txx;\
include/fmm_node.hpp;\
include/fmm_node.txx;\
include/fmm_pts_gpu.hpp;\
include/fmm_pts.hpp;\
include/fmm_pts.txx;\
include/fmm_tree.hpp;\
include/fmm_tree.txx;\
include/interac_list.hpp;\
include/interac_list.txx;\
include/intrin_wrapper.hpp;\
include/kernel.hpp;\
include/kernel.txx;\
include/lapack.h;\
include/legendre_rule.hpp;\
include/math_utils.hpp;\
include/matrix.hpp;\
include/matrix.txx;\
include/mat_utils.hpp;\
include/mat_utils.txx;\
include/mem_mgr.hpp;\
include/mem_mgr.txx;\
include/mortonid.hpp;\
include/mortonid.txx;\
include/mpi_node.hpp;\
include/mpi_node.txx;\
include/mpi_tree.hpp;\
include/mpi_tree.txx;\
include/ompUtils.h;\
include/ompUtils.txx;\
include/parUtils.h;\
include/parUtils.txx;\
include/precomp_mat.hpp;\
include/precomp_mat.txx;\
include/profile.hpp;\
include/pvfmm_common.hpp;\
include/pvfmm.h;\
include/pvfmm.hpp;\
include/pvfmm.txx;\
include/pvfmm.f90;\
include/stacktrace.h;\
include/tree.hpp;\
include/tree_node.hpp;\
include/tree.txx;\
include/vector.hpp;\
include/vector.txx")

# ========================================================== #

if (BUILD_TESTS)
  foreach(example example1 example2 # fmm_cheb fmm_pts
      )

	add_executable(${example} "examples/src/${example}.cpp")
	include_directories("examples/include")

	if (MPI_LINK_FLAGS)
	  set_target_properties(${example} PROPERTIES LINK_FLAGS "${MPI_LINK_FLAGS}")
	endif()

	if (OpenMP_CXX_FLAGS)
	  set_target_properties(${example} PROPERTIES COMPILE_FLAGS "${OpenMP_CXX_FLAGS}")
	  # sic!
	  set_target_properties(${example} PROPERTIES LINK_FLAGS "${OpenMP_CXX_FLAGS}")
	endif()

	target_link_libraries(${example} pvfmm ${MPI_LIBRARIES} ${BLAS_LIBRARIES} ${LAPACK_LIBRARIES})

	if (FFTW_FOUND)
	  target_link_libraries(${example} ${FFTW_LIBRARIES})
	endif()

	if (FFTWF_FOUND)
	  target_link_libraries(${example} ${FFTWF_LIBRARIES})
	endif()

	if (CUDA_FOUND)
	  target_link_libraries(${example} ${CUDA_CUDART_LIBRARY})
	endif()

  endforeach()
endif()

# ========================================================== #

install(TARGETS pvfmm pvfmm_static
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  PUBLIC_HEADER DESTINATION include
  )
