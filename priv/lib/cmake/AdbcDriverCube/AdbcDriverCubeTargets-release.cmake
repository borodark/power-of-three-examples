#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "AdbcDriverCube::adbc_driver_cube_shared" for configuration "Release"
set_property(TARGET AdbcDriverCube::adbc_driver_cube_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(AdbcDriverCube::adbc_driver_cube_shared PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libadbc_driver_cube.so.107.0.0"
  IMPORTED_SONAME_RELEASE "libadbc_driver_cube.so.107"
  )

list(APPEND _cmake_import_check_targets AdbcDriverCube::adbc_driver_cube_shared )
list(APPEND _cmake_import_check_files_for_AdbcDriverCube::adbc_driver_cube_shared "${_IMPORT_PREFIX}/lib/libadbc_driver_cube.so.107.0.0" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
