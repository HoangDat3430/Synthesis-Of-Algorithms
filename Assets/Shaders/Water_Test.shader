Shader "Custom/InteractableWater"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (0.1, 0.35, 0.5, 0.7)

        _NormalTex1 ("Normal A", 2D) = "bump" {}
        _NormalTex2 ("Normal B", 2D) = "bump" {}
        _NormalStrength ("Normal Strength", Range(0,2)) = 1
        _N1_Scale ("Normal A Scale", Float) = 1
        _N2_Scale ("Normal B Scale", Float) = 1
        _N1_Speed ("Normal A Speed", Vector) = (0.05, 0.02, 0, 0)
        _N2_Speed ("Normal B Speed", Vector) = (-0.02, 0.03, 0, 0)

        _RippleTex ("Ripple RT", 2D) = "black" {}
        _RippleStrength ("Ripple Strength", Range(0,0.2)) = 0.05
        _RippleNormalStrength ("Ripple Normal Strength", Range(0,2)) = 1

        _FoamTex ("Foam Tex", 2D) = "white" {}
        _FoamColor ("Foam Color", Color) = (1,1,1,1)
        _FoamThreshold ("Foam Threshold", Range(0,1)) = 0.5
        _FoamIntensity ("Foam Intensity", Range(0,3)) = 1

        _FresnelPower ("Fresnel Power", Range(0.5,8)) = 3
        _ReflectionStrength ("Reflection Strength", Range(0,1)) = 0.5
        _RefractionStrength ("Refraction Strength", Range(0,0.05)) = 0.015

        _Metallic ("Metallic", Range(0,1)) = 0
        _Smoothness ("Smoothness", Range(0,1)) = 0.9

        _WaterPlaneOrigin ("Water Plane Origin (WS)", Vector) = (0,0,0,0)
        _WaterPlaneSize   ("Water Plane Size (XZ)", Vector) = (50,0,50,0)

        _Soft ("Soft Intersection Scale", Range(0,5)) = 1
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 300
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Name "ForwardTransparency"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            TEXTURE2D(_NormalTex1); SAMPLER(sampler_NormalTex1);
            TEXTURE2D(_NormalTex2); SAMPLER(sampler_NormalTex2);
            TEXTURE2D(_RippleTex);   SAMPLER(sampler_RippleTex);
            TEXTURE2D(_FoamTex);    SAMPLER(sampler_FoamTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float _NormalStrength;
                float _N1_Scale;
                float _N2_Scale;
                float4 _N1_Speed; // xy
                float4 _N2_Speed; // xy
                float _RippleStrength;
                float _RippleNormalStrength;
                float4 _FoamColor;
                float _FoamThreshold;
                float _FoamIntensity;
                float _FresnelPower;
                float _ReflectionStrength;
                float _RefractionStrength;
                float _Metallic;
                float _Smoothness;
                float4 _WaterPlaneOrigin; // xyz
                float4 _WaterPlaneSize;   // xz in .x and .z
                float _Soft;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 tangentOS  : TANGENT;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS   : TEXCOORD2;
                float4 tangentWS  : TEXCOORD3; // xyz + handedness in w
                float4 screenPos  : TEXCOORD4;
                float  eyeDepth   : TEXCOORD5;
                float  fogFactor : TEXCOORD6;
            };

            float2 WorldToWaterUV(float3 worldPos)
            {
                return float2(worldPos.xz - _WaterPlaneOrigin.xz) / _WaterPlaneSize.xz;
            }

            Varyings vert(Attributes v)
            {
                Varyings o;
                VertexPositionInputs pos = GetVertexPositionInputs(v.positionOS);
                VertexNormalInputs   nor = GetVertexNormalInputs(v.normalOS, v.tangentOS);

                o.positionCS = pos.positionCS;
                o.positionWS = pos.positionWS;
                o.normalWS   = nor.normalWS;
                o.tangentWS  = float4(nor.tangentWS, v.tangentOS.w);
                o.uv         = v.uv;
                o.screenPos  = ComputeScreenPos(pos.positionCS);
                o.eyeDepth   = -TransformWorldToView(o.positionWS).z;
                o.fogFactor  = ComputeFogFactor(pos.positionCS.z);
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {

                // --- Scene depth vs eye depth for soft intersection ---
                float2 uvSS = i.screenPos.xy / i.screenPos.w;
                float rawZ = SampleSceneDepth(uvSS);
                float sceneZ = LinearEyeDepth(rawZ, _ZBufferParams);
                float partZ  = i.eyeDepth;
                float softFade = saturate(_Soft * (sceneZ - partZ));

                // --- Base normals (two scrolling normal maps) ---
                float2 nUV1 = i.uv * _N1_Scale + _Time.x * _N1_Speed.xy;
                float2 nUV2 = i.uv * _N2_Scale + _Time.x * _N2_Speed.xy;
                float3 n1 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTex1, sampler_NormalTex1, nUV1), _NormalStrength);
                float3 n2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTex2, sampler_NormalTex2, nUV2), _NormalStrength);
                float3 nTS = normalize(n1 + n2);

                // --- Ripple map: height in R, convert to normal perturbation ---
                float2 uvRipple = WorldToWaterUV(i.positionWS);
                float rippleH = SAMPLE_TEXTURE2D(_RippleTex, sampler_RippleTex, uvRipple).r;
                // Fake normal from height gradient: sample neighbors (cheap)
                float hL = SAMPLE_TEXTURE2D(_RippleTex, sampler_RippleTex, uvRipple + float2(-1.0/1024,0)).r;
                float hR = SAMPLE_TEXTURE2D(_RippleTex, sampler_RippleTex, uvRipple + float2( 1.0/1024,0)).r;
                float hD = SAMPLE_TEXTURE2D(_RippleTex, sampler_RippleTex, uvRipple + float2(0,-1.0/1024)).r;
                float hU = SAMPLE_TEXTURE2D(_RippleTex, sampler_RippleTex, uvRipple + float2(0, 1.0/1024)).r;
                float2 grad = float2(hL - hR, hD - hU); // screen-space gradient
                float3 rippleN_TS = normalize(float3(grad * _RippleNormalStrength, 1));
                nTS = normalize(nTS + rippleN_TS * _RippleStrength * 10.0);

                // Tangent->World
                float3x3 t2w = CreateTangentToWorld(normalize(i.normalWS), normalize(i.tangentWS.xyz), i.tangentWS.w);
                float3 normalWS = normalize(TransformTangentToWorld(nTS, t2w));

                // View dir
                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(i.positionWS);

                // --- Fresnel ---
                float NdotV = saturate(dot(normalWS, viewDirWS));
                float fresnel = pow(1.0 - NdotV, _FresnelPower);

                // --- Refraction: sample opaque texture with normal offset ---
                float2 refrUV = uvSS + normalWS.xz * _RefractionStrength;
                float3 refrColor = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, refrUV).rgb;

                // --- Reflection: simple mix using fresnel (env via PBR will also kick in) ---
                float3 baseCol = _BaseColor.rgb;
                float3 reflectCol = lerp(baseCol, refrColor, 0.5);
                float3 combined = lerp(refrColor, reflectCol, _ReflectionStrength * fresnel);

                // --- Foam (threshold on ripple height + normal steepness) ---
                float foamMask = saturate((rippleH - _FoamThreshold) * 5.0);
                float foamUVScale = 6.0;
                float2 foamUV = i.uv * foamUVScale + _Time.x * float2(0.05, -0.03);
                float foamTex = SAMPLE_TEXTURE2D(_FoamTex, sampler_FoamTex, foamUV).r;
                float foam = foamMask * foamTex * _FoamIntensity;
                combined = lerp(combined, _FoamColor.rgb, foam);

                // --- Build URP inputs for PBR lighting ---
                InputData inputData = (InputData)0;
                inputData.positionWS      = i.positionWS;
                inputData.normalWS        = normalWS;
                inputData.viewDirectionWS = viewDirWS;
                inputData.positionCS      = i.positionCS;
                inputData.fogCoord        = i.fogFactor;

                SurfaceData surfaceData = (SurfaceData)0;   
                surfaceData.albedo     = combined;
                surfaceData.metallic   = _Metallic;
                surfaceData.smoothness = _Smoothness;
                surfaceData.occlusion  = 1;
                surfaceData.normalTS   = nTS; // keep TS for additional lights
                surfaceData.alpha      = saturate(_BaseColor.a * softFade);
                
                half4 col = UniversalFragmentPBR(inputData, surfaceData);
                col.rgb = MixFog(col.rgb, i.fogFactor);
                return col;
            }
            ENDHLSL
        }
    }
}