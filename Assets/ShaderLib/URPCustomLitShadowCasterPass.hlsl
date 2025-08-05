#ifndef URP_LIT_CUSTOM_SHADOW_CASTER_PASS_INCLUDED
#define URP_LIT_CUSTOM_SHADOW_CASTER_PASS_INCLUDED
#include "Assets/ShaderLib/URPLitCustomCommon.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
#ifdef _ALPHA_CUTOUT
    float2 uv : TEXCOORD1;
#endif
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float3 normalWS : TEXCOORD0;
#ifdef _ALPHA_CUTOUT
    float2 uv : TEXCOORD1;
#endif
};

float3 _LightDirection;

float3 FlipNormalBasedOnViewDir(float3 normalWS, float3 positionWS)
{
    float3 viewDir = GetWorldSpaceNormalizeViewDir(positionWS);
    return normalWS * dot(normalWS, viewDir) > 0 ? 1 : -1;
}

float4 GetShadowCasterPositionCS(float3 positionWS, float3 normalWS)
{
    float3 LightDirWS = _LightDirection;

#ifdef _DOUBLE_SIDED_NORMALS
    normalWS = FlipNormalBasedOnViewDir(normalWS, positionWS);
#endif

    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, LightDirWS));

#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#endif

    return positionCS;
}

v2f vert(appdata v)
{
    v2f o;
    VertexPositionInputs posIn = GetVertexPositionInputs(v.vertex);
    VertexNormalInputs norIn = GetVertexNormalInputs(v.normal);

    o.vertex = GetShadowCasterPositionCS(posIn.positionWS, norIn.normalWS);
#ifdef _ALPHA_CUTOUT
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
#endif
    return o;
}

half4 frag(v2f i) : SV_TARGET
{
#ifdef _ALPHA_CUTOUT
    half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
    TestAlphaClipping(col);
#endif
    return 0;
}
#endif