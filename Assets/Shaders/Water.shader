Shader "Unlit/Custom/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        // Normal map
        _NormTex("Normal Map", 2D) = "bump" {}
        _NormStrength("Normal Strength", Range(0, 2)) = 1.0
        _Color ("Tint", Color) = (0, 0.5, 0.7, 1)

        //Wave effect
        _Speed ("Scroll Speed", Vector) = (1,0,0,0)
        _Frequency ("Frequency", float) = 0
        _Amplitude ("Amplitude", float) = 0
        _FallOff ("Fall off", float) = 0
        _Duration ("Duration", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            TEXTURE2D(_NormTex);
            SAMPLER(sampler_NormTex);
            float _NormStrength;
            float4 _Color;

            CBUFFER_START(UnityPerMaterial)
                float4 _TouchPoint[8];
                int _RippleCount = 0;
            CBUFFER_END
            
            float4 _Speed;
            float _Frequency;
            float _Amplitude;
            
            float _FallOff;
            
            float SpawnWave(float r, float duration, float startTime, float offset)
            {
                float t = _Time.y - startTime;
                float radius = t * _Speed.x;
                float diff = r - radius;
                float envelope = exp(-diff * diff * _FallOff * _FallOff);
                float wave = sin(diff * _FallOff) * envelope;
                float subAmp = _Amplitude - offset;
                float amp = subAmp * (1-(min((t+offset)/duration, 1)));
                return wave * amp;
            }
            v2f vert (appdata v)
            {
                v2f o;
                float totalWave = 0;
                float2 uv = v.uv;
                
                for(int i = 0; i < _RippleCount; i++)
                {
                    float2 touchUV = _TouchPoint[i].xy;
                    float duration = _TouchPoint[i].z;
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
                        totalWave += SpawnWave(r0, duration, subStartTime, offset);
                        totalWave += SpawnWave(rX, duration, subStartTime, offset);
                        totalWave += SpawnWave(rY, duration, subStartTime, offset);
                        totalWave += SpawnWave(rZ, duration, subStartTime, offset);
                        totalWave += SpawnWave(rW, duration, subStartTime, offset);
                    }
                }
                v.vertex.y += totalWave;
                o.uv = v.uv;
                
                o.pos = TransformObjectToHClip(v.vertex);
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

                // Ánh sáng giả lập chiếu từ trên xuống nhẹ
                float3 lightDir = normalize(float3(-0.5, 0.5, 1));
                float ndotl = saturate(dot(normalTS, lightDir));

                float3 baseColor = _Color.rgb * ndotl;

                return float4(baseColor, 1);
            }
            ENDHLSL
        }
    }
}
