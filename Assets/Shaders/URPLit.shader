Shader "Custom/URPLit"
{
    Properties
    {
        [Header(Surface Options)]
        [MainTexture] _MainTex ("Texture", 2D) = "white" {}
        [MainColor] _MainColor ("Tint", Color) = (1,1,1,1)

        _Smoothness ("Smoothness", Range(0,1)) = 0.5
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
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS

            #define _SPECULAR_COLOR

            #include "Assets/ShaderLib/URPCustomLitPass.hlsl"
            
            ENDHLSL
        }
    }
}
