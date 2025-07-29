#ifndef __MY_COMMON_INCLUDED__
#define __MY_COMMON_INCLUDED__

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"

// add các define / macro / function that usually used here
InputData InitializeInputData(float3 worldPos, float3 normalWS, half3 viewDirWS)
{
    InputData inputData = (InputData)0;
    inputData.positionWS = worldPos;
    inputData.normalWS = normalWS;
    inputData.viewDirectionWS = viewDirWS;
    return inputData;
}
SurfaceData InitializeSurfaceData(half3 albedo, half alpha, half metallic, half smoothness)
{
    SurfaceData surfaceData = (SurfaceData)0;
    surfaceData.albedo = albedo;
    surfaceData.specular = 0;
    surfaceData.metallic = metallic;
    surfaceData.smoothness = smoothness;
    surfaceData.normalTS = 0;
    surfaceData.emission = 0;
    surfaceData.occlusion = 1;
    surfaceData.alpha = alpha;
    surfaceData.clearCoatMask = 0.0;
    surfaceData.clearCoatSmoothness = 0.0;
    return surfaceData;
}
#endif