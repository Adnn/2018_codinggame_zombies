## #################################################################
## Root CMakeLists.txt
## #################################################################

# Not tested with previous versions
cmake_minimum_required(VERSION 3.0)

# TODO : set project name
project(__)


## #################################################################
## Setup output paths
## #################################################################

# Used to initialize DEBUG_POSTFIX property of further created targets.
set(CMAKE_DEBUG_POSTFIX "d")

# Potentially adds a suffix to the library installation directory, by detecting the compiler size for void*
# Nota: copied from osg's root CMakeLists.txt
IF(UNIX AND NOT WIN32 AND NOT APPLE)
  IF(CMAKE_SIZEOF_VOID_P MATCHES "8")
      SET(LIB_POSTFIX "64" CACHE STRING "suffix for 32/64 dir placement")
      MARK_AS_ADVANCED(LIB_POSTFIX)
  ENDIF()
ENDIF()
IF(NOT DEFINED LIB_POSTFIX)
    SET(LIB_POSTFIX "")
ENDIF()

# On Windows platforms, .dll files are RUNTIME targets and the corresponding import library are ARCHIVE.
# Static libraries are always treated as archive: its is not common to build a LIBRARY on Windows.
# Those variables should be used by the install() command for the different targets.
set(RUNTIME_OUTPUT_DIRECTORY bin)
set(LIBRARY_OUTPUT_DIRECTORY lib${LIB_POSTFIX})
set(ARCHIVE_OUTPUT_DIRECTORY lib${LIB_POSTFIX})


## #################################################################
## Setup CMake Modules
## #################################################################

# Where to look for custom FindXXX.cmake files and custom includes
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Definitions of custom macros
include (cmc-macros)

# Definition of custom variables
define_option_variables()


## #################################################################
## Build options
## #################################################################

# Doxygen documentation generation
option(BUILD_DOCUMENTATION "Build doxygen's documentation" false)
conditional_add_subdirectory(docs OPTIONS BUILD_DOCUMENTATION)

# CMake automatically checks this variable value when calling add_library command.
option(BUILD_SHARED_LIBS "Build shared libraries" false)

#
# Select modules to build
#

# TODO : list optional components here, assigning one variable each
#option (BUILD_xxx "Build xxx application" true)


# 
# C++14 support
# 
include(cmc-cpp) # for enable_cpp_version
option(BUILD_WITH_C++14_SUPPORT "Set the compiler flags/options required to compile with C++14 support" true)
if(BUILD_WITH_C++14_SUPPORT)
    enable_cpp_version(C++14)
endif()


## #################################################################
## Resolve dependencies
## #################################################################

# TODO : find all your dependencies packages
#find_package(__)


## #################################################################
## Add targets
## #################################################################

# Start recursive crawling of the sources
add_subdirectory(src)
