Shader "Custom/FlagShader"
{
    Properties
    {
        _MainTex("Texture",2D)="white"{}
        _Color ("Color",Color) = (1,1,1,1)
        _Speed("Speed", Range(0, 5.0)) = 1
        _Frequency("Frequency", Range(0, 1.3)) = 0
        _Amplitude("Amplitude", Range(0, 5.0)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }
        Cull off

        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"


            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            float _Frequency;
            float _Amplitude;
            float4 _Color;

            v2f vert(appdata_base v)
            {
                v2f o;
                v.vertex.y += cos((v.vertex.x + _Time.y * _Speed) * _Frequency) * _Amplitude * (v.vertex.x - 5);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv) * _Color;
            }
            ENDCG

        }
    }
    FallBack "Diffuse"
}