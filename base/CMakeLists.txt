add_library(base init.cc logging.cc pthread_utils.cc walltime.cc)

if (DEFINED external_project_dependencies)
    add_dependencies(base ${external_project_dependencies})
endif()