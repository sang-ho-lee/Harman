# CMAKE generated file: DO NOT EDIT!
# Generated by CMake Version 3.29
cmake_policy(SET CMP0009 NEW)

# SRC_FILES at CMakeLists.txt:11 (file)
file(GLOB NEW_GLOB LIST_DIRECTORIES true "D:/avr_workspace/ultrasonic/*.c")
set(OLD_GLOB
  "D:/avr_workspace/ultrasonic/main.c"
  )
if(NOT "${NEW_GLOB}" STREQUAL "${OLD_GLOB}")
  message("-- GLOB mismatch!")
  file(TOUCH_NOCREATE "D:/avr_workspace/ultrasonic/build/CMakeFiles/cmake.verify_globs")
endif()

# SRC_FILES at CMakeLists.txt:11 (file)
file(GLOB NEW_GLOB LIST_DIRECTORIES true "D:/avr_workspace/ultrasonic/.cpp")
set(OLD_GLOB
  )
if(NOT "${NEW_GLOB}" STREQUAL "${OLD_GLOB}")
  message("-- GLOB mismatch!")
  file(TOUCH_NOCREATE "D:/avr_workspace/ultrasonic/build/CMakeFiles/cmake.verify_globs")
endif()

# SRC_FILES_RECURSE at CMakeLists.txt:17 (file)
file(GLOB_RECURSE NEW_GLOB LIST_DIRECTORIES false "D:/avr_workspace/ultrasonic/src/*.cpp")
set(OLD_GLOB
  )
if(NOT "${NEW_GLOB}" STREQUAL "${OLD_GLOB}")
  message("-- GLOB mismatch!")
  file(TOUCH_NOCREATE "D:/avr_workspace/ultrasonic/build/CMakeFiles/cmake.verify_globs")
endif()

# SRC_FILES_RECURSE at CMakeLists.txt:17 (file)
file(GLOB_RECURSE NEW_GLOB LIST_DIRECTORIES false "D:/avr_workspace/ultrasonic/src/.c")
set(OLD_GLOB
  )
if(NOT "${NEW_GLOB}" STREQUAL "${OLD_GLOB}")
  message("-- GLOB mismatch!")
  file(TOUCH_NOCREATE "D:/avr_workspace/ultrasonic/build/CMakeFiles/cmake.verify_globs")
endif()
