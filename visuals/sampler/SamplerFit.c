#include "SamplerFit.h"
#include <libswscale/swscale.h>
#include <libavutil/pixfmt.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
struct SamplerFit { struct SwsContext *scaler; uint8_t output[484 * 114 * 4]; };
SamplerFit *sampler_fit_create(void) { return calloc(1, sizeof(SamplerFit)); }
void sampler_fit_destroy(SamplerFit *fit) {
    if (fit) { sws_freeContext(fit->scaler); memset(fit, 0, sizeof(*fit)); free(fit); }
}
const uint8_t *sampler_fit_frame(SamplerFit *fit, const uint8_t *source, size_t length,
    int width, int height, int stride, int x, int y, int cw, int ch) {
    if (!fit || !source || width < 1 || height < 1 || width > 8192 || height > 4320 ||
        stride < width * 4 || stride > 8192 * 4 + 4096 ||
        length < (size_t)(height - 1) * stride + width * 4 ||
        x < 0 || y < 0 || cw < 1 || ch < 1 || cw > width || ch > height ||
        x > width - cw || y > height - ch) return NULL;
    const double scale = fmin(484.0 / cw, 114.0 / ch);
    // Uniform fit followed by raster rounding: less than one destination pixel loss per axis.
    const int dw = (int)floor(cw * scale + 1e-9), dh = (int)floor(ch * scale + 1e-9);
    if (dw < 1 || dh < 1) return NULL;
    fit->scaler = sws_getCachedContext(fit->scaler, cw, ch, AV_PIX_FMT_BGR0,
        dw, dh, AV_PIX_FMT_BGRA, SWS_LANCZOS, NULL, NULL, NULL);
    if (!fit->scaler) return NULL;
    memset(fit->output, 0, sizeof(fit->output));
    const uint8_t *src[4] = {source + (size_t)y * stride + x * 4, NULL, NULL, NULL};
    int src_stride[4] = {stride, 0, 0, 0};
    uint8_t *dst[4] = {fit->output + ((114 - dh) / 2 * 484 + (484 - dw) / 2) * 4, NULL, NULL, NULL};
    int dst_stride[4] = {484 * 4, 0, 0, 0};
    if (sws_scale(fit->scaler, src, src_stride, 0, ch, dst, dst_stride) != dh) return NULL;
    for (size_t i = 3; i < sizeof(fit->output); i += 4) fit->output[i] = 255;
    return fit->output;
}
