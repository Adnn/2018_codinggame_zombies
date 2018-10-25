## #################################################################
## CMakeLists.txt
## #################################################################

# TODO : executable name goes here
project(Invasion)

# TODO : list .h files here. 
# Helpful windows command : dir /b /oen
set(${PROJECT_NAME}_HEADERS
)

# TODO : list .cpp files here
set(${PROJECT_NAME}_SOURCES
)

add_executable(${PROJECT_NAME}
    main.cpp
    ${${PROJECT_NAME}_SOURCES}
    ${${PROJECT_NAME}_HEADERS}
)


target_include_directories(${PROJECT_NAME} PRIVATE
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    zombies
)


# TODO : Uncomment to raise warning level and set warning as error
cmc_target_all_warnings_as_errors(${PROJECT_NAME})


######################################################################
## Package Installation 
######################################################################

include(cmc-install)

cmc_target_install_package(${PROJECT_NAME}
                           NAMESPACE ${PROJECT_NAME}
                           #VERSION "__"
                           #SOVERSION "__"
)

