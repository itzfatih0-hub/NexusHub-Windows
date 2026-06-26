# ============================================================
# CMakeLists.txt — NEXUS EXECUTOR C++ BUILD
# AUTHOR: PROFESOR_FATIH + NEXUS 1.0
# ============================================================

cmake_minimum_required(VERSION 3.10)
project(NexusExecutor)

# ============================================================
# SET C++ STANDARD
# ============================================================
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ============================================================
# CONFIGURATION
# ============================================================
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# ============================================================
# INCLUDE DIRECTORIES
# ============================================================
include_directories(
    ${CMAKE_SOURCE_DIR}/core
    ${CMAKE_SOURCE_DIR}/injector
    ${CMAKE_SOURCE_DIR}/memory
    ${CMAKE_SOURCE_DIR}/hooks
    ${CMAKE_SOURCE_DIR}/utils
)

# ============================================================
# SOURCE FILES
# ============================================================
set(SOURCES
    main.cpp
    core/executor.cpp
    injector/injector.cpp
    memory/memory.cpp
    hooks/hooks.cpp
    utils/utils.cpp
)

set(HEADERS
    core/executor.h
    injector/injector.h
    memory/memory.h
    hooks/hooks.h
    utils/utils.h
)

# ============================================================
# EXECUTABLE (Console)
# ============================================================
add_executable(nexus_core ${SOURCES} ${HEADERS})

# ============================================================
# LINK LIBRARIES
# ============================================================
target_link_libraries(nexus_core
    user32
    kernel32
    advapi32
    shell32
)

# ============================================================
# DLL (Injector) — OPSIONAL
# ============================================================
# add_library(nexus_injector SHARED
#     injector/injector.cpp
#     injector/injector.h
# )
# 
# target_link_libraries(nexus_injector)
# set_target_properties(nexus_injector PROPERTIES
#     PREFIX ""
#     SUFFIX ".dll"
#     OUTPUT_NAME "nexus_injector"
# )

# ============================================================
# COMPILE OPTIONS
# ============================================================
target_compile_options(nexus_core PRIVATE
    /W4           # Warning level 4
    /MT           # Statically link runtime (untuk standalone)
)

# Untuk release build
set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type")

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(nexus_core PRIVATE
        /O2           # Optimize for speed
        /GL           # Whole program optimization
    )
    set_target_properties(nexus_core PROPERTIES
        LINK_FLAGS "/LTCG" # Link-time code generation
    )
endif()

# ============================================================
# POST-BUILD COMMAND (Copy to bin folder)
# ============================================================
add_custom_command(TARGET nexus_core POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:nexus_core>
        ${CMAKE_SOURCE_DIR}/../bin/
    COMMENT "Copying executable to bin folder..."
)

# ============================================================
# MESSAGE
# ============================================================
message("")
message("========================================")
message("NEXUS EXECUTOR — C++ BUILD")
message("Build Type: ${CMAKE_BUILD_TYPE}")
message("Executable: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/nexus_core.exe")
message("========================================")
message("")