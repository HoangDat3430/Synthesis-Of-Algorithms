Shader "Unlit/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Scroll Speed", Vector) = (1,0,0,0)
        _TileIndex ("Tile Index", Vector) = (0,0,0,0)
        _GridSize ("GridSize", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Speed;
            Vector _GridSize;
            Vector _TileIndex;
            
            float2 GetPositionOnTexture(float2 uv)
            {
                return uv / _GridSize + _TileIndex / _GridSize;
            }

            v2f vert (appdata v)
            {
                v2f o;
                float2 uv = GetPositionOnTexture(v.uv);
                uv += _Speed.xy * _Time.x;
                o.uv = uv;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                //i.uv = GetPositionOnTexture(i.uv);
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
