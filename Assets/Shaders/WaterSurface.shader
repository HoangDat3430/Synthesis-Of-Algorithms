Shader "Custom/WaterSurface"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        // Normal map
        _NormTex("Normal Map", 2D) = "bump" {}
        _NormStrength("Normal Strength", Range(0, 2)) = 1.0
        _LightDir ("Light Direction", Vector) = (0,0,0,0)
        _BaseColor ("Tint", Color) = (0, 0.5, 0.7, 1)
        
        // Lighting
        _Metallic ("Smoothness", Range(0,1)) = 0.5
		_Smoothness ("Metallic", Range(0,1)) = 0.0
		_Occlusion ("Occlusion", Range(0,1)) = 1.0

        //Wave effect
        _Speed ("Speed", Vector) = (1,0,0,0)
        _Frequency ("Frequency", float) = 0
        _Amplitude ("Amplitude", float) = 0
        _FallOff ("Fall off", float) = 0
        _Duration ("Duration", float) = 1.0
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

            #include "URPCommon.hlsl"

            struct appdata
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 4);
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            TEXTURE2D(_NormTex);
            SAMPLER(sampler_NormTex);
            float _NormStrength;
            float4 _BaseColor;
            float4 _LightDir;

            float _Metallic, _Smoothness, _Occlusion;

            CBUFFER_START(UnityPerMaterial)
                float4 _TouchPoint[8];
                int _RippleCount = 0;
            CBUFFER_END
            
            float4 _Speed;
            float _Frequency;
            float _Amplitude;
            float _FallOff;
            float _Duration;
            
            float SpawnWave(float2 uv, float r, float duration, float startTime, float offset, inout float dydxTotal, inout float dydzTotal)
            {
                float t = _Time.y - startTime;
                float radius = t * _Speed.x;
                float diff = r - radius;
                float f = diff * _FallOff;
                float envelope = exp(- f * f);
                float wave = sin(f) * envelope;

                float subAmp = _Amplitude - offset;
                float fadeOut = 1 - saturate((t+offset) / duration);
                float amp = subAmp * fadeOut;

                float dWave = amp * (cos(f) - 2 * sin(f)) * envelope; // derivative of wave

                float2 dir = normalize(uv + float2(1e-6, 1e-6)); //derivative dydx & dydz (uv/r => uv/length(uv) => normalize(uv)). Epsilon to avoid 0/0 = NaN
                dydxTotal += dWave * dir.x;
                dydzTotal += dWave * dir.y;
                
                return wave * amp;
            }
            v2f vert (appdata v)
            {
                v2f o;
                float totalWave = 0;
                float2 uv = v.uv;
                float dydxTotal = 0;
                float dydzTotal = 0;
                
                for(int i = 0; i < _RippleCount; i++)
                {
                    float2 touchUV = _TouchPoint[i].xy;
                    float duration = _TouchPoint[i].z;
                    duration = _Duration;
                    float startTime = _TouchPoint[i].w;
                    float r0 = distance(uv, touchUV);
                    float rX = distance(float2(2.0 - uv.x, uv.y), touchUV);
                    float rY = distance(float2(uv.x, 2.0 - uv.y), touchUV);
                    float rZ = distance(float2(-uv.x, uv.y), touchUV);
                    float rW = distance(float2(uv.x, -uv.y), touchUV);
                    for(int j = 0; j < _Frequency; j++)
                    {
                        float offset = j * 0.15;
                        float subStartTime = startTime + offset;
                        totalWave += SpawnWave(uv, r0, duration, subStartTime, offset, dydxTotal, dydzTotal);
                        totalWave += SpawnWave(uv, rX, duration, subStartTime, offset, dydxTotal, dydzTotal);
                        totalWave += SpawnWave(uv, rY, duration, subStartTime, offset, dydxTotal, dydzTotal);
                        totalWave += SpawnWave(uv, rZ, duration, subStartTime, offset, dydxTotal, dydzTotal);
                        totalWave += SpawnWave(uv, rW, duration, subStartTime, offset, dydxTotal, dydzTotal);
                    }
                }
                v.vertex.y += totalWave;
                o.uv = v.uv;
                
                o.pos = TransformObjectToHClip(v.vertex);
                o.normalWS.xyz = normalize(TransformObjectToWorldNormal(v.normal.xyz));
                o.normalWS.xyz = normalize(float3(-dydxTotal, 1, -dydzTotal));
                o.tangentWS.xyz = normalize(TransformObjectToWorldDir(v.tangent));
                o.worldPos = TransformObjectToWorld(v.vertex);
                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUV);
                OUTPUT_SH(o.normalWS, o.vertexSH);
                return o;
            }
            
            half4 frag(v2f i) : SV_Target
            {
                //return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                // Sample normal map và unpack
                float2 speed = _Speed/10;
                float2 uv1 = i.uv + _Time.y * float2( 0.8,  0.5) * 0.05;
                float2 uv2 = i.uv + _Time.y * float2(-0.4,  0.6) * 0.08;    

                float3 n1 = UnpackNormal(SAMPLE_TEXTURE2D(_NormTex, sampler_NormTex, uv1));
                float3 n2 = UnpackNormal(SAMPLE_TEXTURE2D(_NormTex, sampler_NormTex, uv2));

                float3 normalTS = normalize(n1 + n2);
                float2 uv = i.uv + _Time.y * _Speed.xy;

                normalTS.xy *= _NormStrength;
                normalTS = normalize(normalTS);

                float ndotl = saturate(dot(normalTS, normalize(_LightDir)));

                float3 color = _BaseColor.rgb * ndotl;

                half3 viewDirWS = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 bakedGI = SAMPLE_GI(i.lightmapUV, i.vertexSH, i.normalWS);
                InputData inputData = InitializeInputData(i.worldPos, i.normalWS, viewDirWS, bakedGI);
                SurfaceData surfaceData = InitializeSurfaceData(color.rgb, _BaseColor.a, _Metallic, _Smoothness, _Occlusion);

                return UniversalFragmentPBR(inputData, surfaceData);
            }
            ENDHLSL
        }
    }
}
