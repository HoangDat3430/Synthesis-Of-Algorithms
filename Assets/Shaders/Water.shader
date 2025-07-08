Shader "Unlit/Custom/Water_Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        // Normal map
        _NormTex("Normal Map", 2D) = "bump" {}
        _NormStrength("Normal Strength", Range(0, 2)) = 1.0
        _Color ("Tint", Color) = (0, 0.5, 0.7, 1)

        // Grid's stuff
        _TileIndex ("Tile Index", Vector) = (0,0,0,0)
        _GridSize ("GridSize", Vector) = (0,0,0,0)

        //Wave effect
        _Speed ("Scroll Speed", Vector) = (1,0,0,0)
        //_TouchPoint ("Touch Point", Vector) = (0,0,0,0)
        _Frequency ("Frequency", float) = 0
        _Amplitude ("Amplitude", float) = 0
        _FallOff ("Fall off", float) = 0
        //_FakeTime ("Fake Time", Range(0,10)) = 0
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

            float4 _GridSize;
            float4 _TileIndex;

            float4 _Speed;
            float _Frequency;
            float _Amplitude;
            float4 _TouchPoint = (0,0,0,0);
            float _FallOff;
            float2 _RunTime;
            
            float2 GetPositionOnTexture(float2 uv)
            {
                return uv / _GridSize + _TileIndex / _GridSize;
            }

            v2f vert (appdata v)
            {
                v2f o;
                float2 uv = GetPositionOnTexture(v.uv);

                float r = distance(uv, _TouchPoint / _GridSize);
                float radius = _RunTime.x * _Speed.x;
                float diff = r - radius;
                float wave = exp(-diff * diff * _FallOff * _FallOff) * sin(diff * _FallOff);
                v.vertex.y += wave * _Amplitude;

                o.uv = uv;
                
                o.pos = TransformObjectToHClip(v.vertex);
                return o;
            }
            
            half4 frag(v2f i) : SV_Target
            {
                // Sample normal map và unpack
                float2 speed = _Speed/10;
                float2 uv1 = i.uv + _Time.y * speed.xy;
                float2 uv2 = i.uv + _Time.y * speed.yx;

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

                //return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                return float4(baseColor, 1);
            }
            ENDHLSL
        }
    }
}
