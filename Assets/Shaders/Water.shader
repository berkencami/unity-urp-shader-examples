Shader "Unlit/Water"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _DistortionText("Distortion Texture",2D) ="white"{}
        [Space(10)]
        _DistortionSpeed("Distortion Speed",Range(-1,1))=0
        _DistortionValue("Distortion Value",Range(2,20)) =0

        [Header(Wave animation properties)]
        [Space(10)]
        _Speed("Speed", Range(0, 5.0)) = 0
        _Frequency("Frequency", Range(0, 1)) = 1
        _Amplitude("Amplitude", Range(0, 0.5)) = 1

        [Header(Edge Foam)]
        [Space(10)]
        [HDR]_EdgeFoamColor ("Edge Color", Color) = (1, 1, 1, 1)
        _EdgeFoamDepth ("Scale", float) = 10.0
        _ShadowColor ("Shadow Color", Color) = (0.5, 0.5, 0.5, 1.0)


    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
        }
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 grabPosition : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _DistortionText;
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;
            float _DistortionSpeed;
            float _DistortionValue;
            float _Speed;
            float _Frequency;
            float _Amplitude;
            float3 _EdgeFoamColor;
            float _EdgeFoamDepth;
            float3 _ShadowColor;


            v2f vert(appdata v)
            {
                v2f o;
                o.grabPosition = ComputeGrabScreenPos(
                    mul(UNITY_MATRIX_VP, float4(mul(unity_ObjectToWorld, v.vertex).xyz, 1)));
                v.vertex.y += cos((v.vertex.x + _Time.y * _Speed) * _Frequency) * _Amplitude;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float shadowMask = 1.0;
                float2 screenCoord = i.grabPosition.xy / i.grabPosition.w;
                float depth = tex2D(_CameraDepthTexture, screenCoord.xy).x;
                float opticalDepth = abs(LinearEyeDepth(depth) - LinearEyeDepth(i.vertex.z));
                float edgeFoamMask = round(exp(-opticalDepth / _EdgeFoamDepth));
                float3 edgeFoamColor = lerp(0, _EdgeFoamColor, edgeFoamMask);
                edgeFoamColor = edgeFoamColor * lerp(_ShadowColor, 1, shadowMask);

                fixed4 distortion = tex2D(_DistortionText, i.uv + (_Time * _DistortionSpeed)).r;
                i.uv += distortion / _DistortionValue;
                fixed4 col = tex2D(_MainTex, i.uv) + fixed4(edgeFoamColor, 1);
                return col;
            }
            ENDCG
        }
    }
}