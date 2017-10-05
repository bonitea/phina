# Locate libraries for Beast
# ================================

set(FIND_Beast_NAME "Beast")

# ### Usage

# The simplest way to use this module is to find and then link.

# ```
# find_package(???? REQUIRED)
# target_link_libraries(${PROJECT_NAME} ????)
# ```

# The first line finds the specified CMake module -- this file.
# The CMake module usually exports a CMake library interface.
# The interface defines, for example, paths of include directories
#   and libraries necessary to use the library.
# When linking to the interface as in the second line,
#   paths defined by the interface are then be linked to the project.
# It is typically the same as the following.

# ```
# find_package(???? REQUIRED)
# target_include_directories(
#   ${PROJECT_NAME}
#   PUBLIC ${????_INCLUDE_DIRS}
# )
# target_link_libraries(
#   ${PROJECT_NAME}
#   PUBLIC ${????_LIBRARIES}
# )
# ```

# The variables `$INCLUDE_DIRS` and `$LIBRARIES`
#   are paths of headers and libraries
#   of the library and possibly dependencies.
# It might be possible to replace them by `$INCLUDE_DIR` and `$LIBRARY`
#   for more control over what is checked by the compiler and linker.
# However, these two variables may not always exist
#   depending on the library.
# For example, a header-only library may not have a `$LIBRARY`
#   and a CMake module that simply groups libraries under one module
#   may not have its own `$INCLUDE_DIR`.

# ### Finding required paths

# The `$INSTALL_PREFIX` path defines a root directory
#   in which this library may be installed.
# It usually contains the `include` and `lib` subdirectories.
# This is optional, for finding custom built libraries.
# System libraries are found by CMake by default without hints.
find_path(Beast_INSTALL_PREFIX
  NAMES include/beast/version.hpp
        include/boost/beast/version.hpp
  HINTS extlib/beast
        # If all projects are subdirectories of a root directory,
        #   for example `$HOME/src`,
        #   then the parent of `$SHOME_DIRECTORY`
        #   might contain the repo for this library.
        "${CMAKE_HOME_DIRECTORY}/../beast"
  DOC "${FIND_Beast_NAME} install directory"
)

# The path to the actual include directory.
find_path(Beast_INCLUDE_DIR
  NAMES beast/version.hpp
        boost/beast/version.hpp
  HINTS ${Beast_INSTALL_PREFIX}
  PATH_SUFFIXES include
  DOC "${FIND_Beast_NAME} include directory"
)

# ### Exporting paths

# The following defines paths and CMake interface of this library.
# The interface allows the library to be used with just two lines.
# Both paths and interface start with the settings for this library
#   and then dependencies are added.
add_library(Beast INTERFACE)
target_include_directories(Beast INTERFACE ${Beast_INCLUDE_DIR})
list(APPEND Beast_INCLUDE_DIRS ${Beast_INCLUDE_DIR})

# Uses Boost system.
find_package(Boost 1.58 REQUIRED COMPONENTS system)
target_link_libraries(Beast INTERFACE Boost::system)
list(APPEND Beast_INCLUDE_DIRS ${Boost_INCLUDE_DIRS})
list(APPEND Beast_LIBRARIES ${Boost_LIBRARIES})

# Uses SSL
find_package(OpenSSL 1.0.0 REQUIRED)
target_link_libraries(Beast INTERFACE OpenSSL::SSL)
list(APPEND Beast_INCLUDE_DIRS ${OPENSSL_INCLUDE_DIR})
list(APPEND Beast_LIBRARIES ${OPENSSL_LIBRARIES})

# Uses threads.
find_package(Threads REQUIRED)
target_link_libraries(Beast INTERFACE Threads::Threads)
list(APPEND Beast_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
