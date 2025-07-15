Shader "Unlit/Custom/Real_Water"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Metallic ("Smoothness", Range(0,1)) = 0.5
		_Smoothness ("Metallic", Range(0,1)) = 0.0

        _Amplitude ("Amplitude", float) = 1.0
        _WaveLength ("WaveLength", float) = 1.0
        _Speed ("Speed", float) = 1.0
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
                float3 normalOS : NORMAL;
                float4 texcoord1 : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 normalWS : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 3);
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            half _Smoothness;
            half _Metallic;
            half4 _Color;

            float _Amplitude;
            float _WaveLength;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;

                float k = 2 * 3.14 / _WaveLength;
                float f = k * (v.vertex.x - _Speed.x * _Time.y);
                v.vertex.y += _Amplitude * sin(f);

                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                o.normalWS.xyz = normalize(TransformObjectToWorldNormal(v.normalOS));
                o.worldPos = TransformObjectToWorld(v.vertex);

                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUV);
                OUTPUT_SH(v.normalOS, o.vertexSH);
                return o;
            }
            float3 CalculateNormal (float2 uv)
            {
                float k = 2 * 3.14 / _WaveLength;
                float f = k * (uv.x - _Speed * _Time.y);
                
                float3 tangent = normalize(float3(1, k * _Amplitude * cos(f), 0));
                float3 normal = normalize(cross(tangent, float3(0, 0, 1)));

                return normal;
            }
            half4 frag (v2f i) : SV_Target
            {
                InputData inputData = (InputData)0;
                inputData.positionWS = i.worldPos;
                inputData.normalWS = i.normalWS;
                inputData.viewDirectionWS = normalize(_WorldSpaceCameraPos - i.worldPos);
                inputData.bakedGI = SAMPLE_GI(i.lightmapUV, i.vertexSH, i.normalWS);

                SurfaceData surfaceData;
                surfaceData.albedo = _Color.rgb;
                surfaceData.specular = 0;
                surfaceData.metallic = _Metallic;
                surfaceData.smoothness = _Smoothness;
                surfaceData.normalTS = 0;
                surfaceData.emission = 0;
                surfaceData.occlusion = 1;
                surfaceData.alpha = _Color.a;
                surfaceData.clearCoatMask = 0;
                surfaceData.clearCoatSmoothness = 0;

                return UniversalFragmentPBR(inputData, surfaceData);
            }

            ENDHLSL
        }
    }
}
