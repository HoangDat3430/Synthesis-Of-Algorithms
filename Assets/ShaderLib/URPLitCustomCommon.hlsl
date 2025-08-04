#ifndef URP_LIT_CUSTOM_COMMON_INCLUDED
#define URP_LIT_CUSTOM_COMMON_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
TEXTURE2D(_NormalTex); SAMPLER(sampler_NormalTex);
TEXTURE2D(_MetallicMask); SAMPLER(sampler_MetallicMask);
TEXTURE2D(_SpecularMap); SAMPLER(sampler_SpecularMap);
TEXTURE2D(_SmoothnessMap); SAMPLER(sampler_SmoothnessMap);
TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);
TEXTURE2D(_ParallaxMap); SAMPLER(sampler_ParallaxMap);
TEXTURE2D(_ClearCoatMap); SAMPLER(sampler_ClearCoatMap);
TEXTURE2D(_ClearCoatSmoothnessMap); SAMPLER(sampler_ClearCoatSmoothnessMap);

float4 _MainTex_ST;

float4 _MainColor, _SpecularTint, _EmissionTint;
float _MetallicStr, _Smoothness, _AlphaCutOff, _NormalStr, _HeightStr, _ClearCoatStr, _ClearCoatSmoothness;

void TestAlphaClipping(float4 color)
{
#ifdef _ALPHA_CUTOUT
    clip(color.a * _MainColor.a - _AlphaCutOff);
#endif
}
#endif