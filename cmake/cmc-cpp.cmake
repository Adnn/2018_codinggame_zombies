## CMAKE_DOCUMENTATION_START cmc_select_cpp_version
##
## Define GUI variable to control which C++ version will be used for compilation.
## Then calls cmc_enable_cpp_verison to apply the required settings.
##
## CMAKE_DOCUMENTATION_END
macro(cmc_select_cpp_version)

    set(optionsArgs "C++98;C++11;C++14;C++17")

    set(BUILD_C++_VERSION C++14 CACHE STRING "Set the compiler flags/options required to chose supported C++ revision")
    set_property(CACHE BUILD_C++_VERSION PROPERTY STRINGS ${optionsArgs})

    cmc_enable_cpp_version(${BUILD_C++_VERSION})

endmacro()


## CMAKE_DOCUMENTATION_START cmc_enable_cpp_version
##
## Initialize custom variables, grouped under 'OPTION', to control CMake run.
##
## CMAKE_DOCUMENTATION_END
macro(cmc_enable_cpp_version)

    cmake_parse_arguments(CAS "${optionsArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    if (CAS_C++11)
      set(CMAKE_CXX_STANDARD 11)

      # /todo Only specify the library for version of XCode that do not use the right one by default.
      #With C++11/14 support, Xcode should use libc++ (by Clang) instead of default GNU stdlibc++
      if (CMAKE_GENERATOR STREQUAL "Xcode")
          SET(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++11")
      endif ()

    elseif(CAS_C++14)
      set(CMAKE_CXX_STANDARD 14)

      if (CMAKE_GENERATOR STREQUAL "Xcode")
          SET(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++14")
      endif ()

    elseif(CAS_C++17)
      set(CMAKE_CXX_STANDARD 17)

      if (CMAKE_GENERATOR STREQUAL "Xcode")
          SET(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++17")
      endif ()

    else()
        message ("cmc_enable_cpp_version() must be invoked with a valid langage version.")
        return()
    endif()


    # General CPP options
    set(CMAKE_CXX_EXTENSIONS OFF)

    if (CMAKE_GENERATOR STREQUAL "Xcode")
        SET(CMAKE_XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES)
    endif()

endmacro()


## CMAKE_DOCUMENTATION_START cmc_all_warnings_as_errors
##
## If the function is invoked, all compilation warnings are treated as errors
##
## CMAKE_DOCUMENTATION_END
function(cmc_all_warnings_as_errors target)

    set(gnuoptions "AppleClang" "Clang" "GNU")
    if (CMAKE_CXX_COMPILER_ID IN_LIST gnuoptions)
        set(option "-Werror")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(option "-WX")
    endif()

    # Enables all warnings
    # Except on Windows, where all warnings create too many problems with system headers
    if (NOT WIN32)
        target_compile_options(${target} PRIVATE -Wall)
    endif()

    target_compile_options(${target} PRIVATE ${option})
    target_link_libraries(${target} PRIVATE ${option})

endfunction()

