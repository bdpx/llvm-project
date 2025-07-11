find_first_existing_vc_file("${LLVM_MAIN_SRC_DIR}" llvm_vc)
find_first_existing_vc_file("${BOLT_SOURCE_DIR}" bolt_vc)

# The VC revision include that we want to generate.
set(version_inc "${CMAKE_CURRENT_BINARY_DIR}/VCSVersion.inc")

set(generate_vcs_version_script "${LLVM_CMAKE_DIR}/GenerateVersionFromVCS.cmake")

if(llvm_vc AND LLVM_APPEND_VC_REV)
  set(llvm_source_dir ${LLVM_MAIN_SRC_DIR})
endif()
if(LLVM_VC_REPOSITORY AND LLVM_VC_REVISION)
  set(llvm_source_dir ${LLVM_SOURCE_DIR})
  set(llvm_vc_repository ${LLVM_VC_REPOSITORY})
  set(llvm_vc_revision ${LLVM_VC_REVISION})
endif()
if(bolt_vc AND LLVM_APPEND_VC_REV)
  set(bolt_source_dir ${BOLT_SOURCE_DIR})
endif()

# Create custom target to generate the VC revision include.
add_custom_command(OUTPUT "${version_inc}"
  DEPENDS "${llvm_vc}" "${bolt_vc}" "${generate_vcs_version_script}"
  COMMAND ${CMAKE_COMMAND} "-DNAMES=BOLT"
                           "-DLLVM_SOURCE_DIR=${llvm_source_dir}"
                           "-DBOLT_SOURCE_DIR=${bolt_source_dir}"
                           "-DHEADER_FILE=${version_inc}"
                           "-DLLVM_VC_REPOSITORY=${llvm_vc_repository}"
                           "-DLLVM_VC_REVISION=${llvm_vc_revision}"
                           "-DLLVM_FORCE_VC_REVISION=${LLVM_FORCE_VC_REVISION}"
                           "-DLLVM_FORCE_VC_REPOSITORY=${LLVM_FORCE_VC_REPOSITORY}"
                           -P "${generate_vcs_version_script}")

# Mark the generated header as being generated.
set_source_files_properties("${version_inc}"
  PROPERTIES GENERATED TRUE
             HEADER_FILE_ONLY TRUE)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_llvm_library(LLVMBOLTUtils
  CommandLineOpts.cpp
  Utils.cpp
  ${version_inc}

  NO_EXPORT
  DISABLE_LLVM_LINK_LLVM_DYLIB

  LINK_LIBS
  ${LLVM_PTHREAD_LIB}

  LINK_COMPONENTS
  Support
  )
