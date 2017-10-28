## CMAKE_DOCUMENTATION_START cmc_install_package
##
## A macro to take care of the complete "cmake packaging" and installation of target (relying on an export-set).
## The package is created in the namespace given to NAMESPACE argument.
## For library targets, an alias target NAMESPACE::target is also created
## in order to make prefixed usage available from the build tree.
##
## Installs the headers given to PUBLIC_HEADER, creating the same folder structure prefixed by 'include/${target}/'.
##
## GENERATE_EXPORT_HEADER: If the option is given, generate export headers (e.g. the declspec dance under Windows).
## 
## VERSION: When provided, sets the target version (and SOVERSION), and generate a ConfigVersion package file
## COMPATIBILITY: Control ConfigVersion compatiblity mode.
##                Any of (AnyNewerVersion|SameMajorVersion|ExactVersion), defaults to ExactVersion
##
## CMAKE_DOCUMENTATION_END
function(cmc_target_install_package target)

    set(optionsArgs GENERATE_EXPORT_HEADER)
    set(oneValueArgs NAMESPACE VERSION SOVERSION COMPATIBLITY)
    set(multiValueArgs PUBLIC_HEADER)
    cmake_parse_arguments(CAS "${optionsArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    # Sets the version on the target
    set_target_properties(${target} PROPERTIES
                          VERSION "${CAS_VERSION}"
                          SOVERSION "${CAS_SOVERSION}"
    )

    # If the target is a library type (see: https://cmake.org/cmake/help/v3.10/prop_tgt/TYPE.html) 
    # Creates an alias for it prefixed with the namespace (so other targets in the same build tree can use it prefixed).
    get_target_property(target_type ${target} TYPE)
    set(library_type_list STATIC_LIBRARY MODULE_LIBRARY SHARED_LIBRARY INTERFACE_LIBRARY)
    if (target_type IN_LIST library_type_list)
        add_library(${namespace}::${target} ALIAS ${target})
    endif()

    # Install binaries and generate the export set for the target
    set (exportSet ${target}Targets)
    install(TARGETS ${target} EXPORT ${exportSet}
            RUNTIME DESTINATION ${RUNTIME_OUTPUT_DIRECTORY}
            LIBRARY DESTINATION ${LIBRARY_OUTPUT_DIRECTORY}
            ARCHIVE DESTINATION ${ARCHIVE_OUTPUT_DIRECTORY}
    )

    # Install headers
    set(include_prefix include/${target})
    cmc_install_header_preserve_structure(${include_prefix} "${CAS_PUBLIC_HEADER}")

    # Generate and install the export header (e.g. __declspec( dllexport )) and install it
    if (CAS_GENERATE_EXPORT_HEADER)
        include(GenerateExportHeader)
        generate_export_header(${target})
        install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${target}_export.h"
                DESTINATION ${include_prefix}
        )
    endif()

    # Custom variable holding the destination folder for package configuration files
    set (ConfigPackageLocation lib/cmake/${target})
    # Install the Config file alongside generated target file
    cmc_target_export(${target} ${ConfigPackageLocation} NAMESPACE ${CAS_NAMESPACE})
    # If version is provided, generate and install a ConfigVersion file
    if (CAS_VERSION)
        if (${CAS_COMPATIBILITY})
            set(compatibility ${CAS_COMPATIBILITY})
        else()
            set(compatibility "ExactVersion")
        endif()
        cmc_target_config_version(${target} ${CAS_VERSION} ${compatibility} ${ConfigPackageLocation})
    endif()

endfunction()


