# This list is required for static linking and exported to PelotonConfig.cmake
set(Beeri_LINKER_LIBS "")

# ---[ Threads
find_package(Threads REQUIRED)
list(APPEND Beeri_LINKER_LIBS ${CMAKE_THREAD_LIBS_INIT})

# ---[ Google-protobuf
# include(cmake/ProtoBuf.cmake)

# ---[ Libevent
find_package(Libevent REQUIRED)
include_directories(SYSTEM ${LIBEVENT_INCLUDE_DIRS})
list(APPEND Beeri_LINKER_LIBS ${LIBEVENT_LIBRARIES})

# ---[ Doxygen
if(BUILD_docs)
  find_package(Doxygen)
endif()

# ---[ Sanitizers
if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")   
   include(Sanitizer)
   list(APPEND Beeri_LINKER_LIBS "-ltsan")
endif()

# --[ Valgrind
find_program(MEMORYCHECK_COMMAND valgrind)
set(MEMORYCHECK_COMMAND_OPTIONS "--trace-children=yes --leak-check=full")
set(MEMORYCHECK_SUPPRESSIONS_FILE "${PROJECT_SOURCE_DIR}/third_party/valgrind/valgrind.supp")

include("cmake/External/gflags.cmake")
include("cmake/External/glog.cmake")

include_directories(SYSTEM ${GLOG_INCLUDE_DIRS})

#find_package(GFlags REQUIRED)

# --[ IWYU

# Generate clang compilation database
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(PythonInterp REQUIRED)
find_program(iwyu_tool_path NAMES "${PROJECT_SOURCE_DIR}/third_party/iwyu/iwyu_tool.py")

add_custom_target(iwyu
    COMMAND "${PYTHON_EXECUTABLE}" "${iwyu_tool_path}" -p "${CMAKE_BINARY_DIR}"
    COMMENT "Running include-what-you-use tool"
    VERBATIM
)
