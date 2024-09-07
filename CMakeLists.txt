cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(pythonx C CXX)

if(NOT DEFINED CMAKE_BUILD_TYPE OR "${CMAKE_BUILD_TYPE}" STREQUAL "")
    set(CMAKE_BUILD_TYPE "Release")
endif()

if(NOT DEFINED PRIV_DIR)
    if(DEFINED MIX_APP_PATH AND NOT "${MIX_APP_PATH}" STREQUAL "")
        set(PRIV_DIR "${MIX_APP_PATH}/priv")
    else()
        set(PRIV_DIR "${CMAKE_CURRENT_SOURCE_DIR}/priv")
    endif()
endif()
message(STATUS "Using PRIV_DIR: ${PRIV_DIR}")

if(DEFINED ERTS_INCLUDE_DIR AND NOT "${ERTS_INCLUDE_DIR}" STREQUAL "")
    set(ERTS_INCLUDE_DIR "${ERTS_INCLUDE_DIR}")
else()
    set(ERTS_INCLUDE_DIR_ONE_LINER "erl -noshell -eval \"io:format('~ts/erts-~ts/include/', [code:root_dir(), erlang:system_info(version)]), halt().\"")
    if(WIN32)
        execute_process(COMMAND powershell -command "${ERTS_INCLUDE_DIR_ONE_LINER}" OUTPUT_VARIABLE ERTS_INCLUDE_DIR)
    else()
        execute_process(COMMAND bash -c "${ERTS_INCLUDE_DIR_ONE_LINER}" OUTPUT_VARIABLE ERTS_INCLUDE_DIR)
    endif()
    set(ERTS_INCLUDE_DIR "${ERTS_INCLUDE_DIR}")
endif()
message(STATUS "Using ERTS_INCLUDE_DIR: ${ERTS_INCLUDE_DIR}")

if(DEFINED C_SRC AND NOT "${C_SRC}" STREQUAL "")
    set(C_SRC "${C_SRC}")
else()
    set(C_SRC "${CMAKE_CURRENT_LIST_DIR}/c_src")
endif()

if(UNIX AND APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS "-flat_namespace -undefined suppress -undefined dynamic_lookup")
endif()

if(DEFINED ENV{TARGET_GCC_FLAGS})
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TARGET_GCC_FLAGS}")
    if(DEFINED ENV{TARGET_CPU})
        if("$ENV{TARGET_CPU}" STREQUAL "cortex_a53" OR "$ENV{TARGET_CPU}" STREQUAL "cortex_a57")
            string(REPLACE "neon-vfpv4" "neon-fp-armv8" TARGET_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
            set(CMAKE_CXX_FLAGS "${TARGET_CXX_FLAGS}")
        endif()
    endif()
endif()
if(DEFINED ENV{TARGET_ARCH})
    if(NOT "$ENV{TARGET_ARCH}" STREQUAL "arm")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DTF_HAS_vcvtaq_s32_f32")
    endif()
endif()

message(STATUS "CMAKE_TOOLCHAIN_FILE: ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
message(STATUS "CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "CMAKE_CXX_COMPILER_VERSION: ${CMAKE_CXX_COMPILER_VERSION}")

message(STATUS "Python3_ROOT_DIR: ${Python3_ROOT_DIR}")
# find_package(Python3 REQUIRED COMPONENTS Development)
set(Python3_INCLUDE_DIRS "${Python3_ROOT_DIR}/include/python3.${PYTHON3_VERSION_MINOR}")
set(Python3_LIBRARIES "${Python3_ROOT_DIR}/lib/libpython3.${PYTHON3_VERSION_MINOR}")
set(Python3_LIBRARY_DIRS "${Python3_ROOT_DIR}/lib")
message(STATUS "Python3_INCLUDE_DIRS: ${Python3_INCLUDE_DIRS}")
message(STATUS "Python3_LIBRARIES: ${Python3_LIBRARIES}")
message(STATUS "Python3_LIBRARY_DIRS: ${Python3_LIBRARY_DIRS}")

if(WIN32)
    string(REPLACE "\\" "/" C_SRC "${C_SRC}")
endif()
set(PYTHONX_SOURCE_FILES
    "${C_SRC}/pythonx.cpp"
)
set(CMAKE_CXX_STANDARD 17)
add_library(pythonx SHARED
    ${PYTHONX_SOURCE_FILES}
)
install(
    TARGETS pythonx
    DESTINATION "${PRIV_DIR}"
)
target_include_directories(pythonx PRIVATE "${Python3_INCLUDE_DIRS}" "${ERTS_INCLUDE_DIR}")
target_link_options(pythonx PRIVATE "${Python3_LINK_OPTIONS}")
target_link_directories(pythonx PRIVATE ${Python3_LIBRARY_DIRS})
target_link_libraries(pythonx "${Python3_LIBRARIES}")
set_property(TARGET pythonx PROPERTY CXX_STANDARD 17)
set_property(TARGET pythonx PROPERTY POSITION_INDEPENDENT_CODE ON)
set_target_properties(pythonx PROPERTIES PREFIX "")
if(NOT WIN32)
    set_target_properties(pythonx PROPERTIES SUFFIX ".so")
endif()
set_target_properties(pythonx PROPERTIES
    INSTALL_RPATH_USE_LINK_PATH TRUE
    BUILD_WITH_INSTALL_RPATH TRUE
)

if(UNIX AND NOT APPLE)
    set_target_properties(pythonx PROPERTIES INSTALL_RPATH "\$ORIGIN/python3/lib")
elseif(UNIX AND APPLE)
    # Although the compiler complains about not using these,
    # things only work with them set
    set(CMAKE_SHARED_LINKER_FLAGS "-flat_namespace -undefined dynamic_lookup")
    set_target_properties(pythonx PROPERTIES INSTALL_RPATH "@loader_path/python3")
endif()

# if(WIN32)
#     add_library(windows_fix SHARED
#         "${C_SRC}/windows_fix/windows_fix.cpp"
#     )
#     install(
#         TARGETS windows_fix
#         RUNTIME DESTINATION "${PRIV_DIR}"
#     )
#     set_property(TARGET windows_fix PROPERTY CXX_STANDARD 14)
#     set_property(TARGET windows_fix PROPERTY POSITION_INDEPENDENT_CODE ON)
#     set_target_properties(windows_fix PROPERTIES PREFIX "")
#     set_target_properties(windows_fix PROPERTIES
#         INSTALL_RPATH_USE_LINK_PATH TRUE
#         BUILD_WITH_INSTALL_RPATH TRUE
#     )
# endif()
