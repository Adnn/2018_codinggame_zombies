## #################################################################
## CMakeLists.txt
## #################################################################

# TODO : executable name goes here
project(__)

set(${PROJECT_NAME}_HEADERS
    AppDelegate.h
)

set(${PROJECT_NAME}_SOURCES
    AppDelegate.mm
)

set(${PROJECT_NAME}_XIB
    MainMenu.xib
)

set(${PROJECT_NAME}_RESOURCES
    # Potentially list other resources (images, html, ...) here
    ${${PROJECT_NAME}_XIB}
)

# By default, the configured Info.plist was placed in a 'Resources' group automatically, but not the xib files.
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


# Dependencies marked as system libraries: avoid generating warnings for header in those include directories
target_include_directories(${PROJECT_NAME} SYSTEM PRIVATE
)

target_include_directories(${PROJECT_NAME} PRIVATE
)

target_link_libraries(${PROJECT_NAME}
                      "-framework Cocoa" #Could probably use find_package() to find it as an alternative
)


# TODO : Uncomment to raise warning level and set warning as error
#cmc_target_all_warnings_as_errors(${PROJECT_NAME})


######################################################################
## OS X specific
######################################################################

# Enable Obj-C ARC
target_compile_options(${PROJECT_NAME} PRIVATE "-fobjc-arc")

 ## Note: a command to copy files into the generated bundle even in the build tree
 ## (sometimes required for some libraries)
#add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
#    COMMAND rsync -L __ $<TARGET_FILE_DIR:${PROJECT_NAME}>/
#)


######################################################################
## Installation stuff - common to all projects
######################################################################
set_target_properties(${PROJECT_NAME} PROPERTIES
                      VERSION "${VERSION}"
                      SOVERSION "${SOVERSION}"
                      RESOURCE "${${PROJECT_NAME}_RESOURCES}" # To generate the .nib files
                                                        # see: http://stackoverflow.com/a/13292471/1027706
                       ## Optional (see Info.plist handling)
                      #MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist" # Overrides the default template with a custom Info.plist
                      INSTALL_RPATH_USE_LINK_PATH True # The external libraries with an RPATH-based install name should have their directory appended to INSTALL_RPATH
)


install(TARGETS ${PROJECT_NAME}
        BUNDLE DESTINATION ${RUNTIME_OUTPUT_DIRECTORY}  # Executables created as MACOSX_BUNDLE on OS X
        RUNTIME DESTINATION ${RUNTIME_OUTPUT_DIRECTORY} # Executables in other situations
        LIBRARY DESTINATION ${LIBRARY_OUTPUT_DIRECTORY}
        ARCHIVE DESTINATION ${ARCHIVE_OUTPUT_DIRECTORY}
        RESOURCE DESTINATION "dummy_copy" # There is a warning emitted by CMake if this is not set.
                                          # (Which seems useless under OS X, see: http://stackoverflow.com/q/31723271/1027706)
)

## Fixup the INSTALLED bundle: copies dynamic libraries next to the executable, fixes the install names.
set (_app ${CMAKE_INSTALL_PREFIX}/${RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME}.app)
## Nota: BU_CHMOD_BUNDLE_ITEMS allows fixup_bundle to issue a chmod command if a copied library is not writtable
## It is usefull in case a library is copied from a system folder. (https://public.kitware.com/Bug/view.php?id=13833)
install(CODE "set(BU_CHMOD_BUNDLE_ITEMS ON)
              include(BundleUtilities)
              fixup_bundle(\"${_app}\" \"\" \"\")"
        COMPONENT Runtime
)
