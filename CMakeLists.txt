# Options
#set(JINJA2CPP_SANITIZERS address+undefined memory)
#set(JINJA2CPP_WITH_SANITIZERS none CACHE STRING "Build with sanitizer")
#set_property(CACHE JINJA2CPP_WITH_SANITIZERS PROPERTY STRINGS ${JINJA2CPP_SANITIZERS})
#set(JINJA2CPP_SUPPORTED_REGEX std boost)
#set(JINJA2CPP_USE_REGEX boost CACHE STRING "Use regex parser in lexer, boost works faster on most platforms")
#set_property(CACHE JINJA2CPP_USE_REGEX PROPERTY STRINGS ${JINJA2CPP_SUPPORTED_REGEX})
#set(JINJA2CPP_WITH_JSON_BINDINGS boost nlohmann rapid all none)
#set(JINJA2CPP_WITH_JSON_BINDINGS boost CACHE STRING "Build with json support(boost|rapid)")
#set_property(CACHE JINJA2CPP_WITH_JSON_BINDINGS PROPERTY STRINGS ${JINJA2CPP_WITH_JSON_BINDINGS})
#set (JINJA2CPP_DEPS_MODE "internal" CACHE STRING "Jinja2Cpp dependency management mode (internal | external | external-boost | conan-build). See documentation for details. 'interal' is default.")
#option(JINJA2CPP_BUILD_TESTS "Build Jinja2Cpp unit tests" ${JINJA2CPP_IS_MAIN_PROJECT})
#option(JINJA2CPP_STRICT_WARNINGS "Enable additional warnings and treat them as errors" ON)
#option(JINJA2CPP_BUILD_SHARED "Build shared linkage version of Jinja2Cpp" OFF)
#option(JINJA2CPP_PIC "Control -fPIC option for library build" OFF)
#option(JINJA2CPP_VERBOSE "Add extra debug output to the build scripts" OFF)
#option(JINJA2CPP_INSTALL "Add installation rules for JinjaCpp targets" ${JINJA2CPP_IS_MAIN_PROJECT})

cmake_minimum_required(VERSION 3.13)
project(jinja2cppmedium)
message(STATUS "Initiating compile using CMake ${CMAKE_VERSION}")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(OSXCROSS "Build via osxcross" OFF)

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_SOURCE_DIR}/cmake")
set(PROJECT_VERSION "0.2")

# custom static lib dirs
cmake_policy(SET CMP0144 NEW)

if(UNIX)  # linux/apple
    set(STATIC ON)
    set(CMAKE_PREFIX_PATH "/usr/local/boost/;${CMAKE_PREFIX_PATH}")
    set(Boost_USE_STATIC_LIBS ON)
    set(Boost_USE_STATIC_RUNTIME ON)
    if(UNIX AND NOT OSXCROSS)
        set(STATIC_LIBS -static-libgcc -static-libstdc++)
    endif()
elseif(MSVC)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    set(CMAKE_PREFIX_PATH "C:/local/boost_1_74_0/;${CMAKE_PREFIX_PATH}")
    set(Boost_NO_SYSTEM_PATHS true)
    set(Boost_USE_STATIC_LIBS OFF)
    set(Boost_USE_STATIC_RUNTIME OFF)
    set(Boost_USE_MULTITHREADED ON)
    add_definitions(-DBOOST_ALL_NO_LIB)
    add_definitions(-DBOOST_ALL_DYN_LINK)
    set(Boost_THREADAPI win32)
elseif(APPLE)
    message(FATAL_ERROR "no direct Apple support")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
option(BUILD_EXAMPLE "Build the example application" OFF)

include(FindCcache)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING
            "Default build type: Release" FORCE)
endif()

if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_SKIP_RPATH ON)
endif()

set(_BOOST_COMPONENTS system filesystem)
find_package(Boost 1.74 REQUIRED COMPONENTS ${_BOOST_COMPONENTS})

# the source files
file(GLOB SOURCE_FILES
        "src/*.cpp"
        "src/binding/rapid_json_serializer.cpp"
        "src/binding/rapid_json_serializer.h"
        "include/*.h"
        "thirdparty/nonstd/*.hpp"
        "thirdparty/nonstd/*.h"
        "thirdparty/nonstd/*.cpp"
        "thirdparty/nonstd/*.c"
)

