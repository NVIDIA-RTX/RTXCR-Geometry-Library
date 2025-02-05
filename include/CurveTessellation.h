/*
 * Copyright (c) 2024-2025, NVIDIA CORPORATION.  All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto.  Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */

namespace rtxcr::geometry
{
    struct Vertex
    {
        float position[3] = {};
        float radius = 0.0f;
        float texCoord[2] = {};
    };

    struct LineSegment
    {
        unsigned int geometryIndex = 0;
        Vertex vertices[2] = {};
    };
}
