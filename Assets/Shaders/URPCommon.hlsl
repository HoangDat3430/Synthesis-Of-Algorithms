#ifndef __MY_COMMON_INCLUDED__
#define __MY_COMMON_INCLUDED__

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"
// add các define / macro / function that usually used here
InputData InitializeInputData(float3 worldPos, float3 normalWS, half3 viewDirWS, half3 bakedGI)
{
    InputData inputData = (InputData)0;
    inputData.positionWS = worldPos;
    inputData.normalWS = normalWS;
    inputData.viewDirectionWS = viewDirWS;
    inputData.shadowCoord = TransformWorldToShadowCoord(worldPos);
    inputData.fogCoord = ComputeFogFactor(worldPos);
    inputData.bakedGI = bakedGI;
    return inputData;
}
SurfaceData InitializeSurfaceData(half3 albedo, half alpha, half metallic, half smoothness, half occlusion)
{
    SurfaceData surfaceData = (SurfaceData)0;
    surfaceData.albedo = albedo;
    surfaceData.alpha = alpha;
    surfaceData.metallic = metallic;
    surfaceData.smoothness = smoothness;
    surfaceData.normalTS = float3(0, 0, 1);
    surfaceData.emission = float3(0, 0, 0);
    surfaceData.occlusion = occlusion;
    surfaceData.clearCoatMask = 0.0;
    surfaceData.clearCoatSmoothness = 1.0;
    return surfaceData;
}
#endif