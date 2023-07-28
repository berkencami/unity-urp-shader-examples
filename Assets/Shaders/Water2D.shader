Shader "Unlit/Water2D"
{
    Properties
    {
        [NoScaleOffset] _DisplacementMap ("Displacement Map", 2D) = "bump" {}
        _DistortionStrength("Distortion Strength", Range(0.06, 0.4)) = 0.06
        _MainTex("Render Texture", 2D) = "white" {}
        _Color("Color", Color) = (0,0,0,0)
        _FoamAmountX("Foam Amount", Range(0, 0.05)) = 0.0
        _FoamColor("Foam Color", Color) = (0,0,0,0)
        _WaveSpeed ("Horizontal Wave Speed",Range(0,1)) = 0

    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Opaque"
        }

        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag


            sampler2D _DisplacementMap;
            float4 _DisplacementMap_ST;
            float _DistortionStrength;
            float _DisplacementOffset;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;

            float _FoamAmountX;
            float _WaveSpeed;
            fixed4 _FoamColor;


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 displacementUv : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 displacementUv : TEXCOORD1;
            };

            void WaveAnimation()
            {
                _DisplacementOffset += _WaveSpeed * _Time.y;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.displacementUv = TRANSFORM_TEX(v.displacementUv, _DisplacementMap);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                WaveAnimation();

                fixed2 displacement = tex2D(_DisplacementMap,
                                            float2(i.displacementUv.x + _DisplacementOffset, i.displacementUv.y));

                fixed2 calculatedDisplacement = (displacement.rg - .5) * _DistortionStrength;
                fixed2 displacementUv = i.uv.xy + calculatedDisplacement;

                fixed4 output = tex2D(_MainTex, displacementUv);

                if (abs(calculatedDisplacement.g) <= _FoamAmountX)
                {
                    output = _FoamColor;
                }
                return output * _Color;
            }
            ENDCG
        }
    }
}