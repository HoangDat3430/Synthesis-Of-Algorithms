Shader "Custom/Erosion"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NormalTex ("Normal Map", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)

        _BurntColor ("Burnt Color", Color) = (1, 1, 1, 1)
        _BurningColor ("Burning Color", Color) = (1, 1, 1, 1)
        _Reveal ("Reveal Value", Range(0, 1)) = 0.5
        _Thickness ("Thickness", Range(0, 0.1)) = 0.02
        _BurnStr ("Burn Intensity", Range(0,10)) = 1

        // Lighting
		_Metallic ("Metallic", Range(0,1)) = 0.0
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        _NormalStr ("Normal Strength", Range(0,5)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Transparent"
        }

        Pass
        {
            Blend One Zero
            Cull Back
            Lighting Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Assets/ShaderLib/URPCommon.hlsl"

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
                float3 viewDirWS : TEXCOORD3;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 4);
                float4 tangentWS : TEXCOORD5;
                float3 bitangentWS : TEXCOORD6;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            TEXTURE2D(_NormalTex);
            SAMPLER(sampler_NormalTex);

            float4 _BaseColor, _BurntColor, _BurningColor;

            float _Metallic, _Smoothness, _Reveal, _Thickness, _NormalStr, _BurnStr;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionWS = TransformObjectToWorld(v.vertex.xyz);
                o.normalWS = TransformObjectToWorldNormal(v.normal.xyz);

                o.tangentWS.xyz = TransformObjectToWorld(v.tangent.xyz);
                o.tangentWS.w = v.tangent.w;
                o.bitangentWS = cross(o.tangentWS.xyz, o.normalWS.xyz) * o.tangentWS.w;
                
                o.viewDirWS = GetWorldSpaceNormalizeViewDir(o.positionWS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertex = TransformObjectToHClip(v.vertex.xyz);

                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUV);
                OUTPUT_SH(o.normalWS, o.vertexSH);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                half unburnArea = step(col.r, _Reveal);
                half burningArea = step(col.r + _Thickness, _Reveal);
                half burntArea = 1 - unburnArea;

                half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, i.uv), _NormalStr * burntArea);
                half3 finalNormal = normalTS.r * i.tangentWS + normalTS.g * i.bitangentWS + normalTS.b * i.normalWS;

                InputData inputData = (InputData)0;
                inputData.positionWS = i.positionWS;
                inputData.normalWS = normalize(finalNormal);
                inputData.viewDirectionWS = i.viewDirWS;
                inputData.bakedGI = SAMPLE_GI(i.lightmapUV, i.vertexSH, i.normalWS);
                
                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = lerp(_BaseColor, _BurntColor, burntArea);
                surfaceData.specular = 0;
                surfaceData.metallic = _Metallic - burntArea;
                surfaceData.smoothness = _Smoothness - burntArea;
                surfaceData.normalTS = normalize(finalNormal);
                surfaceData.emission =  (unburnArea - burningArea) * _BurningColor * _BurnStr;
                surfaceData.occlusion = 1;
                surfaceData.alpha = 1;
                surfaceData.clearCoatMask = 0.0;
                surfaceData.clearCoatSmoothness = 0.0;

                return UniversalFragmentPBR(inputData, surfaceData);
            }
            ENDHLSL
        }
    }
}
