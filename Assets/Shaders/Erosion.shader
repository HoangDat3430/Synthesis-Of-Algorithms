Shader "Custom/Erosion"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _MaskTex ("Mask", 2D) = "white" {}
        
        _ErodeColor ("Erosion Color", Color) = (1, 1, 1, 1)
        _Reveal ("Reveal Value", Range(0, 1)) = 0.5
        _FadeOut ("Fade Out", Range(0, 0.1)) = 0.02

        // Lighting
        _Metallic ("Smoothness", Range(0,1)) = 0.5
		_Smoothness ("Metallic", Range(0,1)) = 0.0
		_Occlusion ("Occlusion", Range(0,1)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
        }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "URPCommon.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 4);
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);
            float4 _MaskTex_ST;

            float _Reveal, _FadeOut;
            float4 _ErodeColor;

            float _Metallic, _Smoothness, _Occlusion;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex);

                o.normalWS.xyz = normalize(TransformObjectToWorldNormal(v.normal.xyz));
                o.tangentWS.xyz = normalize(TransformObjectToWorldDir(v.tangent));
                o.worldPos = TransformObjectToWorld(v.vertex);
                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUV);
                OUTPUT_SH(o.normalWS, o.vertexSH);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.xy);
                half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.uv.xy);
                float reveal = smoothstep(mask.r - _FadeOut, mask.r + _FadeOut, _Reveal);
                float revealTop = step(mask.r, _Reveal + _FadeOut);
                float revealBottom = step(mask.r, _Reveal - _FadeOut);
                float revealDiff = revealTop - revealBottom;
                float3 finalColor = lerp(col, _ErodeColor, revealDiff);

                half3 viewDirWS = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 bakedGI = SAMPLE_GI(i.lightmapUV, i.vertexSH, i.normalWS);
                InputData inputData = InitializeInputData(i.worldPos, i.normalWS, viewDirWS, bakedGI);
                SurfaceData surfaceData = InitializeSurfaceData(finalColor.rgb, revealTop * col.a, _Metallic, _Smoothness, _Occlusion);

                return UniversalFragmentPBR(inputData, surfaceData);
            }
            ENDHLSL
        }
    }
}
