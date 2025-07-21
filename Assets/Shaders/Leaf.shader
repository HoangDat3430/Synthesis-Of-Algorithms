Shader "Custom/Leaf"
{
    Properties
    {
        _BaseMap("Base Map (RGBA)", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)

        _Angle("Angle", float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionWS : SV_POSITION;
                float2 uv          : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseColor;
            float4 _BaseMap_ST;

            float4 _camPos;
            float _Angle;

            v2f vert(appdata v)
            {
                v2f o;

                // Convert angle to radians
                float rad = radians(_Angle);
                float s = sin(rad);
                float c = cos(rad);

                // Rotate around Z axis
                float3 pos = v.positionOS.xyz;
                float3 rotated;
                rotated.x = pos.x * c - pos.y * s;
                rotated.y = pos.x * s + pos.y * c;
                rotated.z = pos.z;

                float4 rotatedPos = float4(rotated, 1.0);

                o.positionWS = TransformObjectToHClip(float4(rotated, 1));
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float4 tex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                return tex * _BaseColor;
            }
            ENDHLSL
        }
    }
}
