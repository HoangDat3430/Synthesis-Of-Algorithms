Shader "Custom/URPLit"
{
    Properties
    {
        [Header(Surface Options)]
        [MainTexture] _MainTex ("Texture", 2D) = "white" {}
        [MainColor] _MainColor ("Tint", Color) = (1,1,1,1)
        [NoScaleOffset][Normal] _NormalTex ("Normal Map", 2D) = "bump" {}

        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.5
        _AlphaCutOff ("Alpha Clip Threshold", Range(0,1)) = 0.5

        [HideInInspector] _Cull("Cull", float) = 2
        [HideInInspector] _SourceBlend ("Source Blend", float) = 0
        [HideInInspector] _DestBlend ("Destination Blend", float) = 0
        [HideInInspector] _ZWrite ("ZWrite", float) = 0

        [HideInInspector] _FaceRenderingMode ("Face Rendering Mode", float) = 0
        [HideInInspector] _SurfaceType ("Surface Type", float) = 0
    }
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalRenderPipeline" 
        }
        LOD 100
        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            
            Blend [_SourceBlend] [_DestBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature_local _ALPHA_CUTOUT
            #pragma shader_feature_local _DOUBLE_SIDED_NORMALS
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #include "Assets/ShaderLib/URPCustomLitPass.hlsl"
            
            ENDHLSL
        }

        Pass
        {
            Name "Shadow Caster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            Cull [_Cull]
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature_local _ALPHA_CUTOUT
            #pragma shader_feature_local _DOUBLE_SIDED_NORMALS

            #include "Assets/ShaderLib/URPCustomLitShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "URPLitCustomGUI"
}