list(APPEND PublicHeaders
        include/jinja2cpp/polymorphic_value.h
        include/jinja2cpp/generic_list_iterator.h
        include/jinja2cpp/string_helpers.h
        include/jinja2cpp/generic_list_impl.h
        include/jinja2cpp/reflected_value.h
        include/jinja2cpp/value_ptr.h
        include/jinja2cpp/binding/rapid_json.h
        include/jinja2cpp/error_handler.h
        include/jinja2cpp/utils/i_comparable.h
        include/jinja2cpp/user_callable.h
        include/jinja2cpp/error_info.h
        include/jinja2cpp/template_env.h
        include/jinja2cpp/template.h
        include/jinja2cpp/config.h
        include/jinja2cpp/filesystem_handler.h
        include/jinja2cpp/value.h
        include/jinja2cpp/generic_list.h)

if(STATIC)
    add_library(jinja2cppmedium STATIC
            ${SOURCE_FILES}
            ${RESOURCES}
    )
else()
    add_library(jinja2cppmedium SHARED
            ${SOURCE_FILES}
            ${RESOURCES}
    )
endif()

# find_package(FmtMeta 8.0.0 REQUIRED)

set_target_properties(jinja2cppmedium PROPERTIES
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_VERSION})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
target_include_directories(jinja2cppmedium PUBLIC
        include/
        thirdparty/
        ${Boost_INCLUDE_DIRS}
)

include(FetchContent)

FetchContent_Declare(
        fmt
        GIT_REPOSITORY https://github.com/fmtlib/fmt
        GIT_TAG        b6f4ceaed0a0a24ccf575fab6c56dd50ccf6f1a9) # 8.1.1
FetchContent_MakeAvailable(fmt)

if(OSXCROSS OR APPLE)
    target_compile_definitions(jinja2cppmedium PRIVATE BOOST_NO_CXX98_FUNCTION_BASE=1)
endif()

target_compile_definitions(jinja2cppmedium PRIVATE FMT_HEADER_ONLY=1)

# "$<LINK_LIBRARY:WHOLE_ARCHIVE,fmt::fmt,Boost::system,Boost::filesystem>"
# -Wl,--whole-archive fmt::fmt Boost::system Boost::filesystem -Wl,--no-whole-archive
target_link_libraries(jinja2cppmedium
        fmt::fmt-header-only
        ${Boost_LIBRARIES}
        ${CMAKE_DL_LIBS}
        ${STATIC_LIBS}
)

# install library
include(GNUInstallDirs)
install(TARGETS jinja2cppmedium
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# install library headers
install(DIRECTORY "${CMAKE_SOURCE_DIR}/include/jinja2cpp"
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
        FILES_MATCHING
        PATTERN "*.h"
)
install(DIRECTORY "${CMAKE_SOURCE_DIR}/thirdparty/nonstd"
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
        FILES_MATCHING
        PATTERN "*.hpp"
        PATTERN "*.h"
)

# install pkconfig helper
configure_file(jinja2cppmedium.pc.in jinja2cppmedium.pc @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/jinja2cppmedium.pc
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig)

# to build target 'test', requires -DCMAKE_INSTALL_PREFIX=/usr/local/jinja/
if(BUILD_EXAMPLE)
    #    add_executable(test example/main.cpp)
    #    target_link_libraries(test /usr/local/jinja/lib/libjinja2cppmedium.so)
    #    target_include_directories(test PUBLIC /usr/local/jinja/include/)
    #    add_dependencies(test jinja2cppmedium)
    #
    #    set_target_properties(test
    #            PROPERTIES
    #            LINK_FLAGS "-Wl,-rpath,$ORIGIN"
    #    )
    #    install(TARGETS test
    #            RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR})

    add_executable(test2 example/main.cpp example/fs_godot_mock.cpp example/fs_godot_mock.h)
    target_link_libraries(test2 jinja2cppmedium)
endif()

message(STATUS "BUILD TYPE: ${CMAKE_BUILD_TYPE}")
message(STATUS "INSTALL PREFIX: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "STATIC: ${STATIC}")
message(STATUS "[+] Boost")
message(STATUS "  - version: ${Boost_VERSION}")
message(STATUS "  - dirs: ${Boost_INCLUDE_DIRS}")
message(STATUS "  - libs: ${Boost_LIBRARIES}")
