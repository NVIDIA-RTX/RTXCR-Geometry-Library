/*
 * Copyright (c) 2024-2025, NVIDIA CORPORATION.  All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto.  Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */

#pragma once

// The MIT License
// Copyright � 2018 Inigo Quilez
/*
Permission is hereby granted, free of charge, 
to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
The above copyright notice and this permission notice shall be included in all copies 
or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

// This version forked and modified from IQ's rounded cone https://www.shadertoy.com/view/MlKfzm

// Intersection of a ray and an infinite cone oriented in an arbitrary direction
// List of ray-surface intersectors at https://www.shadertoy.com/playlist/l3dXRf
// and https://iquilezles.org/articles/intersectors

float4 IntersectInfiniteCone(float3 ro, float3 rd, float3 pa, float3 pb, float ra, float rb)
{
    // Move ray origin closer to the cone to minimize floating-point arithmetic issues
    // Method inspired by Ray Tracing Gems II, chapter 34
    float3 oa = ro - pa;
    float tOffset = -dot(rd, oa);
    float3 roOffset = tOffset * rd;
    oa = ro + roOffset - pa;

    float3 ba = pb - pa;
    float rr = ra - rb;
    float m0 = dot(ba, ba);
    float m1 = dot(ba, oa);
    float m2 = dot(ba, rd);
    float m3 = dot(rd, oa);
    float m5 = dot(oa, oa);

    float d2 = m0 - rr * rr;

    float k2 = d2      - m2 * m2;
    float k1 = d2 * m3 - m1 * m2 + m2 * rr * ra;
    float k0 = d2 * m5 - m1 * m1 + m1 * rr * ra * 2.0f - m0 * ra * ra;

    float h = k1 * k1 - k0 * k2;
    if (h < 0.0f)
    {
        return float(0xDEADBEEF);
    }

    float t = (-sqrt(h) - k1) / k2;
    if(t + tOffset < 0.0f)
    {
        return float(0xDEADBEEF);
    }

    float y = m1 - ra * rr + t * m2;
    float3 hP = d2 * (oa + t * rd); // hit point
    float3 aP = ba * y;             // axis point with same U param as hit point
    float3 normal = normalize(hP - aP);
    return float4(t + tOffset, normal);
}

float3 AdjustGeometryNormalDOTS(float3 objectRayOrigin, float3 objectRayDirection, float3 objectCurveVertex0Pos, float3 objectCurveVertex1Pos, float curveRadius0, float curveRadius1)
{
    float4 hit = IntersectInfiniteCone(objectRayOrigin, objectRayDirection, objectCurveVertex0Pos, objectCurveVertex1Pos, curveRadius0, curveRadius1);

    float hitT = hit.x;
    float3 normal = hit.yzw;

    if (hitT != float(0xDEADBEEF))
    {
        return normal;
    }
    else
    {
        // Handle unsucessful ray/infinite cone intersection somewhat gracefully (shouldn't happen too often).
        return objectRayDirection;
    }
}
