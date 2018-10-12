## CMAKE_DOCUMENTATION_START cmc_optional_conan_setup
##
## If a conanbuildinfo.cmake file is present in the current binary dir,
## configure the current project by calling macros from said file.
##
## CMAKE_DOCUMENTATION_END
macro(cmc_optional_conan_setup)
    set(_found_conan "")
    if(AG_BUILD_BY_CONAN)
        # AG_BUILD_BY_CONAN is set by the Conan recipe:
        # if it is true, we consider the current build is run by Conan
        # In that case, it is probably better to let Conan control CMake
        # generationn as much as it needs by calling conan_basic_setup() above
        # (for example, handling the RPATH cancelling on OS X)
        include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake RESULT_VARIABLE _found_conan)
        conan_basic_setup()
        message(STATUS "cmc-conan detected build by Conan")
    else()
        # conan_paths.cmake populates CMAKE_MODULE_PATH and CMAKE_LIBRARY|INCLUDE_PATH,
        # allowing find_package to locate conan managed dependencies
        # without polluting other aspects of the cmake mechanic
        # (unlike conan_basic_setup from conanbuildinfo.cmake)
        # We consider it the accepted approach for User initiaed builds
        include(${CMAKE_BINARY_DIR}/conan_paths.cmake OPTIONAL RESULT_VARIABLE _found_conan)
        if(_found_conan)
            message(STATUS "cmc-conan detected User build, with Conan satisfied dependencies in conan_paths.cmake")
        endif()
    endif()
    unset(_found_conan)
endmacro()
