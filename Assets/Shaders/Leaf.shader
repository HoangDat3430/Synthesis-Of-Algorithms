Shader "Custom/Leaf"
{
    Properties
    {
        _BaseMap("Base Map (RGBA)", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)

        _Angle("Angle", float) = 0
        _Offset("Offset", Vector) = (0,0,0,0)
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
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseColor;
            float4 _BaseMap_ST;

            float3 _CamPos;
            float _Angle;
            float4 _Offset;

            v2f vert(appdata v)
            {
                v2f o;
                _CamPos = _WorldSpaceCameraPos;
                float3 toCam = _CamPos - TransformObjectToWorld(v.vertex);
                toCam.y = 0;
                toCam = normalize(toCam);
                float angle = atan2(toCam.x, toCam.z);
                float s = sin(angle);
                float c = cos(angle);

                float3 pos = v.vertex.xyz;
                float3 rotated;
                rotated.x = pos.x * c - pos.y * s;
                rotated.y = pos.x * s + pos.y * c;
                rotated.z = pos.z;

                o.pos = TransformObjectToHClip(float4(rotated, 1));
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
