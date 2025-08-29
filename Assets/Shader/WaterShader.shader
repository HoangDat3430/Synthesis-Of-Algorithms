Shader "Custom/WaterShader"
{
    Properties
    {
        _RippleTex ("Ripple Render Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)

        [Normal] _NormalTex1 ("Normal Texture 1", 2D) = "white" {}
        [Normal] _NormalTex2 ("Normal Texture 2", 2D) = "white" {}
        _NormalStr ("Normal Strength", Range(0,1)) = 0.5
        _Speed ("Speed", Vector) = (0,0,0,0)

        _Smoothness ("Smoothness", Range(0,1)) = 1
        _Metallic ("Metallic", Range(0,1)) = 1
    }
    SubShader
    {
        Tags 
        { 
            "RenderPipeline"="UniversalRenderPipiline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
        }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags 
            { 
                "LightMode" = "UniversalForward" 
            }
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest LEqual
            ZWrite Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD2; 
                float3 positionWS : TEXCOORD3;
                float3 viewDirWS : TEXCOORD4;
            };

            TEXTURE2D(_RippleTex);SAMPLER(sampler_RippleTex);
            TEXTURE2D(_NormalTex1);SAMPLER(sampler_NormalTex1);
            TEXTURE2D(_NormalTex2);SAMPLER(sampler_NormalTex2);

            float4 _RippleTex_ST, _RippleTex_TexelSize;
            float4 _BaseColor, _Speed;
            float _NormalStr, _Smoothness, _Metallic;

            v2f vert (appdata v)
            {
                v2f o;
                VertexPositionInputs posIn = GetVertexPositionInputs(v.vertex);
                VertexNormalInputs normIn = GetVertexNormalInputs(v.normal, v.tangent); 
                o.vertex = posIn.positionCS;
                o.uv = TRANSFORM_TEX(v.uv, _RippleTex);
                o.normalWS = normIn.normalWS;
                o.tangentWS = float4(normIn.tangentWS, v.tangent.w);
                o.positionWS = posIn.positionWS;
                o.viewDirWS = GetWorldSpaceNormalizeViewDir(o.positionWS);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 uv1 = sin(i.uv + _Time.x * _Speed.xy);
                float2 uv2 = sin(i.uv + _Time.x * _Speed.zw);
                float n1 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTex1, sampler_NormalTex1, uv1), _NormalStr);
                float n2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTex2, sampler_NormalTex2, uv2), _NormalStr);

                float2 duv = _RippleTex_TexelSize.xy;
                float hL = SAMPLE_TEXTURE2D(_RippleTex, sampler_RippleTex, i.uv + float2(-duv.x, 0)).r;
                float hR = SAMPLE_TEXTURE2D(_RippleTex, sampler_RippleTex, i.uv + float2( duv.x, 0)).r;
                float hD = SAMPLE_TEXTURE2D(_RippleTex, sampler_RippleTex, i.uv + float2(0, -duv.y)).r;
                float hU = SAMPLE_TEXTURE2D(_RippleTex, sampler_RippleTex, i.uv + float2(0,  duv.y)).r;

                // Tangent-space normal từ height gradient (giống "Normal From Height" trong SG)
                float3 normalTS = float3((hL - hR), (hD - hU), 1.0);
                normalTS.xy *= _NormalStr;           
                normalTS = normalize(normalTS + n1 + n2);
                float3 normalWS = normalize(i.normalWS);
                
                float3x3 tangentToWorld = CreateTangentToWorld(normalWS, i.tangentWS.xyz, i.tangentWS.w);
                normalWS = normalize(TransformTangentToWorld(normalTS, tangentToWorld));
                
                // Setup surface data for URP lighting
                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = _BaseColor.rgb;
                surfaceData.metallic = _Metallic;
                surfaceData.smoothness = _Smoothness;
                surfaceData.normalTS = normalTS;
                surfaceData.occlusion = 1.0;
                surfaceData.emission = 0;
                surfaceData.alpha = _BaseColor.a;

                // Setup input data for lighting
                InputData inputData = (InputData)0;
                inputData.positionWS = i.positionWS;
                inputData.normalWS = normalWS;
                inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(i.positionWS);
                inputData.shadowCoord = TransformWorldToShadowCoord(i.positionWS);
                inputData.fogCoord = ComputeFogFactor(i.vertex.z);
                
                // Calculate final color with URP lighting
                half4 color = UniversalFragmentPBR(inputData, surfaceData);
                
                return color;
            }
            ENDHLSL
        }
    }
}
