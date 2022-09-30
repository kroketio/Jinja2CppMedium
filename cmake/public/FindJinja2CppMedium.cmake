# - Try to find Jinja2CppMedium
# Once done, this will define
#
#  Jinja2CppMedium_FOUND - system has Jinja2CppMedium
#  Jinja2CppMedium_INCLUDE_DIRS - the include directories
#  Jinja2CppMedium_LIBRARIES - link these to use Jinja2CppMedium

find_package(PkgConfig)

pkg_check_modules(PC_J2MED QUIET libjinja2cppmedium)
set(J2MED_DEFINITIONS ${PC_J2MED_CFLAGS_OTHER})

find_path(J2MED_INCLUDE_DIR jinja2cpp/template.h
        HINTS ${PC_J2MED_INCLUDEDIR} ${PC_J2MED_INCLUDE_DIRS}
        PATH_SUFFIXES jinja2cpp )

find_library(J2MED_LIBRARY NAMES jinja2cppmedium libjinja2cppmedium
        HINTS ${PC_J2MED_LIBDIR} ${PC_J2MED_LIBRARY_DIRS} )

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set Jinja2CppMedium_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(Jinja2CppMedium DEFAULT_MSG
        J2MED_LIBRARY J2MED_INCLUDE_DIR)

mark_as_advanced(J2MED_INCLUDE_DIR J2MED_LIBRARY )

set(Jinja2CppMedium_LIBRARIES ${J2MED_LIBRARY} )
set(Jinja2CppMedium_INCLUDE_DIRS ${J2MED_INCLUDE_DIR} )
