cmake_minimum_required(VERSION 2.8.7)
if(POLICY CMP0046)
  # cmake_policy(SET CMP0046 NEW)
endif()
if(POLICY CMP0054)
  # cmake_policy(SET CMP0054 NEW)
endif()

# ---[ Project name
project(CPP_Skeleton)

# ---[ CTest
include(CTest)

add_definitions(-DMYPROJ_VERSION="0.0.1")

# --[ Output directory
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# ---[ Using cmake scripts and modules
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)

set(THIRD_PARTY_DIR ${CMAKE_SOURCE_DIR}/third_party)

include(ExternalProject)
include(cmake/CompilerInfo.cmake)
include(cmake/Utils.cmake)
include(cmake/Summary.cmake)

include(cmake/Dependencies.cmake)


# ---[ Options
beeri_option(BUILD_docs   "Build documentation" ON IF UNIX OR APPLE)

# ---[ C++11 Flags
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++1y" COMPILER_SUPPORTS_CXX1Y)

if(COMPILER_SUPPORTS_CXX1Y)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++1y")
else()
    message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++1Y support. Please use a different C++ compiler.")
endif()

# ---[ Color diagnostics

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fcolor-diagnostics")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fcolor-diagnostics")
endif()

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" AND 
  (CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 4.9 OR CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 4.9))
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fdiagnostics-color=auto")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fdiagnostics-color=auto")
endif()

# -- [ Debug Flags
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0 -ggdb")


set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -Wall -Wextra -Werror -mcx16")

include_directories(${PROJECT_SOURCE_DIR})

add_subdirectory(base)

if (False)
include(cmake/ConfigGen.cmake)

include(cmake/Targets.cmake)
include(cmake/Misc.cmake)


# ---[ Warnings
peloton_warnings_disable(CMAKE_CXX_FLAGS -Wno-strict-aliasing)

# ---[ Config generation
configure_file(cmake/Templates/peloton_config.h.in "${PROJECT_BINARY_DIR}/peloton_config.h")

# ---[ Includes
set(Peloton_SRC_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/src/include)
set(Peloton_TEST_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/test/include)
set(Peloton_THIRD_PARTY_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/third_party)
include_directories(${Peloton_SRC_INCLUDE_DIR} ${Peloton_TEST_INCLUDE_DIR} ${Peloton_THIRD_PARTY_INCLUDE_DIR} ${PROJECT_BINARY_DIR})
include_directories(BEFORE src) # This is needed for gtest.

# ---[ Subdirectories
add_subdirectory(src)
add_subdirectory(test)

# -- [ Coverage
option(COVERALLS "Generate coveralls data" OFF)

if (COVERALLS)
	include(Coveralls)
	coveralls_turn_on_coverage()

	# Create the coveralls target.
	file(GLOB_RECURSE srcs ${PROJECT_SOURCE_DIR}/src/*/*.cpp)

	peloton_convert_absolute_paths(srcs)
	peloton_convert_absolute_paths(parser_srcs)

    #message(STATUS "Coverage srcs : ${srcs}" )
	set(COVERAGE_SRCS ${srcs})

    coveralls_setup("${COVERAGE_SRCS}" ON)
endif()

# -- [ Doxygen

if (DOXYGEN)
	include(doxygen)
	doxygen_configure(src/ test/)
endif()

# ---[ Linter target
add_custom_target(lint COMMAND ${CMAKE_COMMAND} -P ${PROJECT_SOURCE_DIR}/cmake/lint.cmake)

endif()

# ---[ Configuration summary
beeri_print_configuration_summary()

# ---[ Export configs generation
# peloton_generate_export_configs()
