# Use CPack only if its cmake script exists
IF(NOT EXISTS "${CMAKE_ROOT}/Modules/CPack.cmake")
  MESSAGE(WARNING "${CMAKE_ROOT}/Modules/CPack.cmake does not exist")
  RETURN()
ENDIF()

SET(CPACK_PACKAGE_NAME "Elmer")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Open Source Finite Element Software for Multiphysical Problems")

SET(CPACK_PACKAGE_DESCRIPTION "Elmer is an open source multiphysical
simulation software mainly developed by CSC - IT Center for Science (CSC).
Elmer development was started 1995 in collaboration with Finnish
Universities, research institutes and industry. After it's open source
publication in 2005, the use and development of Elmer has become
international.

Elmer includes physical models of fluid dynamics, structural mechanics,
electromagnetics, heat transfer and acoustics, for example. These are
described by partial differential equations which Elmer solves by the Finite
Element Method (FEM).")

SET(CPACK_PACKAGE_VERSION_MAJOR "${ELMER_FEM_MAJOR_VERSION}")
SET(CPACK_PACKAGE_VERSION_MINOR "${ELMER_FEM_MINOR_VERSION}")
SET(CPACK_PACKAGE_VERSION_PATCH "${ELMER_FEM_REVISION}")

#SET(CPACK_PACKAGE_FILE_NAME "elmerfem-${ELMER_FEM_MAJOR_VERSION}.${ELMER_FEM_MINOR_VERSION}_${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
IF(${CMAKE_VERSION} VERSION_GREATER 2.8.11)
  STRING(TIMESTAMP DATE "%Y%m%d")
ELSE()
  MESSAGE(WARNING "cmake ${CMAKE_VERSION} does not support STRING(TIMESTAMP ...)")
ENDIF()

SET(CPACK_PACKAGE_BASE_FILE_NAME "elmerfem" CACHE STRING "")
MARK_AS_ADVANCED(CPACK_PACKAGE_BASE_FILE_NAME)
SET(CPACK_PACKAGE_VENDOR "CSC")
SET(CPACK_PACKAGE_VERSION "${ELMER_FEM_MAJOR_VERSION}.${ELMER_FEM_MINOR_VERSION}-${CPACK_PACKAGE_VERSION_PATCH}")
SET(CPACK_PACKAGE_CONTACT "elmeradm@csc.fi")
IF(CPACK_PACKAGE_FILE_NAME STREQUAL "")
  SET(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_BASE_FILE_NAME}-${CPACK_PACKAGE_VERSION}-${DATE}_${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}" CACHE STRING "" FORCE)
ELSE()
  SET(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_BASE_FILE_NAME}-${CPACK_PACKAGE_VERSION}-${DATE}_${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}" CACHE STRING "")
ENDIF(CPACK_PACKAGE_FILE_NAME STREQUAL "")

SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/license_texts/LICENSES_GPL.txt") 

MESSAGE(STATUS "------------------------------------------------")
MESSAGE(STATUS "  Package filename: ${CPACK_PACKAGE_FILE_NAME} ")
MESSAGE(STATUS "  Patch version: ${CPACK_PACKAGE_VERSION} ")

IF(NOT(BYPASS_DEB_DEPENDENCIES))
  SET(CPACK_DEBIAN_PACKAGE_DEPENDS "libblas-dev, liblapack-dev")

  MACRO(ADD_DEBIAN_DEPENDENCY WITH_RULE DEPS)
    IF(${WITH_RULE})
      LIST(APPEND DEP_LIST ${DEPS})
    ENDIF(${WITH_RULE})
  ENDMACRO()

  ADD_DEBIAN_DEPENDENCY(WITH_MPI "openmpi-bin")
  ADD_DEBIAN_DEPENDENCY(WITH_Mumps "libmumps-4.10.0")
  ADD_DEBIAN_DEPENDENCY(WITH_Hypre "libhypre-2.8.0b")
  ADD_DEBIAN_DEPENDENCY(WITH_ELMERGUI "libqt4-opengl")
  ADD_DEBIAN_DEPENDENCY(WITH_ELMERGUILOGGER "libqt4-core")
  ADD_DEBIAN_DEPENDENCY(WITH_ELMERGUITESTER "libqt4-core")
  ADD_DEBIAN_DEPENDENCY(WITH_OCC "liboce-foundation" "liboce-modeling8")
  ADD_DEBIAN_DEPENDENCY(WITH_PARAVIEW "paraview")
  ADD_DEBIAN_DEPENDENCY(WITH_VTK "libvtk5.8-qt4" "libvtk5.8")
  ADD_DEBIAN_DEPENDENCY(WITH_QWT "libqwt6")
  
  FOREACH(arg ${DEP_LIST})
    SET(CPACK_DEBIAN_PACKAGE_DEPENDS "${CPACK_DEBIAN_PACKAGE_DEPENDS}, ${arg}")
  ENDFOREACH()
ENDIF()

IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
  MARK_AS_ADVANCED(MAKE_DEB_PACKAGE MAKE_RPM_PACKAGE MAKE_TGZ_PACKAGE)
  #MESSAGE(STATUS "DEB package dependencies ${CPACK_DEBIAN_PACKAGE_DEPENDS}")
  SET(MAKE_DEB_PACKAGE TRUE CACHE BOOL "Create DEB package with cpack")
  SET(MAKE_RPM_PACKAGE TRUE CACHE BOOL "Create RPM package with cpack")
  SET(MAKE_TGZ_PACKAGE TRUE CACHE BOOL "Create TGZ package with cpack")
  IF(MAKE_TGZ_PACKAGE)
    LIST(APPEND CPACK_GENERATOR TGZ)
  ENDIF()
  IF(MAKE_DEB_PACKAGE)
    LIST(APPEND CPACK_GENERATOR DEB)
  ENDIF()
  IF(MAKE_RPM_PACKAGE)  # @TODO: untested
    SET(CPACK_GENERATOR "${CPACK_GENERATOR};RPM")
  ENDIF()
ENDIF()

IF(CMAKE_SYSTEM_NAME MATCHES "Windows")
  MARK_AS_ADVANCED(MAKE_NSIS_PACKAGE MAKE_ZIP_PACKAGE CPACK_BUNDLE_EXTRA_WINDOWS_DLLS)
  SET(MAKE_ZIP_PACKAGE TRUE CACHE BOOL "Create windows .zip file")
  SET(MAKE_NSIS_PACKAGE TRUE CACHE BOOL "Create windows installer executable")
  SET(CPACK_BUNDLE_EXTRA_WINDOWS_DLLS TRUE CACHE BOOL "Bundle dlls in windows install.")

  IF(CPACK_BUNDLE_EXTRA_WINDOWS_DLLS)
    INSTALL(FILES ${LAPACK_LIBRARIES} DESTINATION "bin")
    IF(NOT(LAPACK_LIB))
      FIND_FILE(LAPACK_LIB liblapack.dll PATH_SUFFIXES "bin")
    ENDIF()
    IF(NOT(BLAS_LIB))
      FIND_FILE(BLAS_LIB libblas.dll PATH_SUFFIXES "bin")
    ENDIF()

    # mingw runtime dynamic link libraries
    FIND_FILE(QUADMATH_LIB libquadmath-0.dll)
    FIND_FILE(WINPTHREAD_LIB libwinpthread-1.dll)
    FIND_FILE(STDCPP_LIB libstdc++-6.dll)
#if 1
    FIND_FILE(MINGW_GFORT_LIB libgfortran-5.dll)
    FIND_FILE(GCC_LIB libgcc_s_seh-1.dll)
    FIND_FILE(DBL_LIB libdouble-conversion.dll)
    FIND_FILE(GMP_LIB libgmp-10.dll)
    FIND_FILE(Z1_LIB zlib1.dll)
    INSTALL(FILES ${MINGW_GFORT_LIB} ${QUADMATH_LIB} ${WINPTHREAD_LIB} ${GCC_LIB} ${STDCPP_LIB} ${BLAS_LIB} ${LAPACK_LIB} ${DBL_LIB} ${GMP_LIB} ${Z1_LIB} DESTINATION "bin")
#else
    FIND_FILE(MINGW_GFORT_LIB libgfortran-3.dll)
    FIND_FILE(GCC_LIB libgcc_s_sjlj-1.dll)
    INSTALL(FILES ${MINGW_GFORT_LIB} ${QUADMATH_LIB} ${WINPTHREAD_LIB} ${GCC_LIB} ${STDCPP_LIB} ${BLAS_LIB} ${LAPACK_LIB} DESTINATION "bin")
#endif

# Here we augment the installation by some needed dll's that should be included with QT5. 
# This is a quick and dirty remedy. I'm sure there is a prettier way too. 
    IF(WITH_QT5)
	  FIND_FILE(QTF0 tbb.dll)
	  FIND_FILE(QTF1 libbz2-1.dll)
      FIND_FILE(QTF2 libfreetype-6.dll)
	  FIND_FILE(QTF3 libglib-2.0-0.dll)
	  FIND_FILE(QTF4 libgraphite2.dll)
	  FIND_FILE(QTF5 libharfbuzz-0.dll)
	  FIND_FILE(QTF6 libiconv-2.dll)
	  FIND_FILE(QTF7 libicudt65.dll)
	  FIND_FILE(QTF8 libicuin65.dll)
	  FIND_FILE(QTF9 libicuuc65.dll)
	  FIND_FILE(QTF10 libintl-8.dll)
	  FIND_FILE(QTF11 libpcre-1.dll)
	  FIND_FILE(QTF12 libpcre2-16-0.dll)
	  FIND_FILE(QTF13 libpng16-16.dll)
	  FIND_FILE(QTF14 libzstd.dll)
      INSTALL(FILES ${QTF0} ${QTF1} ${QTF2} ${QTF3} ${QTF4} ${QTF5} ${QTF6} ${QTF7} ${QTF8} ${QTF9} ${QTF10} ${QTF11} ${QTF12} ${QTF13} ${QTF14} DESTINATION "bin")
      INSTALL(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../platforms" DESTINATION "bin")
	ENDIF()
    IF(WITH_VTK)
      INSTALL(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../bundle_vtk/bin" DESTINATION ".")
    ENDIF()

    IF(BUNDLE_STRIPPED_GFORTRAN)
      # TODO: This will make the windows package to be GPL3
      INSTALL(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../stripped_gfortran" DESTINATION "." COMPONENT "stripped_gfortran")
      SET(CPACK_COMPONENT_STRIPPED_GFORTRAN_DESCRIPTION "A stripped version of x86_64-w64-mingw32-gfortran 9.2.0 compiler for compiling Elmer modules.")
      SET(CPACK_COMPONENT_STRIPPED_GFORTRAN_DISPLAY_NAME "gfortran 9.2.0")
    ENDIF()

    IF(WITH_MPI)
      IF(BUNDLE_MSMPI_REDIST)
        INSTALL(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../msmpi_redist/msmpisetup.exe" DESTINATION "redist" COMPONENT "MS_MPI_Redistributable")
# these are for Microsoft C++ (not needed for gcc/gfortan)
#        INSTALL(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../msmpi_redist/vcredist_x64.exe" DESTINATION "redist" COMPONENT "MS_MPI_Redistributable")
#        INSTALL(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../msmpi_redist/vcredist_x86.exe" DESTINATION "redist" COMPONENT "MS_MPI_Redistributable")
        SET(CPACK_COMPONENT_MS_MPI_REDISTRIBUTABLE_DESCRIPTION "Install MS-MPI 10.1.1. Redistributable Package")
        SET(CPACK_COMPONENT_MS_MPI_REDISTRIBUTABLE_DISPLAY_NAME "MS-MPI")
        LIST(APPEND CPACK_NSIS_EXTRA_INSTALL_COMMANDS "
        IfFileExists '$INSTDIR\\\\redist\\\\msmpisetup.exe' MSMpiSetupExists MsMpiSetupNotExist
        MsMpiSetupExists:
#        ExecWait '$INSTDIR\\\\redist\\\\vcredist_x64.exe'
#        ExecWait '$INSTDIR\\\\redist\\\\vcredist_x86.exe'
        ExecWait '$INSTDIR\\\\redist\\\\msmpisetup.exe'
        MsMpiSetupNotExist:
        ")
      ENDIF()
    ENDIF()
  ENDIF()

  IF(MAKE_NSIS_PACKAGE)
    SET(CPACK_GENERATOR "NSIS")
  ENDIF()
  IF(MAKE_ZIP_PACKAGE)
    SET(CPACK_GENERATOR "${CPACK_GENERATOR};ZIP")
  ENDIF()

  IF(MAKE_NSIS_PACKAGE)
    INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/cpack/NSISCPack.cmake)
  ENDIF()
ENDIF()


SET(CPACK_INSTALL_CMAKE_PROJECTS "${CMAKE_BINARY_DIR}" "Elmer" "ALL" "/")

IF(WITH_ELMERGUI)
  SET(CPACK_PACKAGE_EXECUTABLES "ElmerGUI" "ElmerGUI")
  SET(CPACK_CREATE_DESKTOP_LINKS "ElmerGUI")
ENDIF(WITH_ELMERGUI)

IF(WITH_ELMERPOST)
  SET(CPACK_PACKAGE_EXECUTABLES ${CPACK_PACKAGE_EXECUTABLES} "ElmerPost" "ElmerPost")
ENDIF()

IF(WITH_ELMERGUITESTER)
  SET(CPACK_PACKAGE_EXECUTABLES ${CPACK_PACKAGE_EXECUTABLES} "ElmerGUItester" "ElmerGUItester")
ENDIF(WITH_ELMERGUITESTER)

IF(WITH_ELMERGUILOGGER)
  SET(CPACK_PACKAGE_EXECUTABLES ${CPACK_PACKAGE_EXECUTABLES} "ElmerGUIlogger" "ElmerGUIlogger")
ENDIF(WITH_ELMERGUILOGGER)

INCLUDE(CPack)
