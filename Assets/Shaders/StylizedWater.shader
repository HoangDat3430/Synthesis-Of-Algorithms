Shader "Custom/StylizedWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _NoiseTex ("Noise Texture", 2D) = "white" {}

        _Metallic ("Metallic", Range(0,1)) = 0.5
        _Smoothness ("Smoothness", Range(0,1)) = 0.5

        _Speed ("Speed", float) = 1
        _Amplitude ("Amplitude", float) = 1
        _Scale ("Scale", float) = 1
    }
    SubShader
    {
        Name "Forward Lit"
        Tags 
        { 
            "RenderType"="Opaque" 
            "Queue"="Transparent" 
            "RenderPipeline"="UniversalRenderPipeline" 
        }
        LOD 100

        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Assets/ShaderLib/StylizedWaterPass.hlsl"
            ENDHLSL
        }
    }
}
