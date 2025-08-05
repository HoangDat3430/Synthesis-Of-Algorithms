#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/ShaderLib/StylizedWaterInput.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float4 texcoord1 : TEXCOORD1;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 normalWS : TEXCOORD1;
    float4 tangentWS : TEXCOORD2;
    float3 bitangentWS : TEXCOORD3;
    float3 positionWS : TEXCOORD4;
    float3 viewDirWS : TEXCOORD5;
};

v2f vert (appdata v)
{
    v2f o;
    float2 noiseUV = float2((v.uv + _Time.x * _Speed) * _Scale);
    float noiseVal = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, noiseUV, 0).x * _Amplitude;
    v.vertex += float4(0, v.vertex.y + noiseVal, 0, 0);

    VertexPositionInputs posIN = GetVertexPositionInputs(v.vertex);
    VertexNormalInputs norIN = GetVertexNormalInputs(v.normal, v.tangent);

    o.vertex = posIN.positionCS;
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normalWS = norIN.normalWS;
    o.tangentWS = float4(norIN.tangentWS.xyz, v.tangent.w);
    o.bitangentWS = cross(o.normalWS, o.tangentWS.xyz) * o.tangentWS.w;
    o.positionWS = posIN.positionWS;
    o.viewDirWS = GetWorldSpaceNormalizeViewDir(o.positionWS);
    return o;
}

half4 frag (v2f i) : SV_Target
{
    half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _BaseColor * 2;

    InputData inputData = (InputData)0;
    inputData.positionCS = i.vertex;
    inputData.positionWS = i.positionWS;
    inputData.normalWS = normalize(i.normalWS);
    inputData.viewDirectionWS = i.viewDirWS;
    inputData.tangentToWorld = CreateTangentToWorld(i.normalWS, i.tangentWS.xyz, i.tangentWS.w);

    SurfaceData surfaceData = (SurfaceData)0;   
    surfaceData.albedo = col.rgb;
    surfaceData.alpha = col.a;
    surfaceData.metallic = _Metallic;
    surfaceData.smoothness = _Smoothness;
    surfaceData.occlusion = 1;

    return UniversalFragmentPBR(inputData, surfaceData);
}