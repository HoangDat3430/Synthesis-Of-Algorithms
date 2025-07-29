Shader "Custom/Test"
{
    Properties
    {
        _MainTex ("BaseMap", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        
        _Metallic ("Metallic", Range(0,1)) = 0.5
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline"="UniversalRenderPipeline" 
        }
        LOD 100
        
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
            Lighting Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "URPCommon.hlsl"
            
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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float4 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
                float3 viewDirWS : TEXCOORD5;
                float4 shadowCoord : TEXCOORD6;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 7);
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            float4 _BaseColor;
            float _Metallic, _Smoothness;
            
            v2f vert (appdata v)
            {
                v2f o;
                VertexPositionInputs posInput = GetVertexPositionInputs(v.vertex.xyz);
                VertexNormalInputs normInput = GetVertexNormalInputs(v.normal, v.tangent);

                o.vertex = posInput.positionCS;
                o.uv = v.uv;
                o.positionWS = posInput.positionWS;
                o.normalWS = normInput.normalWS;
                o.tangentWS = float4(normInput.tangentWS, v.tangent.w);
                o.bitangentWS = normInput.bitangentWS;
                o.viewDirWS = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
                o.shadowCoord = TransformWorldToShadowCoord(posInput.positionWS);
                
                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUV);
                OUTPUT_SH(o.normalWS, o.vertexSH);
                return o;
            }
            
            half4 frag (v2f i) : SV_Target
            {
                float3 normalWS = normalize(i.normalWS);
                InputData inputData = InitializeInputData(i.positionWS, normalWS, i.viewDirWS);
                inputData.bakedGI = SAMPLE_GI(i.lightmapUV, i.vertexSH, normalWS);
                inputData.shadowCoord = i.shadowCoord;

                SurfaceData surfaceData = InitializeSurfaceData(_BaseColor.rgb, 1, _Metallic, _Smoothness);
                
                return UniversalFragmentPBR(inputData, surfaceData);
            }
            ENDHLSL
        }
    }
}
