Shader "Custom/ToonWater"
{
    Properties
    {
        [Header(Depth)]
        [Space(10)]
        _DepthGradientShallow("Depth Gradient Shallow", Color) = (1,1,1,1)
        _DepthGradientDeep("Depth Gradient Deep", Color) = (1,1,1,1)
        _DepthMaxDistance("Depth Maximum Distance", Float) = 1

        [Header(Noise)]
        [Space(10)]
        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        _SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.7
        _SurfaceNoiseScroll("Surface Noise Scroll Amount", Vector) = (0, 0, 0, 0)
        [NoScaleOffset]_SurfaceDistortion("Surface Distortion", 2D) = "white" {}
        _SurfaceDistortionAmount("Surface Distortion Amount", Range(0, 1)) = 0.27

        [Header(Foam)]
        [Space(10)]
        _FoamDistance("Foam Distance", Float) = 0.04
        _FoamMaxDistance("Foam Maximum Distance", Float) = 0.4
        _FoamMinDistance("Foam Minimum Distance", Float) = 0.04
        [HDR]_FoamColor("Foam Color", Color) = (1,1,1,1)

        [Header(Wave animation properties)]
        [Space(10)]
        _DisplacementTex("Displacement texture", 2D) = "white" {}
        _DisplacementParams("Speed (.xy) | Intensity (.z)", Vector) = (0, 0, 0, 0)
        _Speed("Speed", Range(0, 5.0)) = 0

    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 noiseUV : TEXCOORD0;
                float2 distortUV : TEXCOORD1;
                float4 screenPosition : TEXCOORD2;
                float3 viewNormal : NORMAL;
            };

            sampler2D _SurfaceDistortion;
            sampler2D _CameraDepthTexture;
            sampler2D _CameraNormalsTexture;
            sampler2D _SurfaceNoise;
            sampler2D _DisplacementTex;
            float4 _SurfaceDistortion_ST;
            float4 _DisplacementTex_ST;
            float4 _SurfaceNoise_ST;

            float _SurfaceDistortionAmount;
            float _SurfaceNoiseCutoff;
            float4 _DepthGradientShallow;
            float4 _DepthGradientDeep;
            float4 _FoamColor;
            float _DepthMaxDistance;
            float _FoamDistance;
            float2 _SurfaceNoiseScroll;
            float _FoamMaxDistance;
            float _FoamMinDistance;
            float _Speed;

            float4 _DisplacementParams;

            float4 alphaBlend(float4 top, float4 bottom)
            {
                float3 color = (top.rgb * top.a) + (bottom.rgb * (1 - top.a));
                float alpha = top.a + bottom.a * (1 - top.a);

                return float4(color, alpha);
            }

            float4 MoveVertex(float4 vertex, float3 normal, float2 uv)
            {
                float4 displacementMap = tex2Dlod(_DisplacementTex,
                                                  float4(uv + _DisplacementParams.xy * _Time.y*_Speed, 0, 0));

                vertex.xyz += displacementMap * normal * _DisplacementParams.z;

                return vertex;
            }

            v2f vert(appdata v)
            {
                v2f o;

                v.vertex = MoveVertex(v.vertex, v.normal, v.uv);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPosition = ComputeScreenPos(o.vertex);
                o.noiseUV = TRANSFORM_TEX(v.uv, _SurfaceNoise);
                o.distortUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion);
                o.viewNormal = COMPUTE_VIEW_NORMAL;


                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
                float existingDepthLinear = LinearEyeDepth(existingDepth01);
                float depthDifference = existingDepthLinear - i.screenPosition.w;

                float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
                float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);

                float2 distortSample = (tex2D(_SurfaceDistortion, i.distortUV).xy * 2 - 1) * _SurfaceDistortionAmount;

                float2 noiseUV = float2((i.noiseUV.x + _Time.y * _SurfaceNoiseScroll.x) + distortSample.x,
                                        (i.noiseUV.y + _Time.y * _SurfaceNoiseScroll.y) + distortSample.y);
                float surfaceNoiseSample = tex2D(_SurfaceNoise, noiseUV).r;
                float3 existingNormal = tex2Dproj(_CameraNormalsTexture, UNITY_PROJ_COORD(i.screenPosition));
                float3 normalDot = saturate(dot(existingNormal, i.viewNormal));
                float foamDistance = lerp(_FoamMaxDistance, _FoamMinDistance, normalDot);
                float foamDepthDifference = saturate(depthDifference / foamDistance);
                float surfaceNoiseCutoff = foamDepthDifference * _SurfaceNoiseCutoff;
                float surfaceNoise = surfaceNoiseSample > surfaceNoiseCutoff ? 1 : 0;


                float4 surfaceNoiseColor = _FoamColor;
                surfaceNoiseColor.a *= surfaceNoise;

                return alphaBlend(surfaceNoiseColor, waterColor);
            }
            ENDCG
        }
    }
}