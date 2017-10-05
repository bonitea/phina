project(phina)
cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)

# ========
# Extra CMake find_package directory
list(APPEND CMAKE_MODULE_PATH  ${CMAKE_CURRENT_LIST_DIR}/cmake)

# ========
add_executable(${PROJECT_NAME}
  src/main.cpp
)

# Use C++14
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 14)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD_REQUIRED 14)

# Uses Boost Beast.
find_package(Beast REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC Beast)

install(TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}
  DESTINATION bin
)
