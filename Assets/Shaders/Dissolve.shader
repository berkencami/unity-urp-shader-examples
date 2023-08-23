Shader "Custom/Dissolve"
{
	Properties
	{
		_Color("Main Color",Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		[NoScaleOffset]_NoiseTex("Noise Texture", 2D) = "white" {}
		_Dissolve("Dissolve", Range(0.0, 1.0)) = 0.5
		_Edge("Edge", Range(0.0, 0.2)) = 0.1
		_OutterEdgeColor("Outter Edge Color", Color) = (1,1,1,1)
		_InnerEdgeColor("Inner Edge Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "Queue"="Geometry" "RenderType"="Opaque" }

		Pass
		{
			Cull Off

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
				float2 uvMainTex : TEXCOORD0;
				float2 uvNoiseTex : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _Dissolve;
			float _Edge;
			fixed4 _OutterEdgeColor;
			fixed4 _InnerEdgeColor;
			fixed4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvNoiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed cutout = tex2D(_NoiseTex, i.uvNoiseTex).r;
				clip(cutout - _Dissolve);

				float degree = saturate((cutout - _Dissolve) / _Edge);
				fixed4 edgeColor = lerp(_OutterEdgeColor, _InnerEdgeColor, degree);

				fixed4 col = tex2D(_MainTex, i.uvMainTex)*_Color;

				fixed4 finalColor = lerp(edgeColor, col, degree);
				return fixed4(finalColor.rgb, 1);
			}
			ENDCG
		}
	}
}
