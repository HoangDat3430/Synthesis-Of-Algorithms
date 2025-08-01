#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/ShaderLib/URPLitCustomCommon.hlsl"


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
};

v2f vert (appdata v)
{
    v2f o;
    VertexPositionInputs posIn = GetVertexPositionInputs(v.vertex);
    VertexNormalInputs norIn = GetVertexNormalInputs(v.normal, v.tangent);
    
    o.vertex = posIn.positionCS;
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.positionWS = posIn.positionWS;
    o.normalWS = norIn.normalWS;
    o.tangentWS = float4(norIn.tangentWS.xyz, v.tangent.w);
    return o;
}

half4 frag (v2f i
#ifdef _DOUBLE_SIDED_NORMALS 
    , FRONT_FACE_TYPE frontFace : FRONT_FACE_SEMANTIC
#endif
) : SV_Target
{
    half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
    
    TestAlphaClipping(col);

    float3 normalWS = normalize(i.normalWS);
#ifdef _DOUBLE_SIDED_NORMALS
    normalWS *= IS_FRONT_VFACE(frontFace, 1, -1);
#endif

    float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, i.uv));
    float3x3 tangentToWorld = CreateTangentToWorld(normalWS, i.tangentWS.xyz, i.tangentWS.w);
    normalWS = normalize(TransformTangentToWorld(normalTS, tangentToWorld));

    InputData lightingData = (InputData)0;
    lightingData.positionCS = i.vertex;
    lightingData.positionWS = i.positionWS;
    lightingData.normalWS = normalWS;
    lightingData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(i.positionWS);
    lightingData.shadowCoord = TransformWorldToShadowCoord(i.positionWS);
    lightingData.tangentToWorld = tangentToWorld; 

    SurfaceData surfaceData = (SurfaceData)0;
    surfaceData.albedo =  _MainColor.rgb;
    surfaceData.alpha = col.a * _MainColor.a;
    surfaceData.specular = 1;
    surfaceData.smoothness = _Smoothness;
    surfaceData.metallic = _Metallic;
    surfaceData.normalTS = normalTS;

    return UniversalFragmentPBR(lightingData, surfaceData);
}