## #################################################################
## CMakeLists.txt
## #################################################################

# TODO : library name goes here
project(__)

# TODO : list .dox standalone doxygen pages here
set(${PROJECT_NAME}_DOXYGEN
    #mainpage.dox
)

# TODO : list .h files here. 
# Helpful windows command : dir /b /oen
set(${PROJECT_NAME}_HEADERS
)

# TODO : list .cpp files here
set(${PROJECT_NAME}_SOURCES
)

cmc_source_group() ## For IDE generators, groups files based on the subfolder organisation

add_library(${PROJECT_NAME}
    ${${PROJECT_NAME}_SOURCES}
    ${${PROJECT_NAME}_HEADERS}
    ${${PROJECT_NAME}_DOXYGEN}
)


## Adds the library headers themselves to the interface include directory
## Adds the parent folder to the header search path used when building *this* library.
## It allows this library's as well as client code to include headers from this library using <${PROJECT_NAME}/file.h>
## (eg. instead of relying on potentially backtracing relative paths inside this library)
## Drawback: this is making the other libraries in the lib/ folder visible for inclusion.
target_include_directories(${PROJECT_NAME} 
                            PUBLIC
                                $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
                            PRIVATE
                                $<INSTALL_INTERFACE:include>
)

# Public includes
target_include_directories(${PROJECT_NAME} PUBLIC
)

# Public includes treated as system (i.e., not generating warnings)
target_include_directories(${PROJECT_NAME} SYSTEM PUBLIC
)

target_link_libraries(${PROJECT_NAME} PUBLIC
)


# TODO : Uncomment to raise warning level and set warning as error
#cmc_target_all_warnings_as_errors(${PROJECT_NAME})


######################################################################
## Package Installation 
######################################################################

include(cmc-install)

# TODO: Allow the generated Config file to autonomously find the dependencies of the target,
# giving -for each dependency- a string equivalent to the arguments that would be given to find_package.
#cmc_target_depends(${PROJECT_NAME} "Boost COMPONENT filesystem")
#cmc_target_depends(${PROJECT_NAME} "OtherLib")

cmc_target_install_package(${PROJECT_NAME}
                           NAMESPACE ${PROJECT_NAME}
                           PUBLIC_HEADER ${${PROJECT_NAME}_HEADERS}
                           GENERATE_EXPORT_HEADER
                           #VERSION "__"
                           #SOVERSION "__"
                           #COMPATIBILITY SameMajorVersion
)

