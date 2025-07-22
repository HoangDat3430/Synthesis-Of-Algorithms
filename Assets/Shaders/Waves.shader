Shader "Custom/Waves"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Metallic ("Smoothness", Range(0,1)) = 0.5
		_Smoothness ("Metallic", Range(0,1)) = 0.0
		_Occlusion ("Occlusion", Range(0,1)) = 1.0

        _NormTex("Normal Map", 2D) = "bump" {}
        _NormStrength("Normal Strength", Range(0, 2)) = 1.0
        _Color ("Tint", Color) = (0, 0.5, 0.7, 1)

        _WaveA ("Wave A (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
		_WaveB ("Wave B", Vector) = (0,1,0.25,20)
		_WaveC ("Wave C", Vector) = (1,1,0.15,10)
    }
    SubShader
    {
        Name "Forward Lit"
        Tags { "RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5

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
                float4 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 5);
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            TEXTURE2D(_NormTex);
            SAMPLER(sampler_NormTex);
            float _NormStrength;

            half _Smoothness;
            half _Metallic;
            half _Occlusion;
            half4 _Color;

            float4 _WaveA;
            float4 _WaveB;
            float4 _WaveC;

            float3 GerstnerWave (
                float4 wave, float3 p, inout float3 tangent, inout float3 binormal
            ) {
                float steepness = wave.z;
                float wavelength = wave.w;
                float k = 2 * 3.14 / wavelength;
                float c = sqrt(9.8 / k);
                float2 d = normalize(wave.xy);
                float f = k * (dot(d, p.xz) - c * _Time.y);
                float a = steepness / k;
    
                tangent += float3(
                    -d.x * d.x * (steepness * sin(f)),
                    d.x * (steepness * cos(f)),
                    -d.x * d.y * (steepness * sin(f))
                );
                binormal += float3(
                    -d.x * d.y * (steepness * sin(f)),
                    d.y * (steepness * cos(f)),
                    -d.y * d.y * (steepness * sin(f))
                );
                return float3(
                    d.x * (a * cos(f)),
                    a * sin(f),
                    d.y * (a * cos(f))
                );
            }

            v2f vert (appdata v)
            {
                v2f o;

                float3 gridPoint = v.vertex.xyz;
                float3 tangent = float3(1, 0, 0);
			    float3 binormal = float3(0, 0, 1);
                float3 p = gridPoint;
                p += GerstnerWave(_WaveA, gridPoint, tangent, binormal);
                p += GerstnerWave(_WaveB, gridPoint, tangent, binormal);
                p += GerstnerWave(_WaveC, gridPoint, tangent, binormal);
                float3 normal = normalize(cross(binormal, tangent));
                v.vertex.xyz = p;
                
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                //o.normalWS.xyz = normalize(TransformObjectToWorldNormal(v.normal));
                o.normalWS.xyz = normal;
                o.tangentWS.xyz = normalize(TransformObjectToWorldDir(v.tangent));
                o.bitangentWS = cross(o.normalWS, o.tangentWS) * v.tangent.w;
                o.worldPos = TransformObjectToWorld(v.vertex);

                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUV);
                OUTPUT_SH(v.normal, o.vertexSH);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                InputData inputData = (InputData)0;
                inputData.positionWS = i.worldPos;
                inputData.normalWS = i.normalWS;
                inputData.viewDirectionWS = normalize(_WorldSpaceCameraPos - i.worldPos);
                inputData.bakedGI = SAMPLE_GI(i.lightmapUV, i.vertexSH, i.normalWS);
                inputData.shadowCoord = TransformWorldToShadowCoord(i.worldPos);
                float3x3 tangentToWorld = CreateTangentToWorld(i.tangentWS, i.bitangentWS, i.normalWS);
                inputData.tangentToWorld = tangentToWorld;

                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = _Color.rgb;
                surfaceData.metallic = _Metallic;
                surfaceData.smoothness = _Smoothness;
                surfaceData.occlusion = _Occlusion;
                surfaceData.alpha = _Color.a;

                return UniversalFragmentPBR(inputData, surfaceData);
            }

            ENDHLSL
        }
    }
}
