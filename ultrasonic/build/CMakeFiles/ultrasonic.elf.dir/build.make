# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.29

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = D:/avr_tools/cmake-3.29.2-windows-x86_64/bin/cmake.exe

# The command to remove a file.
RM = D:/avr_tools/cmake-3.29.2-windows-x86_64/bin/cmake.exe -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = D:/avr_workspace/ultrasonic

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = D:/avr_workspace/ultrasonic/build

# Include any dependencies generated for this target.
include CMakeFiles/ultrasonic.elf.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/ultrasonic.elf.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/ultrasonic.elf.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/ultrasonic.elf.dir/flags.make

CMakeFiles/ultrasonic.elf.dir/main.c.obj: CMakeFiles/ultrasonic.elf.dir/flags.make
CMakeFiles/ultrasonic.elf.dir/main.c.obj: D:/avr_workspace/ultrasonic/main.c
CMakeFiles/ultrasonic.elf.dir/main.c.obj: CMakeFiles/ultrasonic.elf.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green --progress-dir=D:/avr_workspace/ultrasonic/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/ultrasonic.elf.dir/main.c.obj"
	D:/avr_tools/avr_gcc_8bit/bin/avr-gcc.exe $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -MD -MT CMakeFiles/ultrasonic.elf.dir/main.c.obj -MF CMakeFiles/ultrasonic.elf.dir/main.c.obj.d -o CMakeFiles/ultrasonic.elf.dir/main.c.obj -c D:/avr_workspace/ultrasonic/main.c

CMakeFiles/ultrasonic.elf.dir/main.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Preprocessing C source to CMakeFiles/ultrasonic.elf.dir/main.c.i"
	D:/avr_tools/avr_gcc_8bit/bin/avr-gcc.exe $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E D:/avr_workspace/ultrasonic/main.c > CMakeFiles/ultrasonic.elf.dir/main.c.i

CMakeFiles/ultrasonic.elf.dir/main.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Compiling C source to assembly CMakeFiles/ultrasonic.elf.dir/main.c.s"
	D:/avr_tools/avr_gcc_8bit/bin/avr-gcc.exe $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S D:/avr_workspace/ultrasonic/main.c -o CMakeFiles/ultrasonic.elf.dir/main.c.s

# Object files for target ultrasonic.elf
ultrasonic_elf_OBJECTS = \
"CMakeFiles/ultrasonic.elf.dir/main.c.obj"

# External object files for target ultrasonic.elf
ultrasonic_elf_EXTERNAL_OBJECTS =

ultrasonic.elf: CMakeFiles/ultrasonic.elf.dir/main.c.obj
ultrasonic.elf: CMakeFiles/ultrasonic.elf.dir/build.make
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green --bold --progress-dir=D:/avr_workspace/ultrasonic/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable ultrasonic.elf"
	D:/avr_tools/avr_gcc_8bit/bin/avr-gcc.exe -g -mmcu=atmega128a -flto -fuse-linker-plugin -lm -Wl,-Map=ultrasonic.map,--cref -Wl,--gc-sections -Xlinker -print-memory-usage $(ultrasonic_elf_OBJECTS) $(ultrasonic_elf_EXTERNAL_OBJECTS) -o ultrasonic.elf
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold "Invoking: Make Hex"
	D:/avr_tools/avr_gcc_8bit/bin/avr-objcopy -O ihex -R .eeprom ultrasonic.elf ultrasonic.hex
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold "Invoking: Make EEPROM"
	D:/avr_tools/avr_gcc_8bit/bin/avr-objcopy -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 ultrasonic.elf ultrasonic.eep

# Rule to build all files generated by this target.
CMakeFiles/ultrasonic.elf.dir/build: ultrasonic.elf
.PHONY : CMakeFiles/ultrasonic.elf.dir/build

CMakeFiles/ultrasonic.elf.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/ultrasonic.elf.dir/cmake_clean.cmake
.PHONY : CMakeFiles/ultrasonic.elf.dir/clean

CMakeFiles/ultrasonic.elf.dir/depend:
	$(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" D:/avr_workspace/ultrasonic D:/avr_workspace/ultrasonic D:/avr_workspace/ultrasonic/build D:/avr_workspace/ultrasonic/build D:/avr_workspace/ultrasonic/build/CMakeFiles/ultrasonic.elf.dir/DependInfo.cmake "--color=$(COLOR)"
.PHONY : CMakeFiles/ultrasonic.elf.dir/depend
