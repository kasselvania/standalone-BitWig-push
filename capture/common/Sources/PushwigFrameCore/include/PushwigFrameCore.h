// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

#ifndef PUSHWIG_FRAME_CORE_H
#define PUSHWIG_FRAME_CORE_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum PWPixelFormat {
    PW_PIXEL_FORMAT_INVALID = 0,
    PW_PIXEL_FORMAT_OPAQUE_BGRA8888 = 1,
    PW_PIXEL_FORMAT_BGRA8888 = 2,
    PW_PIXEL_FORMAT_RGBA8888 = 3,
    PW_PIXEL_FORMAT_ARGB8888 = 4,
} PWPixelFormat;

typedef enum PWSourceRole {
    PW_SOURCE_ROLE_INVALID = 0,
    PW_SOURCE_ROLE_DISPLAY = 1,
    PW_SOURCE_ROLE_WINDOW = 2,
    PW_SOURCE_ROLE_GENERATED_FIXTURE = 3,
} PWSourceRole;

typedef struct PWFrameSourceDescriptor {
    uint64_t source_id;
    uint64_t generation;
    PWSourceRole role;
    uint32_t width;
    uint32_t height;
    PWPixelFormat pixel_format;
    bool interaction_safe;
    bool cursor_free_or_separable;
    bool supports_subregions;
    bool restartable;
    bool linux_path_available;
} PWFrameSourceDescriptor;

typedef struct PWRawFrame {
    uint64_t source_id;
    uint64_t generation;
    uint64_t sequence;
    uint64_t monotonic_timestamp_nanoseconds;
    uint32_t width;
    uint32_t height;
    size_t stride;
    PWPixelFormat pixel_format;
    bool complete;
    const uint8_t *bytes;
    size_t byte_capacity;
} PWRawFrame;

typedef struct PWNormalizedCrop {
    double x;
    double y;
    double width;
    double height;
} PWNormalizedCrop;

typedef struct PWDestination {
    uint32_t width;
    uint32_t height;
    size_t stride;
} PWDestination;

typedef struct PWTransformResult {
    double effective_x;
    double effective_y;
    double effective_width;
    double effective_height;
    double uniform_scale;
    uint64_t pixels_written;
} PWTransformResult;

typedef enum PWStatus {
    PW_STATUS_OK = 0,
    PW_STATUS_INVALID_DESCRIPTOR = 1,
    PW_STATUS_INVALID_FRAME = 2,
    PW_STATUS_INVALID_CROP = 3,
    PW_STATUS_INVALID_DESTINATION = 4,
    PW_STATUS_INSUFFICIENT_INPUT = 5,
    PW_STATUS_INSUFFICIENT_OUTPUT = 6,
    PW_STATUS_STALE_GENERATION = 7,
    PW_STATUS_STALE_SEQUENCE = 8,
} PWStatus;

typedef struct PWGenerationGate {
    uint64_t source_id;
    uint64_t generation;
    uint64_t last_sequence;
    bool active;
} PWGenerationGate;

typedef struct PWLatestFrameState {
    uint64_t source_id;
    uint64_t generation;
    uint64_t sequence;
    bool has_frame;
} PWLatestFrameState;

bool pw_frame_source_descriptor_is_valid(const PWFrameSourceDescriptor *descriptor);
PWStatus pw_raw_frame_validate(const PWRawFrame *frame);
PWStatus pw_transform_to_opaque_bgra(
    const PWRawFrame *frame,
    PWNormalizedCrop crop,
    PWDestination destination,
    uint8_t *output,
    size_t output_capacity,
    PWTransformResult *result);

void pw_generation_gate_activate(
    PWGenerationGate *gate, uint64_t source_id, uint64_t generation);
void pw_generation_gate_deactivate(PWGenerationGate *gate);
PWStatus pw_generation_gate_accept(PWGenerationGate *gate, const PWRawFrame *frame);

void pw_latest_frame_clear(PWLatestFrameState *state);
PWStatus pw_latest_frame_publish(PWLatestFrameState *state, const PWRawFrame *frame);

#ifdef __cplusplus
}
#endif

#endif
