﻿Shader "Custom/CharacterCellShaderWithOutline"
{
	Properties
	{
		_Color ("Unlit Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("Main Texture", 2D) = "white" {}
		_BumpMap ("Bumpmap", 2D) = "bump" {}
		_Ramp("Shader Gradient", 2D) = "white" {}

		_OutlineColor("Color", Color) = (1,1,1,1)
		_Outline("Outline Width", Range(.002, 0.03)) = .005
	}

		SubShader
		{
			// Render Outline
			Pass
			{
				Cull Front

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				float _Outline;
				float4 _OutlineColor;

				struct v2f
				{
					float4 pos : SV_POSITION;
				};

				float4 vert(appdata_base v) : SV_POSITION
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					float3 normal = mul((float3x3) UNITY_MATRIX_MV, v.normal);
					normal.x *= UNITY_MATRIX_P[0][0];
					normal.y *= UNITY_MATRIX_P[1][1];
					o.pos.xy += normal.xy * _Outline;
					return o.pos;
				}

				half4 frag(v2f i) : COLOR
				{
					return _OutlineColor;
				}

				ENDCG
			}

			Tags{ "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			#pragma surface surf ToonRamp

			sampler2D _Ramp;

			#pragma lighting ToonRamp exclude_path:prepass
			inline half4 LightingToonRamp(SurfaceOutput s, half3 lightDir, half atten)
			{
				#ifndef USING_DIRECTIONAL_LIGHT
				lightDir = normalize(lightDir);
				#endif

				half d = dot(s.Normal, lightDir)*0.5 + 0.5;
				half3 ramp = tex2D(_Ramp, float2(d,d)).rgb;

				half4 c;
				c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
				c.a = 0;
				return c;
			}


			struct Input
			{
				float2 uv_MainTex : TEXCOORD0;
				float2 uv_BumpMap;
			};

			sampler2D _MainTex;
			sampler2D _BumpMap;
			float4 _Color;

			void surf(Input IN, inout SurfaceOutput o) 
			{
				half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				o.Alpha = c.a;
				o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			}
			ENDCG
		
		}

		Fallback "Diffuse"
}
