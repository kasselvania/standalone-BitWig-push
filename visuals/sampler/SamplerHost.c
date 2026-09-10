#include "SamplerHost.h"
#include <libproc.h>
#include <sys/proc_info.h>
#include <unistd.h>
#include <string.h>

int64_t sampler_process_start_millis(int32_t pid) {
    struct proc_bsdinfo info;
    if (proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &info, sizeof(info)) != sizeof(info) ||
        info.pbi_uid != getuid()) return -1;
    return (int64_t)info.pbi_start_tvsec * 1000 + info.pbi_start_tvusec / 1000;
}

int sampler_process_executable(int32_t pid, char *destination, size_t capacity) {
    if (!destination || capacity < PROC_PIDPATHINFO_MAXSIZE || capacity > UINT32_MAX) return 0;
    memset(destination, 0, capacity);
    const int size = proc_pidpath(pid, destination, (uint32_t)capacity);
    return size > 0 && (size_t)size < capacity && destination[size] == 0;
}
