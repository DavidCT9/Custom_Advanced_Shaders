Shader "ACG/GerstnerWaves3D"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Amp("Amplitude", Range(0,1)) = 0.2
        _Freq("Frequency", Range(0,10)) = 1
        _Speed("Speed", Range(0,5)) = 1
        _Dir("Direction", Vector) = (1,0,1,0)

        _Alpha("Transparency", Range(0,1)) = 1   // << NEW
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha     // << NEW
        ZWrite Off                          // optional: prevents sorting artifacts

        CGPROGRAM
        #pragma surface surf Standard alpha:fade vertex:vert

        sampler2D _MainTex;
        float _Amp;
        float _Freq;
        float _Speed;
        float4 _Dir;

        float _Alpha;   // << NEW

        struct Input
        {
            float2 uv_MainTex;
        };

        float3 GerstnerWave(float3 pos, float time)
        {
            float2 dir = normalize(_Dir.xz);

            float k = _Freq;
            float A = _Amp;

            float phase = k * dot(dir, pos.xz) + time * _Speed;

            float3 displaced;
            displaced.x = pos.x + dir.x * A * cos(phase);
            displaced.z = pos.z + dir.y * A * cos(phase);
            displaced.y = pos.y + A * sin(phase);

            return displaced;
        }

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            float t = _Time.y;
            float3 wp = mul(unity_ObjectToWorld, v.vertex).xyz;

            float3 displaced = GerstnerWave(wp, t);

            v.vertex = mul(unity_WorldToObject, float4(displaced, 1.0));
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;

            o.Alpha = _Alpha;   // << NEW
        }

        ENDCG
    }

    Fallback "Transparent"
}
