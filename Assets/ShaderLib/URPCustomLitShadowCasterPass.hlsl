#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float3 normalWS : TEXCOORD0;
};

float3 _LightDirection;

float4 GetShadowCasterPositionCS(float3 positionWS, float3 normalWS)
{
    float3 LightDirWS = _LightDirection;
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
    return o;
}

half4 frag(v2f i) : SV_TARGET
{
    return 0;
}