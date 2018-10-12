#.rst:
# cmc-find
# --------
#
# Provides function to help writting FindXxx modules.


function(HELP_FIND module)
    set(oneValueArgs "HEADER")
    set(multiValueArgs "LIBRARY;LIBRARY_DEBUG;LIBRARY_RELEASE")
    cmake_parse_arguments(CAS "${optionsArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    if(CAS_LIBRARY AND (CAS_LIBRARY_DEBUG OR CAS_LIBRARY_RELEASE))
        message(SEND_ERROR "HELP_FIND cannot be called with both LIBRARY and LIBRARY_<config>")
    endif()

    # The base search path
    set (_${module}_PATH)

    if(${module}_ROOT_DIR)
        set(_${module}_PATH ${${module}_ROOT_DIR})
    elseif(${module}_ROOT)
        set(_${module}_PATH ${${module}_ROOT})
    elseif(${module}_DIR)
        set(_${module}_PATH ${${module}_DIR})
    endif()

    ##
    ## Look for headers and libs
    ##
    find_path(${module}_INCLUDE_DIR ${CAS_HEADER}
        PATHS
            ${_${module}_PATH}/include
        NO_DEFAULT_PATH
    )

    find_path(${module}_INCLUDE_DIR ${CAS_HEADER})


    ## 
    ## Look for the library binaries
    ##
    if(NOT CAS_LIBRARY)
        _cmc_find_library(${module}_LIBRARY_RELEASE CAS_LIBRARY_RELEASE)
        _cmc_find_library(${module}_LIBRARY_DEBUG CAS_LIBRARY_DEBUG)
        if(${module}_LIBRARY_RELEASE AND ${module}_LIBRARY_DEBUG)
            set(${module}_link_line "optimized ${${module}_LIBRARY_RELEASE} debug ${${module}_LIBRARY_DEBUG}")
            set(${module}_link_target
                    IMPORTED_LOCATION_RELEASE ${${module}_LIBRARY_RELEASE}
                    IMPORTED_LOCATION_DEBUG ${${module}_LIBRARY_DEBUG}
               )
            set(${module}_required_libs ${module}_LIBRARY_RELEASE ${module}_LIBRARY_DEBUG)
        elseif(${module}_LIBRARY_RELEASE)
            message(WARNING "${module} debug library not found, will only use the release build.")
            _cmc_define_single_library_variable(${module}_LIBRARY_RELEASE)
        elseif(${module}_LIBRARY_DEBUG)
            message(WARNING "${module} release library not found, will only use the debug build.")
            _cmc_define_single_library_variable(${module}_LIBRARY_DEBUG)
        endif()
    else()
        _cmc_find_library(${module}_LIBRARY CAS_LIBRARY)
        _cmc_define_single_library_variable(${module}_LIBRARY)
    endif()


    ##	
    ## handle the QUIETLY and REQUIRED arguments and set ${module}_FOUND to TRUE if 
    ## all listed variables are TRUE
    ##
    INCLUDE(FindPackageHandleStandardArgs)
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(${module} 
        FOUND_VAR
            ${module}_FOUND
        REQUIRED_VARS
            ${module}_INCLUDE_DIR
            ${${module}_required_libs}
    )

    #there seems to be a bug : xxx_FOUND is always output in upper case
    if (${module}_FOUND)
        set(${module}_INCLUDE_DIRS ${${module}_INCLUDE_DIR} PARENT_SCOPE)
        set(${module}_LIBRARIES ${${module}_link_line} PARENT_SCOPE)
        # Unlike the 'classic' FindXxx.cmake modules, we are here in a function
        # it is thus required to forward the values to the parent scope, including the _FOUND.
        set(${module}_FOUND ${${module}_FOUND} PARENT_SCOPE)
    endif()

    ##
    ## Defines an imported target for the found library
    ##
    if (${module}_FOUND AND NOT TARGET ${module}::${module})
        add_library(${module}::${module} UNKNOWN IMPORTED)
        set_target_properties(${module}::${module} PROPERTIES
            ${${module}_link_target} # The variable itself contains the name(s) of the propertie(s)
            INTERFACE_INCLUDE_DIRECTORIES "${${module}_INCLUDE_DIR}"
      )
    endif()

    mark_as_advanced( ${module}_INCLUDE_DIR ${${module}_required_libs} )

endfunction()


# Internal usage macro
macro(_cmc_find_library destination filenames)
    find_library(${destination} NAMES ${${filenames}}
        PATHS
            ${_${module}_PATH}
            ${_${module}_PATH}/lib
            ${_${module}_PATH}/bin
        NO_DEFAULT_PATH
    )

    # Note: commented out for the moment, because
    # a) it _should_ not be usefull, well behaved builds should build libraries with the correct platform suffix
    # b) it caused a mess when evaluating Conan, eg. finding the include/curl directory before the actual library 
    ## Note: CMake seems to have a limitation in find_library that is not well documented:
    ## It will only consider a name as a literal filename if the extension appears in CMAKE_FIND_LIBRARY_SUFFIXES
    ## see: http://public.kitware.com/pipermail/cmake/2011-March/043369.html
    ## And on Windows, this variable does not contain .a extension by default.
    #find_file(${destination} NAMES ${${filenames}}
    #    PATHS
    #        ${_${module}_PATH}
    #        ${_${module}_PATH}/lib
    #        ${_${module}_PATH}/bin
    #    NO_SYSTEM_ENVIRONMENT_PATH
    #)

    find_library(${destination} NAMES ${${filenames}})

    #find_file(${destination} NAMES ${${filenames}})
endmacro()


# Internal usage macro
macro(_cmc_define_single_library_variable library)
    set(${module}_link_line ${${library}})
    set(${module}_link_target IMPORTED_LOCATION ${${library}})
    set(${module}_required_libs ${library})
endmacro()
