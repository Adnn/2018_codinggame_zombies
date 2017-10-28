## #################################################################
## CMakeLists.txt
## #################################################################

# TODO : executable name goes here
project(__)

# Helpful windows command : dir /b /oen
set(${PROJECT_NAME}_HEADERS
    AppDelegate.h
)

set(${PROJECT_NAME}_SOURCES
    AppDelegate.mm
)

## No XIB, No NIB
#set(${PROJECT_NAME}_XIB
#)

set(${PROJECT_NAME}_RESOURCES
    # Potentially list other resources (images, html, ...) here
)

# By default, the configurer Info.plist was placed in a 'Resources' group automatically, but not the xib files.
# Explicitly placing the xib files in the same group is cancelling the implicit grouping of Info.plist.
source_group(Resources FILES ${${PROJECT_NAME}_XIB} Info.plist)


add_executable(${PROJECT_NAME} MACOSX_BUNDLE
    ${${PROJECT_NAME}_HEADERS}
    ${${PROJECT_NAME}_SOURCES}
    ${${PROJECT_NAME}_RESOURCES} #Shows the resources in the IDE
    main.mm
)

    ## Info.plist handling
# MACOSX_BUNDLE will create Info.plist by configuring MacOSXBundleInfo.plist.in: we placed a custom version of this
# template in project's cmake/, which appears in the CMAKE_MODULE_PATH before the one installed by CMake.
# see: http://www.cmake.org/cmake/help/v3.0/prop_tgt/MACOSX_BUNDLE_INFO_PLIST.html?highlight=macosx_bundle_info_plist
#
# Alternatively, a specific input template file can be specified with the target's MACOSX_BUNDLE_INFO_PLIST variable,
# overriding the default template file selection described above.  Such custom file could hardcode all the values.

target_link_libraries(${PROJECT_NAME} PRIVATE
)


# TODO : Uncomment to raise warning level and set warning as error
#cmc_target_all_warnings_as_errors(${PROJECT_NAME})


######################################################################
## OS X specific
######################################################################

# Enable Obj-C ARC
target_compile_options(${PROJECT_NAME} PRIVATE "-fobjc-arc")

target_link_libraries(${PROJECT_NAME} PRIVATE
                      "-framework Cocoa" #Could probably use find_package() to find it as an alternative
)


######################################################################
## Package Installation 
######################################################################

set_target_properties(${PROJECT_NAME} PROPERTIES
                      MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/NiblessInfo.plist.in
                      INSTALL_RPATH_USE_LINK_PATH True # The external libraries with an RPATH-based install name should have their directory appended to INSTALL_RPATH
)

include(cmc-install)

cmc_target_install_package(${PROJECT_NAME}
                           NAMESPACE ${PROJECT_NAME}
                           RESOURCE_DESTINATION "dummy_resource_copy" # There is a warning emitted by CMake if this is not set.
                                  # (Which seems useless under OS X, see: http://stackoverflow.com/q/31723271/1027706)
                           #VERSION "__"
                           #SOVERSION "__"
)

cmc_fixup_osx_bundle(${PROJECT_NAME})

