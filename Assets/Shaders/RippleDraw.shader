Shader "Hidden/DrawRipple"
{
    Properties {
        _RipplePos("Ripple Pos", Vector) = (0,0,0,0)
        _RippleStrength("Ripple Strength", Float) = 1
        _RippleRadius("Ripple Radius", Float) = 0.05
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        Pass {
            ZWrite Off 
            Cull Off 
            ZTest Always
            Blend One One

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 

            float4 _RipplePos;     // xy = uv pos
            float _RippleStrength;
            float _RippleRadius;

            struct appdata { float4 vertex : POSITION; float2 uv : TEXCOORD0; };
            struct v2f { float4 pos : SV_POSITION; float2 uv : TEXCOORD0; };

            v2f vert(appdata v) {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                float dist = distance(i.uv, _RipplePos.xy);
                float circle = saturate(1 - dist / _RippleRadius);
                return float4(circle * _RippleStrength, 0, 0, 0);
            }
            ENDHLSL
        }
    }
}
