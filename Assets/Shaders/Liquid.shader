Shader "Custom/Liquid"
{
    Properties
    {
        [Header(Color properties)]
        [Space(10)]
        _TopColor("TopColor",Color) =(1,1,1,1)
        _MidColor("MidColor",Color) =(1,1,1,1)
        _BaseColor("BaseColor",Color)=(1,1,1,1)

        [Header(Remap properties)]
        [Space(10)]
        _TopValue("TopValue", float) = 0
        _BotValue("BotValue", float) = 0

        [Header(Fill amount properties)]
        [Space(10)]
        _FillAmount("Fill Amount",Range(0,1))=0
        _MidAmount("MidAmount", Range(0,0.2)) =0


        [Header(Wave animation properties)]
        [Space(10)]
        _Speed("Speed", Range(0, 5.0)) = 1
        _Frequency("Frequency", Range(0, 10)) = 0
        _Amplitude("Amplitude", Range(0, 0.01)) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        ZWrite On
        Cull Off
        AlphaToMask On
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
                float4 vertex : SV_POSITION;
                float4 positionInObjectCoordinates : TEXCOORD0;
                float liquidEdge : TEXCOORD1;
            };

            float4 _TopColor;
            float4 _MidColor;
            float4 _BaseColor;
            float _FillAmount;
            float _MidAmount;
            float _Speed;
            float _Frequency;
            float _Amplitude;
            float _TopValue;
            float _BotValue;

            float Remap(float value, float from1, float to1, float from2, float to2)
            {
                return (value - from1) / (to1 - from1) * (to2 - from2) - from2;
            }


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                if (v.vertex.y > .1)
                {
                    v.vertex.y += cos((v.vertex.x + _Time.y * _Speed) * _Frequency) * _Amplitude * (v.vertex.x - 5);
                }
                float3 worldPosition = mul(unity_ObjectToWorld, v.vertex.xyz);
                o.liquidEdge = worldPosition.y - Remap(_FillAmount, 0, 1, _BotValue, _TopValue);
                return o;
            }

            float4 frag(v2f i, fixed facing :VFACE) : SV_Target
            {
                fixed4 midEdge = step(i.liquidEdge, 0.5) - smoothstep(i.liquidEdge, 0.5, (0.5 - _MidAmount));
                fixed4 midEdgeColor = midEdge * _MidColor;

                fixed4 base = step(i.liquidEdge, 0.5) - midEdge;
                fixed4 baseColor = base * _BaseColor;

                fixed4 renderBase = baseColor + midEdgeColor;
                fixed4 renderTop = _TopColor * (midEdge + base);

                return facing > 0 ? renderBase : renderTop;
            }
            ENDCG
        }
    }
}