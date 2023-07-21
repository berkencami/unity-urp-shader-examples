Shader "Unlit/Gradient Skybox"
{
	Properties
	{
		_Color("Sky color", Color) = (1,1,1,1)
		_Color2("Ground color", Color) = (1,1,1,1)
		_SkyPos("Sky position", Range(-1.0, 1.0)) = 0.5
		_GroundPos("Ground position", Range(-1.0, 1.0)) = -0.5
	}
	SubShader
	{
		Tags {"Queue"="Background"}
		Pass
		{
			Cull Back
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _Color;
			uniform float4 _Color2;
			uniform float _SkyPos;
			uniform float _GroundPos;

			struct appdata
			{
				float4 localPos: POSITION;
				float3 texCoord: TEXCOORD0;
			};

			struct v2f
			{
				float4 clipPos: SV_POSITION;
				float3 texCoord: TEXCOORD0;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.clipPos = UnityObjectToClipPos(i.localPos);
				o.texCoord = i.texCoord;
				return o;
			}
			
			float4 frag(v2f i): COLOR
			{
				float f = clamp((i.texCoord.y-_GroundPos)/(_SkyPos-_GroundPos),0,1);
				return lerp(_Color2, _Color, f);
			}

			ENDCG
		}
	}
}