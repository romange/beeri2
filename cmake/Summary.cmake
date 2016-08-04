################################################################################################
# Beeri status report function.
# Automatically align right column and selects text based on condition.
# Usage:
#   beeri_status(<text>)
#   beeri_status(<heading> <value1> [<value2> ...])
#   beeri_status(<heading> <condition> THEN <text for TRUE> ELSE <text for FALSE> )
function(beeri_status text)
  set(status_cond)
  set(status_then)
  set(status_else)

  set(status_current_name "cond")
  foreach(arg ${ARGN})
    if(arg STREQUAL "THEN")
      set(status_current_name "then")
    elseif(arg STREQUAL "ELSE")
      set(status_current_name "else")
    else()
      list(APPEND status_${status_current_name} ${arg})
    endif()
  endforeach()

  if(DEFINED status_cond)
    set(status_placeholder_length 23)
    string(RANDOM LENGTH ${status_placeholder_length} ALPHABET " " status_placeholder)
    string(LENGTH "${text}" status_text_length)
    if(status_text_length LESS status_placeholder_length)
      string(SUBSTRING "${text}${status_placeholder}" 0 ${status_placeholder_length} status_text)
    elseif(DEFINED status_then OR DEFINED status_else)
      message(STATUS "${text}")
      set(status_text "${status_placeholder}")
    else()
      set(status_text "${text}")
    endif()

    if(DEFINED status_then OR DEFINED status_else)
      if(${status_cond})
        string(REPLACE ";" " " status_then "${status_then}")
        string(REGEX REPLACE "^[ \t]+" "" status_then "${status_then}")
        message(STATUS "${status_text} ${status_then}")
      else()
        string(REPLACE ";" " " status_else "${status_else}")
        string(REGEX REPLACE "^[ \t]+" "" status_else "${status_else}")
        message(STATUS "${status_text} ${status_else}")
      endif()
    else()
      string(REPLACE ";" " " status_cond "${status_cond}")
      string(REGEX REPLACE "^[ \t]+" "" status_cond "${status_cond}")
      message(STATUS "${status_text} ${status_cond}")
    endif()
  else()
    message(STATUS "${text}")
  endif()
endfunction()


################################################################################################
# Function for fetching Beeri version from git and headers
# Usage:
#   beeri_extract_beeri_version()
function(beeri_extract_beeri_version)
  set(Beeri_GIT_VERSION "unknown")
  find_package(Git)
  if(GIT_FOUND)
    execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
                    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE
                    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
                    OUTPUT_VARIABLE Beeri_GIT_VERSION
                    RESULT_VARIABLE __git_result)
    if(NOT ${__git_result} EQUAL 0)
      set(Beeri_GIT_VERSION "unknown")
    endif()
  endif()

  set(Beeri_GIT_VERSION ${Beeri_GIT_VERSION} PARENT_SCOPE)
  set(Beeri_VERSION "<TODO> (Beeri doesn't declare its version in headers)" PARENT_SCOPE)
endfunction()


################################################################################################
# Prints accumulated beeri configuration summary
# Usage:
#   beeri_print_configuration_summary()

function(beeri_print_configuration_summary)
  beeri_extract_beeri_version()
  set(Beeri_VERSION ${Beeri_VERSION} PARENT_SCOPE)

  beeri_merge_flag_lists(__flags_rel CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS)
  beeri_merge_flag_lists(__flags_deb CMAKE_CXX_FLAGS_DEBUG   CMAKE_CXX_FLAGS)

  beeri_status("")
  beeri_status("******************* Beeri Configuration Summary *******************")
  beeri_status("General:")
  beeri_status("  Version           :   ${BEERI_TARGET_VERSION}")
  beeri_status("  Git               :   ${Beeri_GIT_VERSION}")
  beeri_status("  System            :   ${CMAKE_SYSTEM_NAME}")
  beeri_status("  Compiler          :   ${CMAKE_CXX_COMPILER} (${COMPILER_FAMILY} ${COMPILER_VERSION})")
  beeri_status("  Release CXX flags :   ${__flags_rel}")
  beeri_status("  Debug CXX flags   :   ${__flags_deb}")
  beeri_status("  Build type        :   ${CMAKE_BUILD_TYPE}")
  beeri_status("")
  beeri_status("  BUILD_docs        :   ${BUILD_docs}")
  beeri_status("")
  beeri_status("Dependencies:")
  beeri_status("  Linker flags      :   ${CMAKE_EXE_LINKER_FLAGS}")
  beeri_status("  Boost             :   Yes (ver. ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION})")
  beeri_status("  glog              : " GLOG_FOUND THEN "Yes (ver. ${GLOG_VERSION})" ELSE "No")
  beeri_status("  gflags            : " GFLAGS_FOUND THEN "Yes (ver. ${GFLAGS_VERSION})" ELSE "No")
  beeri_status("  protobuf          : " PROTOBUF_FOUND THEN "Yes (ver. ${PROTOBUF_VERSION})" ELSE "No")
  beeri_status("")
  if(BUILD_docs)
    beeri_status("Documentaion:")
    beeri_status("  Doxygen           :" DOXYGEN_FOUND THEN "${DOXYGEN_EXECUTABLE} (${DOXYGEN_VERSION})" ELSE "No")
    beeri_status("  config_file       :   ${DOXYGEN_config_file}")

    beeri_status("")
  endif()
  beeri_status("Install:")
  beeri_status("  Install path      :   ${CMAKE_INSTALL_PREFIX}")
  beeri_status("")
endfunction()
