Shader "Custom/LitTemplate"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Metallic ("Metallic", Range(0,1)) = 0.5
        _Smoothness ("Smoothness", Range(0,1)) = 1
        _Occlusion ("Occlusion", Range(0,1)) = 1
    }
    SubShader
    {
        Name "Forward Lit"
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipeline" 
            "RenderType"="Opaque" 
            "Queue"="Geometry" 
        }
        LOD 100
        Pass
        {
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
                float3 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertex_SH, 4);
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Metallic, _Smoothness, _Occlusion;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                o.tangentWS.xyz = TransformObjectToWorldDir(v.tangent);
                o.worldPos = TransformObjectToWorld(v.vertex)
                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUV);
                OUTPUT_SH(o.normalWS, o.vertex_SH);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);

                half3 viewDirWS = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 bakedGI = SAMPLE_GI(i.lightmapUV, i.vertex_SH, i.normalWS);
                InputData inputData = InitializeInputData(i.worldPos, i.normalWS, viewDirWS);

                SurfaceData surfaceData = InitializeSurfaceData(col.rgb, col.a, _Metallic, _Smoothness);
                return UniversalFragmentPBR(inputData, surfaceData);
            }
            ENDHLSL
        }
    }
}
