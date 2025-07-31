Shader "Custom/URPLit"
{
    Properties
    {
        [Header(Surface Options)]
        [MainTexture] _MainTex ("Texture", 2D) = "white" {}
        [MainColor] _MainColor ("Tint", Color) = (1,1,1,1)

        _Smoothness ("Smoothness", Range(0,1)) = 0.5

        [HideInInspector] _SourceBlend ("Source Blend", float) = 0
        [HideInInspector] _DestBlend ("Destination Blend", float) = 0
        [HideInInspector] _ZWrite ("ZWrite", float) = 0

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
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define _SPECULAR_COLOR
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

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
            
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Assets/ShaderLib/URPCustomLitShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "URPLitCustomGUI"
}
