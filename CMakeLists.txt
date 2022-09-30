cmake_minimum_required(VERSION 3.13)
project(jinja2cppmedium)
message(STATUS "Initiating compile using CMake ${CMAKE_VERSION}")

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_SOURCE_DIR}/cmake")
set(PROJECT_VERSION "0.1")


set(CMAKE_CXX_STANDARD 14)
include(FindCcache)

if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_SKIP_RPATH ON)
endif()

find_package(rapidjson REQUIRED)

if(STATIC)
    set(Boost_USE_STATIC_LIBS ON)
    set(Boost_USE_STATIC_RUNTIME ON)
endif()
if(MINGW)
    set(Boost_THREADAPI win32)
endif()
set(_BOOST_COMPONENTS system filesystem)
find_package(Boost 1.69 REQUIRED COMPONENTS ${_BOOST_COMPONENTS})

# the source files
file(GLOB SOURCE_FILES
        "src/*.cpp"
        "include/*.h"
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

add_library(jinja2cppmedium SHARED
        ${SOURCE_FILES}
        ${RESOURCES}
        )

find_package(fmt 8.0.0 REQUIRED)

set_target_properties(jinja2cppmedium PROPERTIES
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_VERSION})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${RAPIDJSON_CXX_FLAGS}")
target_include_directories(jinja2cppmedium PUBLIC
        include/
        ${RAPIDJSON_INCLUDE_DIRS}
        )

target_link_libraries(jinja2cppmedium
        fmt::fmt
        ${Boost_LIBRARIES}
        ${CMAKE_DL_LIBS}
        )

# install library
include(GNUInstallDirs)
install(TARGETS jinja2cppmedium
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

# install library headers
install(DIRECTORY "${CMAKE_SOURCE_DIR}/include/jinja2cpp"
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
        FILES_MATCHING
        PATTERN "*.h"
        )

# install pkconfig helper
configure_file(jinja2cppmedium.pc.in jinja2cppmedium.pc @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/jinja2cppmedium.pc
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig)

message(STATUS "[+] Boost")
message(STATUS "  - version: ${Boost_VERSION}")
message(STATUS "  - dirs: ${Boost_INCLUDE_DIRS}")
message(STATUS "  - libs: ${Boost_LIBRARIES}")
message(STATUS "[+] RapidJSON")
message(STATUS "  - dirs: ${RAPIDJSON_INCLUDE_DIRS}")
message(STATUS "[+] Fmt")
message(STATUS "  - version: ${fmt_VERSION}")
