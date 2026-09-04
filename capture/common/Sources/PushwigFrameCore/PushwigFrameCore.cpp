// Copyright (c) 2026 Standalone Bitwig Push contributors
// SPDX-License-Identifier: MIT

#include "PushwigFrameCore.h"

#include <algorithm>
#include <cmath>
#include <limits>

namespace {

bool multiply_fits(const size_t left, const size_t right, size_t *result) {
    if (left != 0 && right > std::numeric_limits<size_t>::max() / left) {
        return false;
    }
    *result = left * right;
    return true;
}

bool supported_input_format(const PWPixelFormat format) {
    return format == PW_PIXEL_FORMAT_OPAQUE_BGRA8888 ||
        format == PW_PIXEL_FORMAT_BGRA8888 ||
        format == PW_PIXEL_FORMAT_RGBA8888 ||
        format == PW_PIXEL_FORMAT_ARGB8888;
}

struct Pixel {
    double blue;
    double green;
    double red;
};

Pixel read_pixel(const PWRawFrame &frame, const uint32_t x, const uint32_t y) {
    const uint8_t *pixel = frame.bytes + static_cast<size_t>(y) * frame.stride +
        static_cast<size_t>(x) * 4;
    switch (frame.pixel_format) {
        case PW_PIXEL_FORMAT_OPAQUE_BGRA8888:
        case PW_PIXEL_FORMAT_BGRA8888:
            return {static_cast<double>(pixel[0]), static_cast<double>(pixel[1]),
                static_cast<double>(pixel[2])};
        case PW_PIXEL_FORMAT_RGBA8888:
            return {static_cast<double>(pixel[2]), static_cast<double>(pixel[1]),
                static_cast<double>(pixel[0])};
        case PW_PIXEL_FORMAT_ARGB8888:
            return {static_cast<double>(pixel[3]), static_cast<double>(pixel[2]),
                static_cast<double>(pixel[1])};
        default:
            return {0, 0, 0};
    }
}

uint8_t rounded_channel(const double value) {
    return static_cast<uint8_t>(std::clamp(std::lround(value), 0L, 255L));
}

} // namespace

bool pw_frame_source_descriptor_is_valid(const PWFrameSourceDescriptor *descriptor) {
    return descriptor != nullptr && descriptor->source_id != 0 &&
        descriptor->generation != 0 && descriptor->role != PW_SOURCE_ROLE_INVALID &&
        descriptor->width != 0 && descriptor->height != 0 &&
        supported_input_format(descriptor->pixel_format);
}

PWStatus pw_raw_frame_validate(const PWRawFrame *frame) {
    if (frame == nullptr || frame->source_id == 0 || frame->generation == 0 ||
        frame->sequence == 0 || frame->width == 0 || frame->height == 0 ||
        frame->bytes == nullptr || !frame->complete ||
        !supported_input_format(frame->pixel_format)) {
        return PW_STATUS_INVALID_FRAME;
    }
    size_t useful_row = 0;
    size_t required = 0;
    if (!multiply_fits(frame->width, static_cast<size_t>(4), &useful_row) ||
        frame->stride < useful_row ||
        !multiply_fits(frame->stride, frame->height, &required) ||
        frame->byte_capacity < required) {
        return PW_STATUS_INSUFFICIENT_INPUT;
    }
    return PW_STATUS_OK;
}

