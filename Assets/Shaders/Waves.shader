Shader "Unlit/Custom/Waves"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Scroll Speed", Vector) = (1,0,0,0)
        _TileIndex ("Tile Index", Vector) = (0,0,0,0)
        _GridSize ("GridSize", Vector) = (0,0,0,0)
        _Frequency ("Frequency", float) = 0
        _Amplitude ("Amplitude", float) = 0
        [Toggle]_Flag("Is Flag", float) = 1.0
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
            float4 _Speed;
            float4 _GridSize;
            float4 _TileIndex;
            float _Frequency;
            float _Amplitude;
            float _Flag;
            
            float2 GetPositionOnTexture(float2 uv)
            {
                return uv / _GridSize + _TileIndex / _GridSize;
            }

            v2f vert (appdata v)
            {
                v2f o;
                float2 uv = GetPositionOnTexture(v.uv);
                
                float ampScale = 1;
                if(_Flag == 1)
                {
                    ampScale = v.vertex.x / _GridSize;
                }
                else
                {
                    uv += _Speed.xy * _Time.x;
                }
                float2 waveDir = normalize(float2(1.0, 0.0));
                float wavePhase = dot(uv, waveDir) * _Frequency - _Time.y * _Speed.xy;
                float wave = sin(wavePhase);
                v.vertex.y += wave * _Amplitude * ampScale;

                o.uv = uv;
                
                o.pos = TransformObjectToHClip(v.vertex);
                return o;
            }
            
            half4 frag (v2f i) : SV_Target
            {
                return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
            }
            ENDHLSL
        }
    }
}
