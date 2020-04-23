// Pcx - Point cloud importer & renderer for Unity
// https://github.com/keijiro/Pcx

Shader "Point Cloud/WaveShader"
{
    Properties
    {
        _Tint("Tint", Color) = (0.5, 0.5, 0.5, 1)
        _PointSize("Point Size", Float) = 0.05
        [Toggle] _Distance("Apply Distance", Float) = 1
        
        _WaveMaxRadius("Wave Max Radius", Float) = 20.0
        _WaveWidth("Wave Width", Float) = 0.2
        _WaveSpeed("Wave Speed", Float) = 2.0
        _WaveStartTime("Wave Start Time", Float) = -1000.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #pragma multi_compile_fog
            #pragma multi_compile _ UNITY_COLORSPACE_GAMMA
            #pragma multi_compile _ _DISTANCE_ON
            #pragma multi_compile _ _COMPUTE_BUFFER

            #include "UnityCG.cginc"
            #include "/Assets/Pcx/Runtime/Shaders/Common.cginc"

            struct Attributes
            {
                float4 position : POSITION;
                half3 color : COLOR;
            };

            struct Varyings
            {
                float4 position : SV_Position;
                half3 color : COLOR;
                half psize : PSIZE;
                UNITY_FOG_COORDS(0)
            };

            half4 _Tint;
            float4x4 _Transform;
            half _PointSize;
            
            half _WaveMaxRadius;
            half _WaveWidth;
            half _WaveSpeed;
            half _WaveStartTime;
            
            float cubicPulse(float c, float w, float x)
            {
                x = abs(x - c);
                if( x>w ) return 0.0;
                x /= w;
                return 1.0 - x*x*(3.0-2.0*x);
            }
            
            float expStep(float x, float k, float n)
            {
                return exp( -k*pow(x,n) );
            }

        #if _COMPUTE_BUFFER
            StructuredBuffer<float4> _PointBuffer;
        #endif

        #if _COMPUTE_BUFFER
            Varyings Vertex(uint vid : SV_VertexID)
        #else
            Varyings Vertex(Attributes input)
        #endif
            {
            #if _COMPUTE_BUFFER
                float4 pt = _PointBuffer[vid];
                float4 pos = mul(_Transform, float4(pt.xyz, 1));
                half3 col = PcxDecodeColor(asuint(pt.w));
            #else
                float4 pos = input.position;
                half3 col = input.color;
            #endif

            #ifdef UNITY_COLORSPACE_GAMMA
                col *= _Tint.rgb * 2;
            #else
                col *= LinearToGammaSpace(_Tint.rgb) * 2;
                col = GammaToLinearSpace(col);
            #endif
            
                // wave shader magic
                float4 wpos = mul(unity_ObjectToWorld, pos);
                
                // use camera as target object
                float delta = distance(wpos, _WorldSpaceCameraPos);
                
                // calculate time
                float t = _Time.y - _WaveStartTime;
                
                // calculate color applience
                float percentageDelta = min(1.0, delta / _WaveMaxRadius);
                float windowedDelta = cubicPulse(percentageDelta, _WaveWidth, t * _WaveSpeed);
                
                // apply distance filter
                //float filteredDelta = lerp(windowedDelta, 0, percentageDelta);
                float stepUp = 1.0 - expStep(percentageDelta, 4.0, 5.0);
                float filteredDelta = lerp(windowedDelta, 0, stepUp);
                
                // lerp color
                col = lerp(half3(0.0, 0.0, 0.0), col, filteredDelta);

                Varyings o;
                o.position = UnityObjectToClipPos(pos);
                o.color = col;
            #ifdef _DISTANCE_ON
                o.psize = _PointSize / o.position.w * _ScreenParams.y;
            #else
                o.psize = _PointSize;
            #endif
                UNITY_TRANSFER_FOG(o, o.position);
                return o;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                half4 c = half4(input.color, _Tint.a);
                UNITY_APPLY_FOG(input.fogCoord, c);
                return c;
            }

            ENDCG
        }
    }
}
