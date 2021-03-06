cmake_minimum_required(VERSION 2.8)
project(poprig)

option(WITH_LIBCPUID "Use Libcpuid" ON)
option(WITH_HTTPD    "HTTP REST API" OFF)
option(BUILD_STATIC  "Build static binary" OFF)

option(WITH_HASHRATE "for UI" OFF)

if (CMAKE_BUILD_TYPE MATCHES Debug)
    message(STATUS "debug enable")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 -ggdb")
endif()

include (CheckIncludeFile)
include (cmake/cpu.cmake)

set(HEADERS
    src/api/Api.h
    src/api/ApiState.h
    src/api/NetworkState.h
    src/App.h
    src/Console.h
    src/Cpu.h
    src/interfaces/IClientListener.h
    src/interfaces/IConsoleListener.h
    src/interfaces/IJobResultListener.h
    src/interfaces/ILogBackend.h
    src/interfaces/IStrategy.h
    src/interfaces/IStrategyListener.h
    src/interfaces/IWorker.h
    src/log/ConsoleLog.h
    src/log/FileLog.h
    src/log/Log.h
    src/Mem.h
    src/net/Client.h
    src/net/Id.h
    src/net/Job.h
    src/net/JobResult.h
    src/net/Network.h
    src/net/strategies/DonateStrategy.h
    src/net/strategies/FailoverStrategy.h
    src/net/strategies/SinglePoolStrategy.h
    src/net/SubmitResult.h
    src/net/Url.h
    src/Options.h
    src/Platform.h
    src/Summary.h
    src/version.h
    src/workers/DoubleWorker.h
    src/workers/Handle.h
    src/workers/Hashrate.h
    src/workers/SingleWorker.h
    src/workers/Worker.h
    src/workers/Workers.h
    src/poprig.h
   )


set(SOURCES
    src/api/Api.cpp
    src/api/ApiState.cpp
    src/api/NetworkState.cpp
    src/App.cpp
    src/Console.cpp
    src/log/ConsoleLog.cpp
    src/log/FileLog.cpp
    src/log/Log.cpp
    src/Mem.cpp
    src/net/Client.cpp
    src/net/Job.cpp
    src/net/Network.cpp
    src/net/strategies/DonateStrategy.cpp
    src/net/strategies/FailoverStrategy.cpp
    src/net/strategies/SinglePoolStrategy.cpp
    src/net/SubmitResult.cpp
    src/net/Url.cpp
    src/Options.cpp
    src/Platform.cpp
    src/Summary.cpp
    src/workers/DoubleWorker.cpp
    src/workers/Handle.cpp
    src/workers/Hashrate.cpp
    src/workers/SingleWorker.cpp
    src/workers/Worker.cpp
    src/workers/Workers.cpp
    src/poprig.cpp
   )

if (WIN32)
    set(SOURCES_OS
        res/app.rc
        src/App_win.cpp
        src/Cpu_win.cpp
        src/Mem_win.cpp
        src/Platform_win.cpp
        )

    add_definitions(/DWIN32)
    set(EXTRA_LIBS ws2_32 psapi iphlpapi userenv)
    
    if (WITH_HASHRATE)
        message("WITH_HASHRATE")
        add_definitions(/DWIN32_HASHRATE)
    endif()
elseif (APPLE)
    set(SOURCES_OS
        src/App_unix.cpp
        src/Cpu_mac.cpp
        src/Mem_unix.cpp
        src/Platform_mac.cpp
        )
else()
    set(SOURCES_OS
        src/App_unix.cpp
        src/Cpu_unix.cpp
        src/Mem_unix.cpp
        src/Platform_unix.cpp
        )

    set(EXTRA_LIBS pthread rt )
endif()

if (CMAKE_SYSTEM_NAME STREQUAL FreeBSD)
    set(EXTRA_LIBS ${EXTRA_LIBS} kvm)
endif()

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    EXECUTE_PROCESS(COMMAND uname -o COMMAND tr -d '\n' OUTPUT_VARIABLE OPERATING_SYSTEM)
    if (OPERATING_SYSTEM MATCHES "Android")
        set(EXTRA_LIBS ${EXTRA_LIBS} log)
    endif()
endif()

add_definitions(/D__STDC_FORMAT_MACROS)
add_definitions(/DUNICODE)
#add_definitions(/DAPP_DEBUG)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

find_package(UV REQUIRED)

include(cmake/flags.cmake)

if (WITH_LIBCPUID)
    add_subdirectory(src/3rdparty/libcpuid)

    include_directories(src/3rdparty/libcpuid)
    set(CPUID_LIB cpuid)
    set(SOURCES_CPUID src/Cpu.cpp)
else()
    add_definitions(/DPOPRIG_NO_LIBCPUID)

    if (POPRIG_ARM)
        set(SOURCES_CPUID src/Cpu_arm.cpp)
    else()
        set(SOURCES_CPUID src/Cpu_stub.cpp)
    endif()
endif()

CHECK_INCLUDE_FILE (syslog.h HAVE_SYSLOG_H)
if (HAVE_SYSLOG_H)
    add_definitions(/DHAVE_SYSLOG_H)
    set(SOURCES_SYSLOG src/log/SysLog.h src/log/SysLog.cpp)
endif()

if (WITH_HTTPD)
    find_package(MHD)

    if (MHD_FOUND)
        message("with httpd!")
        include_directories(${MHD_INCLUDE_DIRS})
        set(HTTPD_SOURCES src/api/Httpd.h src/api/Httpd.cpp)
        if (UNIX)
            set(EXTRA_LIBS ${EXTRA_LIBS} -lgnutls -lgcrypt)
        endif()
    else()
        message(FATAL_ERROR "microhttpd NOT found: use `-DWITH_HTTPD=OFF` to build without http deamon support")
    endif()
else()
    set(MHD_LIBRARY "")
    add_definitions(/DPOPRIG_NO_HTTPD)
    add_definitions(/DPOPRIG_NO_API)
endif()

include_directories(src)
include_directories(src/crypto)
include_directories(src/3rdparty)
include_directories(${UV_INCLUDE_DIR})

include_directories ("${PROJECT_SOURCE_DIR}/src/crypto")
add_subdirectory(src/crypto)
set(EXTRA_LIBS ${EXTRA_LIBS} cryptoPop)

if (BUILD_STATIC)
    set(CMAKE_EXE_LINKER_FLAGS " -static")
endif()

add_executable(poprig ${HEADERS} ${SOURCES} ${SOURCES_OS} ${SOURCES_CPUID} ${SOURCES_SYSLOG} ${HTTPD_SOURCES})
target_link_libraries(poprig ${UV_LIBRARIES} ${MHD_LIBRARY} ${EXTRA_LIBS} ${CPUID_LIB})
