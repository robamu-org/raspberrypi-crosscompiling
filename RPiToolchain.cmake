if(NOT DEFINED ENV{RASPBERRY_VERSION})
	message(STATUS "Raspberry Pi version not specified, setting version 4!")
	set(RASPBERRY_VERSION 4)
else()
	set(RASPBERRY_VERSION $ENV{RASPBERRY_VERSION})
endif()


# RASPBIAN_ROOTFS should point to the local directory which contains all the 
# libraries and includes from the target raspi.
# The following command can be used to do this, replace <ip-address> and the
# local <rootfs-path> accordingly:
# rsync -vR --progress -rl --delete-after --safe-links pi@<ip-address>:/{lib,usr,opt/vc/lib} <rootfs-path>
# RASPBIAN_ROOTFS needs to be passed to the CMake command or defined in the
# application CMakeLists.txt before loading the toolchain file.

# CROSS_COMPILE also needs to be set accordingly or passed to the CMake command

if(NOT DEFINED ENV{RASPBIAN_ROOTFS})
	message(FATAL_ERROR 
		"Define the RASPBIAN_ROOTFS variable to point to the Raspberry Pi rootfs."
	)
else()
	set(SYSROOT_PATH "$ENV{RASPBIAN_ROOTFS}")
	message(STATUS "Raspberry Pi sysroot: ${SYSROOT_PATH}")
endif()

if(NOT DEFINED ENV{CROSS_COMPILE})
	set(CROSS_COMPILE "arm-linux-gnueabihf")
	message(STATUS 
		"No CROSS_COMPILE environmental variable set, using default ARM linux "
		"cross compiler name ${CROSS_COMPILE}"
	)
else()
	set(CROSS_COMPILE "$ENV{CROSS_COMPILE}")
	message(STATUS 
		"Using environmental variable CROSS_COMPILE as cross-compiler: "
		"$ENV{CROSS_COMPILE}"
	)
endif()

message(STATUS "Using sysroot path: ${SYSROOT_PATH}")

set(CROSS_COMPILE_CC "${CROSS_COMPILE}-gcc")
set(CROSS_COMPILE_CXX "${CROSS_COMPILE}-g++")
set(CROSS_COMPILE_LD "${CROSS_COMPILE}-ld")
set(CROSS_COMPILE_AR "${CROSS_COMPILE}-ar")
set(CROSS_COMPILE_RANLIB "${CROSS_COMPILE}-ranlib")
set(CROSS_COMPILE_STRIP "${CROSS_COMPILE}-strip")
set(CROSS_COMPILE_NM "${CROSS_COMPILE}-nm")
set(CROSS_COMPILE_OBJCOPY "${CROSS_COMPILE}-objcopy")
set(CROSS_COMPILE_SIZE "${CROSS_COMPILE}-size")

# At the very least, cross compile gcc and g++ have to be set!
find_program (CROSS_COMPILE_CC_FOUND ${CROSS_COMPILE_CC} REQUIRED)
find_program (CROSS_COMPILE_CXX_FOUND ${CROSS_COMPILE_CXX} REQUIRED)

set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_SYSROOT "${SYSROOT_PATH}")

# Define name of the target system
set(CMAKE_SYSTEM_NAME "Linux")
if(RASPBERRY_VERSION VERSION_GREATER 1)
	set(CMAKE_SYSTEM_PROCESSOR "armv7")
else()
	set(CMAKE_SYSTEM_PROCESSOR "arm")
endif()

# Define the compiler
set(CMAKE_C_COMPILER ${CROSS_COMPILE_CC})
set(CMAKE_CXX_COMPILER ${CROSS_COMPILE_CXX})

# List of library dirs where LD has to look. Pass them directly through gcc. 
# LD_LIBRARY_PATH is not evaluated by arm-*-ld
set(LIB_DIRS 
	"/opt/cross-pi-gcc/arm-linux-gnueabihf/lib"
	"/opt/cross-pi-gcc/lib"
	"${SYSROOT_PATH}/opt/vc/lib"
	"${SYSROOT_PATH}/lib/${CROSS_COMPILE}"
	"${SYSROOT_PATH}/usr/local/lib"
	"${SYSROOT_PATH}/usr/lib/${CROSS_COMPILE}"
	"${SYSROOT_PATH}/usr/lib"
	"${SYSROOT_PATH}/usr/lib/${CROSS_COMPILE}/blas"
	"${SYSROOT_PATH}/usr/lib/${CROSS_COMPILE}/lapack"
)
# You can additionally check the linker paths if you add the 
# flags ' -Xlinker --verbose'
set(COMMON_FLAGS "-I${SYSROOT_PATH}/usr/include")
foreach(LIB ${LIB_DIRS})
	set(COMMON_FLAGS "${COMMON_FLAGS} -L${LIB} -Wl,-rpath-link,${LIB}")
endforeach()

set(CMAKE_PREFIX_PATH 
	"${CMAKE_PREFIX_PATH}"
	"${SYSROOT_PATH}/usr/lib/${CROSS_COMPILE}"
)

if(RASPBERRY_VERSION VERSION_GREATER 3)
	set(CMAKE_C_FLAGS 
		"-mcpu=cortex-a72 -mfpu=neon-vfpv4 -mfloat-abi=hard ${COMMON_FLAGS}" 
		CACHE STRING "Flags for Raspberry PI 4"
	)
	set(CMAKE_CXX_FLAGS 
		"${CMAKE_C_FLAGS}" 
		CACHE STRING "Flags for Raspberry PI 4"
	)
elseif(RASPBERRY_VERSION VERSION_GREATER 2)
	set(CMAKE_C_FLAGS 
		"-mcpu=cortex-a53 -mfpu=neon-vfpv4 -mfloat-abi=hard ${COMMON_FLAGS}" 
		CACHE STRING "Flags for Raspberry PI 3"
	)
	set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" 
		CACHE STRING "Flags for Raspberry PI 3"
	)
elseif(RASPBERRY_VERSION VERSION_GREATER 1)
	set(CMAKE_C_FLAGS 
		"-mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard ${COMMON_FLAGS}" 
		CACHE STRING "Flags for Raspberry PI 2"
	)
	set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" 
		CACHE STRING "Flags for Raspberry PI 2"
	)
else()
	set(CMAKE_C_FLAGS 
		"-mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard ${COMMON_FLAGS}" 
		CACHE STRING "Flags for Raspberry PI 1 B+ Zero"
	)
	set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" 
		CACHE STRING "Flags for Raspberry PI 1 B+ Zero"
	)
endif()

set(CMAKE_FIND_ROOT_PATH 
	"${CMAKE_INSTALL_PREFIX};${CMAKE_PREFIX_PATH};${CMAKE_SYSROOT}"
)


# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
