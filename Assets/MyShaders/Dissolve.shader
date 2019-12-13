Shader "Custom/Dissolve"
{
    Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bumpmap", 2D) = "bump" {}
		_DissolvePattern("DissolvePattern", 2D) = "white" {}
		_EmmisionTex("Emmision Texture", 2D) = "blue" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 200
			
			Pass{
				ColorMask 0
			}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB

        CGPROGRAM
		#pragma surface surf Standard fullforwardshadows alpha:fade
		#pragma target 3.0

        sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _DissolvePattern;
		sampler2D _EmmisionTex;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_DissolvePattern;
			float2 uv_EmmisionTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

       
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			float emissionLineWidth = 0.04;
			
			float boder = (_SinTime.a + 1) / 2;
			float pattern = tex2D(_DissolvePattern, IN.uv_DissolvePattern).r;
			if (pattern > boder)
				c.a = 1;
			else
				c.a = 0;

			if( pattern >= boder && pattern <boder + emissionLineWidth && pattern > emissionLineWidth + 0.03)
				o.Emission = tex2D(_EmmisionTex, IN.uv_EmmisionTex);

			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Albedo = c.rgb;
			
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