## CMAKE_DOCUMENTATION_START cmc_target_export
##
## cmc_target_export is a function wrapping the boilerplate code that is used to install an export
## created by install(TARGET ... EXPORT ...).
## See: http://www.cmake.org/cmake/help/v3.0/manual/cmake-packages.7.html#creating-packages for the source of this code
##
## CMAKE_DOCUMENTATION_END
function(cmc_target_export target config_package_location)

    set(oneValueArgs "NAMESPACE")
    cmake_parse_arguments(CAS "" "${oneValueArgs}" "" ${ARGN})

    # TARGETFILE is used in Config file as well as in this macro
    set(TARGETFILE ${target}Targets.cmake)

    if(cmc_${target}_dependencies_buffer)
        set(TARGET_DEPENDENCIES "include(CMakeFindDependencyMacro)${cmc_${target}_dependencies_buffer}")
    endif()

    # Generate config files in the build tree, from the template in cmake/Config.cmake.in
    configure_file(${CMAKE_SOURCE_DIR}/cmake/Config.cmake.in
                   ${CMAKE_CURRENT_BINARY_DIR}/${target}Config.cmake
                   @ONLY
    )

    # Generate the build tree checks, that are used from the config file
    cmc_internal_config_buildtree_checks_code(BUILD_TREE_DIR_CHECKS)
    configure_file(${CMAKE_SOURCE_DIR}/cmake/Config-BuildTreeChecks.cmake.in
                   ${CMAKE_CURRENT_BINARY_DIR}/${target}Config-BuildTreeChecks.cmake
                   @ONLY
    )

    # Exports
    install(EXPORT ${exportSet}
            NAMESPACE "${CAS_NAMESPACE}"
            DESTINATION ${config_package_location}) #install tree
    export(EXPORT ${exportSet}
           NAMESPACE "${CAS_NAMESPACE}" 
           FILE ${CMAKE_CURRENT_BINARY_DIR}/${TARGETFILE}) #build tree

    # Install the package files Config.cmake and ConfigVersion.cmake
    # (not the BuildTreeChecks.cmake, which is build tree only)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${target}Config.cmake
            DESTINATION ${config_package_location})

endfunction()


## CMAKE_DOCUMENTATION_START cmc_target_config_version
##
## cmc_target_config_version is a function wrapping the boilerplate code that is used to install a version config file.
## See: http://www.cmake.org/cmake/help/v3.0/manual/cmake-packages.7.html#creating-packages for the source of this code
##
## CMAKE_DOCUMENTATION_END
function(cmc_target_config_version target version compatibility config_package_location)

    set(config_version_file "${CMAKE_CURRENT_BINARY_DIR}/${target}ConfigVersion.cmake")
    include(CMakePackageConfigHelpers)
    write_basic_package_version_file(
        ${config_version_file}
        VERSION ${version}
        COMPATIBILITY ${compatibility}
    )

    install(FILES ${config_version_file}
            DESTINATION ${config_package_location}
    )
    
endfunction()


## CMAKE_DOCUMENTATION_START cmc_target_depends
##
## cmc_target_depends allows to populate the dependencies requirements of the target to be added in the Config file.
## This is  required because a Config file knows target dependencies, but does nothing to actually locate them.
## Each call to this function will add a line of the form "find_dependency(...)" to the Config file,
## where the ... are replaced by the literal content of 'dependency' argument.
##
## See: https://cmake.org/cmake/help/v3.10/manual/cmake-packages.7.html#creating-a-package-configuration-file
##
## Note: A function instead of a macro, to be able to use ARGN in a test.
##
## CMAKE_DOCUMENTATION_END
function(cmc_target_depends target dependency)
    if(ARGN)
        message(SEND_ERROR "cmc_target_depends must be invoked with a target name and single dependency string.")
    endif()
    set(cmc_${target}_dependencies_buffer "${cmc_${target}_dependencies_buffer}\nfind_dependency(${dependency})"
        PARENT_SCOPE)
endfunction()


## CMAKE_DOCUMENTATION_START cmc_install_header_preserve_structure
##
## This function installs all the headers in the list HEADER_LIST,recreating the same folder structure that appears
## in the filename.
## The folder structure is rooted in prefix.
##
## CMAKE_DOCUMENTATION_END
function(cmc_install_header_preserve_structure prefix HEADER_LIST)

    foreach(HEADER ${HEADER_LIST})
        get_filename_component(DIR ${HEADER} DIRECTORY)
        install(FILES ${HEADER} DESTINATION ${prefix}/${DIR})
    endforeach()

endfunction()

