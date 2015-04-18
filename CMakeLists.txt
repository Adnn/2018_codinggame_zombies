### CMakeLists.txt
## 
######################################################################

# Not tested with previous versions
cmake_minimum_required(VERSION 3.0)

# TODO : set project name
project(__)


## #################################################################
## Setup version numbering
## #################################################################
set(VERSION_MAJOR 0 CACHE STRING "Major version number.")
set(VERSION_MINOR 1 CACHE STRING "Minor version number.")
set(VERSION_BUILD 0 CACHE STRING "Build version number.")
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}")
set(SOVERSION "${VERSION_BUILD}")

set(CMAKE_COLOR_MAKEFILE ON)
set(CMAKE_VERBOSE_MAKEFILE OFF)


## #################################################################
## Setup output paths
## #################################################################

set(CMAKE_DEBUG_POSTFIX "d")
### from osg CMakeLists.txt
IF(UNIX AND NOT WIN32 AND NOT APPLE)
  IF(CMAKE_SIZEOF_VOID_P MATCHES "8")
      SET(LIB_POSTFIX "64" CACHE STRING "suffix for 32/64 dir placement")
      MARK_AS_ADVANCED(LIB_POSTFIX)
  ENDIF(CMAKE_SIZEOF_VOID_P MATCHES "8")
ENDIF(UNIX AND NOT WIN32 AND NOT APPLE)
IF(NOT DEFINED LIB_POSTFIX)
    SET(LIB_POSTFIX "")
ENDIF(NOT DEFINED LIB_POSTFIX)


if(WIN32)
  set(RUNTIME_OUTPUT_DIRECTORY bin)
  set(LIBRARY_OUTPUT_DIRECTORY bin)
  set(ARCHIVE_OUTPUT_DIRECTORY lib)
else(WIN32)
  set(RUNTIME_OUTPUT_DIRECTORY bin)
  set(LIBRARY_OUTPUT_DIRECTORY lib${LIB_POSTFIX})
  set(ARCHIVE_OUTPUT_DIRECTORY lib${LIB_POSTFIX})
endif(WIN32)


set(CMAKE_LIBRARY_OUTPUT_DIRECTORY    ${CMAKE_BINARY_DIR}/${LIBRARY_OUTPUT_DIRECTORY})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY    ${CMAKE_BINARY_DIR}/${ARCHIVE_OUTPUT_DIRECTORY})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY    ${CMAKE_BINARY_DIR}/${RUNTIME_OUTPUT_DIRECTORY})


## #################################################################
## Setup CMake Modules
## #################################################################
# Where to look for custom FindXXX.cmake files
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Definitions of custom macros
include (cmc-macros)

## #################################################################
## Setup the build tools
## #################################################################

# TODO : Uncomment following block to force a decent support of C++11 in VS
## In case we are building with VisualStudio
#if(MSVC OR MSVC_IDE) 
#  if( MSVC_VERSION LESS 1800 )       # before Visual Studio 2013
#    message(FATAL_ERROR "The project requires C++11 features. " 
#      "You need at least Visual Studio 12 (Microsoft Visual Studio 2013), " 
#      "with Microsoft Visual C++ Compiler Nov 2013 CTP (CTP_Nov2013).") 
#  elseif( MSVC_VERSION EQUAL 1800 )  # VS 2013 (VC12)
#    message( "VC12: use Microsoft Visual Studio 2013 " 
#      "with Microsoft Visual C++ Compiler Nov 2013 CTP (CTP_Nov2013)." ) 
#    set(CMAKE_GENERATOR_TOOLSET "CTP_Nov2013" CACHE STRING "Platform Toolset" FORCE) 
#  else() # VC12+, assuming C++11 supported. 
#    #nothing to do hopefully
#  endif() 
#endif()


## #################################################################
## Setup installation settings
## #################################################################
#set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
#list(APPEND CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${LIBRARY_OUTPUT_DIRECTORY}" )


## #################################################################
## Resolve dependencies
## #################################################################
#if(APPLE)
#  mark_as_advanced(CMAKE_OSX_ARCHITECTURES)
#  #SYSROOT variable allows to select OS X SDK.
#  # see: http://stackoverflow.com/q/10165335/1027706
#  mark_as_advanced(CMAKE_OSX_SYSROOT)
#endif(APPLE)

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
