find_path(
    UV_INCLUDE_DIR
    NAMES uv.h
    PATHS "${POPRIG_DEPS}" ENV "POPRIG_DEPS"
    PATH_SUFFIXES "include"
    NO_DEFAULT_PATH
)

find_path(UV_INCLUDE_DIR NAMES uv.h)

find_library(
    UV_LIBRARY
    NAMES libuv uv libuv.a
    PATHS "${POPRIG_DEPS}" ENV "POPRIG_DEPS"
    PATH_SUFFIXES "lib"
    NO_DEFAULT_PATH
)

find_library(UV_LIBRARY NAMES libuv.a uv libuv)

set(UV_LIBRARIES ${UV_LIBRARY})
set(UV_INCLUDE_DIRS ${UV_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(UV DEFAULT_MSG UV_LIBRARY UV_INCLUDE_DIR)
