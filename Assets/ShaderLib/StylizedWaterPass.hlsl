#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
TEXTURE2D(_NoiseTex); SAMPLER(sampler_NoiseTex);
TEXTURE2D(_NormalTex1); SAMPLER(sampler_NormalTex1);
TEXTURE2D(_NormalTex2); SAMPLER(sampler_NormalTex2);
TEXTURE2D(_ReflectionTex); SAMPLER(sampler_ReflectionTex);

float4 _MainTex_ST, _NoiseTex_ST;
float4 _BaseColor, _Speed;
float _NormalStr, _Metallic, _Smoothness, _Scale, _Amplitude, _Soft;

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
    float4 screenPos : TEXCOORD6;
    float eyeDepth : TEXCOORD7;
};

v2f vert (appdata v)
{
    v2f o;
    float2 noiseUV = float2(v.uv + _Time.x * _Speed.x) * _Scale;
    float xMod = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, noiseUV, 0).r * _Amplitude;
    v.vertex.y = xMod;

    VertexPositionInputs posIN = GetVertexPositionInputs(v.vertex);
    VertexNormalInputs norIN = GetVertexNormalInputs(v.normal, v.tangent);

    o.vertex = posIN.positionCS;
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normalWS = norIN.normalWS;
    o.tangentWS = float4(norIN.tangentWS.xyz, v.tangent.w);
    o.bitangentWS = cross(o.normalWS, o.tangentWS.xyz) * o.tangentWS.w;
    o.positionWS = posIN.positionWS;
    o.viewDirWS = GetWorldSpaceNormalizeViewDir(o.positionWS);
    o.screenPos = ComputeScreenPos(posIN.positionCS);
    o.eyeDepth = -TransformWorldToView(o.positionWS).z;
    return o;
}

half4 frag (v2f i) : SV_Target
{

    float rawZ = SampleSceneDepth(i.screenPos.xy / i.screenPos.w);
    float sceneZ = LinearEyeDepth(rawZ, _ZBufferParams);
    float partZ = i.eyeDepth;
    float fade = saturate(_Soft * (sceneZ - partZ));

    float3 normalWS = normalize(i.normalWS);
    float normalUVX = i.uv.x + sin(_Time.x) * _Speed.y;
    float normalUVY = i.uv.y + sin(_Time.x) * _Speed.z;

    float2 uv1 = float2(normalUVX, i.uv.y);
    float2 uv2 = float2(i.uv.x, normalUVY);
    float3 n1 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTex1, sampler_NormalTex1, uv1), _NormalStr * fade);
    float3 n2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTex2, sampler_NormalTex2, uv2), _NormalStr * fade);

    float3 normalTS = normalize(n1 + n2);
    float3x3 tangentToWorld = CreateTangentToWorld(normalWS, i.tangentWS.xyz, i.tangentWS.w);
    normalWS = normalize(TransformTangentToWorld(normalTS, tangentToWorld));
    
    float3 reflDir = reflect(-i.viewDirWS, normalWS);
    float4 envColor = SAMPLE_TEXTURECUBE(_ReflectionTex, sampler_ReflectionTex, reflDir);

    InputData inputData = (InputData)0;
    inputData.positionCS = i.vertex;
    inputData.positionWS = i.positionWS;
    inputData.normalWS = normalWS;
    inputData.viewDirectionWS = i.viewDirWS;
    inputData.tangentToWorld = tangentToWorld;

    SurfaceData surfaceData = (SurfaceData)0;   
    surfaceData.albedo = _BaseColor.rgb + envColor.rgb;
    surfaceData.alpha = fade * 0.8;
    surfaceData.metallic = _Metallic;
    surfaceData.smoothness = _Smoothness;
    surfaceData.occlusion = 1;
    surfaceData.normalTS = normalTS;

    return UniversalFragmentPBR(inputData, surfaceData);
}