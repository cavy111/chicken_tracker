cmake_minimum_required(VERSION 3.14)
project(chicken_tracker LANGUAGES CXX)

# Define the application target. Flutter will replace the values with the actual
# application name and build settings.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Generated plugin build rules, which manage building the plugins and the
# rest of the application.
include(flutter/generated_plugins.cmake)

# === Installation ===
# Support files are copied into place next to the executable, so that it can
# run in place. This is done instead of making a separate bundle (an app bundle
# on macOS, an app folder on Linux) that should be moved in place.
# To make your app relocatable, you'll need to configure the build to copy
# the needed data files with the executable instead.
set(BUILD_BUNDLE true)
if(BUILD_BUNDLE)
  # Add the application as a install target.
  install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})
  # These are needed for the executable to run correctly.
  install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION ${CMAKE_INSTALL_PREFIX})
  install(FILES "${FLUTTER_LIBRARY}" DESTINATION ${CMAKE_INSTALL_PREFIX})
  if(PLUGIN_BUNDLED_LIBRARIES)
    install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
      DESTINATION ${CMAKE_INSTALL_PREFIX})
  endif()

  # Fully re-copy the assets directory on each build to avoid having stale files
  # from a previous install.
  set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
  install(CODE "
    file(REMOVE_RECURSE \"${CMAKE_INSTALL_PREFIX}/${FLUTTER_ASSET_DIR_NAME}\")
    " COMPONENT Runtime)
  install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
    DESTINATION ${CMAKE_INSTALL_PREFIX} COMPONENT Runtime)
endif()
