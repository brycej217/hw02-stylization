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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Shaders/Includes/LightingHelp.hlsl"

			float4 _BaseColor;

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct vout
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS   : TEXCOORD1;
            };

            vout vert(appdata v)
            {
                vout o = (vout)0;

                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.positionWS = TransformObjectToWorld(v.positionOS.xyz);
                o.normalWS   = TransformObjectToWorldNormal(v.normalOS);

                return o;
            }

			float4 frag(vout i) : SV_TARGET
			{
                float3 N = normalize(i.normalWS);
                float2 thresholds = float2(0.33, 0.66);
                float3 ramped = float3(0.2, 0.4, 1.0);

                // directional light
                float3 mainColor;
                float3 mainDir;
                float distAttenuation;
                float shadowAttenuation;
                GetMainLight_float(i.positionWS, mainColor, mainDir, distAttenuation, shadowAttenuation);
                float mainDiffuse = saturate(dot(N, mainDir)) * distAttenuation * shadowAttenuation;

                // additional lights
                float3 addColor;
                float addDiffuse;
                ComputeAdditionalLighting_float(i.positionWS.xyz, N, thresholds, ramped, addColor, addDiffuse);
                
                float diffuse = mainDiffuse + addDiffuse;

                float3 shadow = float3(0.01, 0.05, 0.2);
                float3 midtone = float3(0.05, 0.2, 0.6);
                float3 highlight = float3(0.15, 0.5, 1.0);

                float3 output;
                ChooseColor_float(highlight, midtone, shadow, diffuse, thresholds, output);
                return float4(output, 1.0);
			}

			ENDHLSL
		}
    }
}
