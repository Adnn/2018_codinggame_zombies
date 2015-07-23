## #################################################################
## Root CMakeLists.txt
## #################################################################

# Not tested with previous versions
cmake_minimum_required(VERSION 3.0)

# TODO : set project name
project(__)

## #################################################################
## Setup CMake Modules
## #################################################################

# Where to look for custom FindXXX.cmake files
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Definitions of custom macros
include (cmc-macros)


## #################################################################
## Resolve dependencies
## #################################################################

# TODO : find all your dependencies packages
#find_package(__)

# Directory where custom headers are exported.
# It is notably where ${libname}_Export.h files will be exported for DLL libraries,
#   and those file must be seen for libraries and clients compilations.
include_directories(${CMAKE_BINARY_DIR}/include)


## #################################################################
## Build options
## #################################################################

# Doxygen documentation generation
option(BUILD_DOCUMENTATION "Build doxygen's documentation" false)
conditional_add_subdirectory(docs OPTIONS BUILD_DOCUMENTATION)

# CMake automatically checks this variable value when calling add_library command.
option(BUILD_SHARED_LIBS "Build shared libraries" false)

# 
# C++14 support
# 
option(BUILD_WITH_C++14_SUPPORT "Set the compiler flags/options required to compile with C++14 support" true)
if(BUILD_WITH_C++14_SUPPORT)
    if(UNIX)
        list(APPEND CMAKE_CXX_FLAGS "-std=c++1y") # for clang 3.4
    endif(UNIX)

    #With C++14 support, Xcode should use libc++ (by Clang) instead of default GNU stdlibc++
    if (CMAKE_GENERATOR STREQUAL "Xcode")
        SET(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
    endif ()
endif(BUILD_WITH_C++14_SUPPORT)


## #################################################################
## Add targets
## #################################################################

# Start recursive crawling of the sources
add_subdirectory(src)
