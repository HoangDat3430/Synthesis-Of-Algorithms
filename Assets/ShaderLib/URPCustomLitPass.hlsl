#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);

float4 _MainTex_ST;
float _Smoothness;

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
    float4 tangentWS : TEXCOORD3;
    float3 bitangentWS : TEXCOORD4;
};

v2f vert (appdata v)
{
    v2f o;
    VertexPositionInputs posIn = GetVertexPositionInputs(v.vertex);
    VertexNormalInputs norIn = GetVertexNormalInputs(v.normal);
    
    o.vertex = posIn.positionCS;
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.positionWS = posIn.positionWS;
    o.normalWS = norIn.normalWS;
    return o;
}

half4 frag (v2f i) : SV_Target
{
    half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

    InputData lightingData = (InputData)0;
    lightingData.positionWS = i.positionWS;
    lightingData.normalWS = normalize(i.normalWS);
    lightingData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(i.positionWS);
    lightingData.shadowCoord = TransformWorldToShadowCoord(i.positionWS);

    SurfaceData surfaceData = (SurfaceData)0;
    surfaceData.albedo = col.rgb;
    surfaceData.alpha = col.a;
    surfaceData.specular = 1;
    surfaceData.smoothness = _Smoothness;

    return UniversalFragmentBlinnPhong(lightingData, surfaceData);
}