Shader "Unlit/Custom/Real_Water"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

        _Amplitude ("Amplitude", float) = 1.0
        _WaveLength ("WaveLength", float) = 1.0
        _Speed ("Speed", float) = 1.0
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

            #include "URPCommon.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            half _Glossiness;
            half _Metallic;
            half4 _Color;

            float _Amplitude;
            float _WaveLength;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;

                float k = 2 * 3.14 / _WaveLength;
                float f = k * (v.vertex.x - _Speed.x * _Time.y);
                v.vertex.y += _Amplitude * sin(f);

                o.vertex = TransformObjectToHClip(v.vertex);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                return o;
            }
            float3 CalculateNormal (float2 uv)
            {
                float k = 2 * 3.14 / _WaveLength;
                float f = k * (uv.x - _Speed * _Time.y);
                
                // Object-space tangent & normal
                float3 tangent = normalize(float3(1, k * _Amplitude * cos(f), 0));
                float3 normal = normalize(cross(tangent, float3(0, 0, 1)));

                return normal;
            }
            half4 frag (v2f i) : SV_Target
            {
                float3 objectNormal = CalculateNormal(i.uv);
                float3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, objectNormal));

                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);

                float NdotL = saturate(dot(worldNormal, -lightDir)); // nhớ dấu trừ
                float3 diffuse = NdotL * mainLight.color.rgb;

                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfDir = normalize(-lightDir + viewDir);
                float spec = pow(saturate(dot(worldNormal, halfDir)), 32.0);
                spec *= NdotL;

                float3 finalColor = texColor.rgb * _Color.rgb * (diffuse + spec);

                return half4(finalColor, 1.0); // alpha phải là 1
            }

            ENDHLSL
        }
    }
}
