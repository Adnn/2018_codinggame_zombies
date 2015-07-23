## #################################################################
## CMakeLists.txt
## #################################################################

# TODO : library name goes here
project(__)

# TODO : list .h files here. 
# Helpful windows command : dir /b /oen
set(${PROJECT_NAME}_HEADERS
)

# TODO : list .cpp files here
set(${PROJECT_NAME}_SOURCES
)

add_library(${PROJECT_NAME}
    ${${PROJECT_NAME}_SOURCES}
    ${${PROJECT_NAME}_HEADERS}
)

## Adds the library headers themselves to the interface include directory
target_include_directories(${PROJECT_NAME} INTERFACE 
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
                           $<INSTALL_INTERFACE:include>
)

target_include_directories(${PROJECT_NAME} PUBLIC
)

target_link_libraries(${PROJECT_NAME}
)


######################################################################
## Installation stuff - common to all projects
######################################################################

set_target_properties(${PROJECT_NAME} PROPERTIES
                      VERSION "${VERSION}"
                      SOVERSION "${SOVERSION}"
)

# Generate the export set for the target
install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}Targets
        RUNTIME DESTINATION ${RUNTIME_OUTPUT_DIRECTORY}
        LIBRARY DESTINATION ${LIBRARY_OUTPUT_DIRECTORY}
        ARCHIVE DESTINATION ${ARCHIVE_OUTPUT_DIRECTORY}
)

# Install the headers
install(FILES ${${PROJECT_NAME}_HEADERS}
        DESTINATION include/${PROJECT_NAME})
    
# Generate config files in the build tree.
configure_file(${CMAKE_SOURCE_DIR}/cmake/Config.cmake.in
               ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
               @ONLY)

# Custom variable holding the destination folder for package configuration files
set (ConfigPackageLocation cmake/)

# Install the config file
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
        DESTINATION ${ConfigPackageLocation})

# Exports
# TODO : change namespace
set (NAMESPACE "AD")
install(EXPORT ${PROJECT_NAME}Targets NAMESPACE ${NAMESPACE}::
        DESTINATION ${ConfigPackageLocation}) #install tree
export(EXPORT ${PROJECT_NAME}Targets NAMESPACE ${NAMESPACE}::) #build tree
