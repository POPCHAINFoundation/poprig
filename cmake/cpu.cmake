if (WITH_SYSTEM_PROCESSOR)
	set(CMAKE_SYSTEM_PROCESSOR ${WITH_SYSTEM_PROCESSOR})
endif()

if (NOT CMAKE_SYSTEM_PROCESSOR)
    message(WARNING "CMAKE_SYSTEM_PROCESSOR not defined")
else()
	message(STATUS "cmake system processor: ${CMAKE_SYSTEM_PROCESSOR}")
endif()


if (CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|AMD64)$")
    add_definitions(/DRAPIDJSON_SSE2)
endif()


if (CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64)$")
    set(POPRIG_ARM     ON)
    set(POPRIG_ARMv8   ON)
    set(WITH_LIBCPUID OFF)

    add_definitions(/DPOPRIG_ARM)
    add_definitions(/DPOPRIG_ARMv8)
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "^(armv7|armv7f|armv7s|armv7k|armv7-a|armv7l)$")
    set(POPRIG_ARM     ON)
    set(POPRIG_ARMv7   ON)
    set(WITH_LIBCPUID OFF)

    add_definitions(/DPOPRIG_ARM)
    add_definitions(/DPOPRIG_ARMv7)
endif()
