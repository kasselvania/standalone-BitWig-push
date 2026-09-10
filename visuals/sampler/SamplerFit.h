#include <stddef.h>
#include <stdint.h>
typedef struct SamplerFit SamplerFit;
int64_t sampler_process_start_millis(int32_t pid);
SamplerFit *sampler_fit_create(void);
void sampler_fit_destroy(SamplerFit *fit);
/* Synchronous borrowed top-down BGR0 input. Returned storage belongs to fit, until next call. */
const uint8_t *sampler_fit_frame(SamplerFit *fit, const uint8_t *source, size_t length,
    int width, int height, int stride, int x, int y, int crop_width, int crop_height);
