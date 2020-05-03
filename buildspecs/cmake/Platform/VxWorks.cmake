set(VXWORKS 1)

include(Platform/GNU)

# override the property not applicable for VxWorks
unset(CMAKE_LIBRARY_ARCHITECTURE_REGEX)
set(CMAKE_DL_LIBS "")

foreach(type SHARED_LIBRARY SHARED_MODULE EXE)
    set(CMAKE_${type}_LINK_STATIC_C_FLAGS "-Wl,-Bstatic")
    set(CMAKE_${type}_LINK_DYNAMIC_C_FLAGS "-Wl,-Bdynamic")
endforeach()

# set VxWorks root
set(CMAKE_SYSTEM_PREFIX_PATH ${__VXWORKS_PREFIX_PATH__})

# set VxWorks header path
set(CMAKE_SYSTEM_INCLUDE_PATH ${__VXWORKS_INCLUDE_PATH__})

# set VxWorks library path
set(CMAKE_SYSTEM_LIBRARY_PATH ${__VXWORKS_LIBRARY_PATH__})
