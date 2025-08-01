#ifndef URP_LIT_CUSTOM_COMMON_INCLUDED
#define URP_LIT_CUSTOM_COMMON_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
TEXTURE2D(_NormalTex); SAMPLER(sampler_NormalTex);

float4 _MainTex_ST;

float4 _MainColor;
float _Metallic, _Smoothness, _AlphaCutOff;

void TestAlphaClipping(float4 color)
{
#ifdef _ALPHA_CUTOUT
    clip(color.a * _MainColor.a - _AlphaCutOff);
#endif
}
#endif