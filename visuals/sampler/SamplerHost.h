#include <stddef.h>
#include <stdint.h>
int64_t sampler_process_start_millis(int32_t pid);
/* Kernel readback, not AppKit's run-loop-dependent running-application cache. */
int sampler_process_executable(int32_t pid, char *destination, size_t capacity);
