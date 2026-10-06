Shader "Custom/SurfaceShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Opaque"
			"Queue" = "Geometry"
		}

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			float4 _BaseColor;

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct vout
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS   : TEXCOORD0;
            };

            vout vert(appdata v)
            {
                vout o = (vout)0;

                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.normalWS   = TransformObjectToWorldNormal(v.normalOS);

                return o;
            }

			float4 frag(vout i) : SV_TARGET
			{
                float3 N = normalize(i.normalWS);
                float3 L = normalize(float3(0, 0, 1));
                float NdotL = saturate(dot(N, L));

                if (NdotL < 0.33)
                {
                    return float4(0.01, 0.05, 0.2, 1.0);
                }
                else if (NdotL < 0.66)
                {
                    return float4(0.05, 0.2, 0.6, 1.0);
                }

                return float4(0.15, 0.5, 1.0, 1.0);
			}

			ENDHLSL
		}
    }
}
