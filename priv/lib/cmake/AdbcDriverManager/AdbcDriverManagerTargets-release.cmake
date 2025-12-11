#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "AdbcDriverManager::adbc_driver_manager_shared" for configuration "Release"
set_property(TARGET AdbcDriverManager::adbc_driver_manager_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(AdbcDriverManager::adbc_driver_manager_shared PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libadbc_driver_manager.so.107.0.0"
  IMPORTED_SONAME_RELEASE "libadbc_driver_manager.so.107"
  )

list(APPEND _cmake_import_check_targets AdbcDriverManager::adbc_driver_manager_shared )
list(APPEND _cmake_import_check_files_for_AdbcDriverManager::adbc_driver_manager_shared "${_IMPORT_PREFIX}/lib/libadbc_driver_manager.so.107.0.0" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
