Shader "Unlit/Silhouette"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
	}
	SubShader
	{
        Tags{ "Queue" = "Transparent" }

		Pass
		{
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

            #include "UnityCG.cginc"

            uniform float4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD;
                float3 viewDir : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;

                float4x4 modelMatrix = unity_ObjectToWorld;
                float4x4 modelMatrixInverse = unity_WorldToObject;

                o.normal = normalize(mul(float4(v.normal, 0.0), modelMatrixInverse).xyz);
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(modelMatrix , v.vertex).xyz);

                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(v2f i) : COLOR
            {
                float3 normalDirection = normalize(i.normal);
                float3 viewDirection = normalize(i.viewDir);

                float newOpacity = min(1.0, _Color.a / abs(dot(viewDirection, normalDirection)));

                return float4(_Color.rgb, newOpacity);
            }

			ENDCG
		}
	}
}