PWStatus pw_transform_to_opaque_bgra(
    const PWRawFrame *frame,
    const PWNormalizedCrop crop,
    const PWDestination destination,
    uint8_t *output,
    const size_t output_capacity,
    PWTransformResult *result) {
    const PWStatus validation = pw_raw_frame_validate(frame);
    if (validation != PW_STATUS_OK) {
        return validation;
    }
    if (!std::isfinite(crop.x) || !std::isfinite(crop.y) ||
        !std::isfinite(crop.width) || !std::isfinite(crop.height) ||
        crop.x < 0 || crop.y < 0 || crop.width <= 0 || crop.height <= 0 ||
        crop.x + crop.width > 1 || crop.y + crop.height > 1) {
        return PW_STATUS_INVALID_CROP;
    }
    size_t destination_row = 0;
    size_t destination_bytes = 0;
    if (destination.width == 0 || destination.height == 0 || output == nullptr ||
        !multiply_fits(destination.width, static_cast<size_t>(4), &destination_row) ||
        destination.stride < destination_row ||
        !multiply_fits(destination.stride, destination.height, &destination_bytes)) {
        return PW_STATUS_INVALID_DESTINATION;
    }
    if (output_capacity < destination_bytes) {
        return PW_STATUS_INSUFFICIENT_OUTPUT;
    }

    double source_x = crop.x * frame->width;
    double source_y = crop.y * frame->height;
    double source_width = crop.width * frame->width;
    double source_height = crop.height * frame->height;
    const double destination_aspect =
        static_cast<double>(destination.width) / destination.height;
    const double source_aspect = source_width / source_height;
    if (source_aspect > destination_aspect) {
        const double covered_width = source_height * destination_aspect;
        source_x += (source_width - covered_width) / 2;
        source_width = covered_width;
    } else if (source_aspect < destination_aspect) {
        const double covered_height = source_width / destination_aspect;
        source_y += (source_height - covered_height) / 2;
        source_height = covered_height;
    }

    const double scale_x = destination.width / source_width;
    const double scale_y = destination.height / source_height;
    const double uniform_scale = std::min(scale_x, scale_y);
    const uint32_t crop_min_x = std::min(
        static_cast<uint32_t>(std::floor(source_x)), frame->width - 1);
    const uint32_t crop_min_y = std::min(
        static_cast<uint32_t>(std::floor(source_y)), frame->height - 1);
    const uint32_t crop_max_x = std::min(
        static_cast<uint32_t>(std::ceil(source_x + source_width)) - 1,
        frame->width - 1);
    const uint32_t crop_max_y = std::min(
        static_cast<uint32_t>(std::ceil(source_y + source_height)) - 1,
        frame->height - 1);

    for (uint32_t destination_y = 0; destination_y < destination.height; ++destination_y) {
        uint8_t *destination_pixel = output +
            static_cast<size_t>(destination_y) * destination.stride;
        const double sample_y = std::clamp(
            source_y + (destination_y + 0.5) * source_height / destination.height - 0.5,
            static_cast<double>(crop_min_y), static_cast<double>(crop_max_y));
        const uint32_t y0 = std::clamp(
            static_cast<uint32_t>(std::floor(sample_y)), crop_min_y, crop_max_y);
        const uint32_t y1 = std::min(y0 + 1, crop_max_y);
        const double fy = sample_y - y0;
        for (uint32_t destination_x = 0; destination_x < destination.width; ++destination_x) {
            const double sample_x = std::clamp(
                source_x + (destination_x + 0.5) * source_width / destination.width - 0.5,
                static_cast<double>(crop_min_x), static_cast<double>(crop_max_x));
            const uint32_t x0 = std::clamp(
                static_cast<uint32_t>(std::floor(sample_x)), crop_min_x, crop_max_x);
            const uint32_t x1 = std::min(x0 + 1, crop_max_x);
            const double fx = sample_x - x0;
            const Pixel p00 = read_pixel(*frame, x0, y0);
            const Pixel p10 = read_pixel(*frame, x1, y0);
            const Pixel p01 = read_pixel(*frame, x0, y1);
            const Pixel p11 = read_pixel(*frame, x1, y1);
            const auto interpolate = [fx, fy](const double a, const double b,
                                              const double c, const double d) {
                return (a + (b - a) * fx) * (1 - fy) +
                    (c + (d - c) * fx) * fy;
            };
            destination_pixel[0] = rounded_channel(interpolate(
                p00.blue, p10.blue, p01.blue, p11.blue));
            destination_pixel[1] = rounded_channel(interpolate(
                p00.green, p10.green, p01.green, p11.green));
            destination_pixel[2] = rounded_channel(interpolate(
                p00.red, p10.red, p01.red, p11.red));
            destination_pixel[3] = 0xFF;
            destination_pixel += 4;
        }
    }

    if (result != nullptr) {
        result->effective_x = source_x;
        result->effective_y = source_y;
        result->effective_width = source_width;
        result->effective_height = source_height;
        result->uniform_scale = uniform_scale;
        result->pixels_written =
            static_cast<uint64_t>(destination.width) * destination.height;
    }
    return PW_STATUS_OK;
}

void pw_generation_gate_activate(
    PWGenerationGate *gate, const uint64_t source_id, const uint64_t generation) {
    if (gate == nullptr) {
        return;
    }
    gate->source_id = source_id;
    gate->generation = generation;
    gate->last_sequence = 0;
    gate->active = source_id != 0 && generation != 0;
}

void pw_generation_gate_deactivate(PWGenerationGate *gate) {
    if (gate != nullptr) {
        *gate = {};
    }
}

PWStatus pw_generation_gate_accept(PWGenerationGate *gate, const PWRawFrame *frame) {
    const PWStatus validation = pw_raw_frame_validate(frame);
    if (validation != PW_STATUS_OK) {
        return validation;
    }
    if (gate == nullptr || !gate->active || gate->source_id != frame->source_id ||
        gate->generation != frame->generation) {
        return PW_STATUS_STALE_GENERATION;
    }
    if (frame->sequence <= gate->last_sequence) {
        return PW_STATUS_STALE_SEQUENCE;
    }
    gate->last_sequence = frame->sequence;
    return PW_STATUS_OK;
}

void pw_latest_frame_clear(PWLatestFrameState *state) {
    if (state != nullptr) {
        *state = {};
    }
}

PWStatus pw_latest_frame_publish(PWLatestFrameState *state, const PWRawFrame *frame) {
    const PWStatus validation = pw_raw_frame_validate(frame);
    if (validation != PW_STATUS_OK) {
        return validation;
    }
    if (state == nullptr) {
        return PW_STATUS_INVALID_FRAME;
    }
    if (state->has_frame && state->source_id == frame->source_id &&
        state->generation == frame->generation && frame->sequence <= state->sequence) {
        return PW_STATUS_STALE_SEQUENCE;
    }
    state->source_id = frame->source_id;
    state->generation = frame->generation;
    state->sequence = frame->sequence;
    state->has_frame = true;
    return PW_STATUS_OK;
}
