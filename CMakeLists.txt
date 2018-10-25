## #################################################################
## Root CMakeLists.txt
## #################################################################

# >= 2.8.12 to be able to use the target variant of commands
# >= 3.3 to have access to IN_LIST operator
# 3.9 fixes a bad bug with CMAKE_AUTORCC:
#   it only regenerated resource
#   if the resources.qrc was touched, not when the pointed files were touched.
cmake_minimum_required(VERSION 3.9)

# TODO : set project name
project(cgprepa)


## #################################################################
## Setup CMake Modules
## #################################################################

# Where to look for custom FindXXX.cmake files and custom includes
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Definitions of custom macros
include (cmc-macros)

# Definition of custom variables
cmc_define_option_variables()

# Handle Conan, if it was used to install dependencies 
include(cmc-conan)
cmc_optional_conan_setup()


## #################################################################
## Setup output paths
## #################################################################

# Setups the debug postfix, and populates *_OUTPUT_DIRECTORY variables.
cmc_setup_output()


## #################################################################
## Build options
## #################################################################

# Doxygen documentation generation
option(BUILD_DOCUMENTATION "Build doxygen's documentation" false)
conditional_add_subdirectory(cmake/doc OPTIONS BUILD_DOCUMENTATION)

# CMake automatically checks this variable value when calling add_library command.
option(BUILD_SHARED_LIBS "Build shared libraries" false)

#
# Control modules to build
#

# TODO : list optional components here, assigning one variable each
#option (BUILD_xxx "Build xxx application" true)


# 
# C++ version control
# 
# General CPP options
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_EXTENSIONS OFF)
include(cmc-cpp)
#cmc_enable_objc_arc()


## #################################################################
## Resolve dependencies
## #################################################################

# TODO : find all your dependencies packages

#
# Internal dependencies
#
include(cmc-import)                    
#cmc_find_internal_package(__   NAMESPACE __::)


#
# 3rd party dependencies
#

find_package(Boost 1.68 
    COMPONENTS
        filesystem
)

find_package(curl CONFIG REQUIRED) 

## #################################################################
## Add targets
## #################################################################

# Start recursive crawling of the sources
add_subdirectory(src)
