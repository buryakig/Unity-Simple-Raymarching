Shader "OnRender/SurfaceRayMarch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define MAX_STEPS 100
            #define MAX_DIST  100.0f  
            #define SURF_DIST  0.01f  

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            //sampler2D _MainTex;                           // We don't need it for the raymarch

            uniform float _ZMovingAmount;

            static float3 rayOrigin = float3(0, 1, 0);

            static const float3 cyan = float3(0, 1, 1);
            static const float3 darkBlue = float3(0, 0, 0.2);

            static const float4 surface = float4(0, 1, 6, 1); //surfase x, y, z of the center + the bound radius

            float SineWobbling(float3 Point)
            {
               return 0.05 * surface.w * sin(_Time.w + 10.0f * (Point.x + Point.y + Point.z));  // Applying the wobbling with the sine function that depends
                                                                                                // on time and position of the point of the surface
            }

            // We have a horizontal plane at zero "heigth"
            float DistanceToPlane(float3 Point)
            {
                return Point.y;
            }

            // Calculating distance taking wobbling into account
            float DistanceToSurface(float3 Point)
            {
                float w = SineWobbling(Point);
                float dist = length(Point - surface.xyz) - (surface.w + w);

                return dist;
            }

            // Main raymarching function
            float RayMarchingResult(float3 rayOrig, float3 rayDir)
            {
                float distOrig = 0.0f;                                      // Set initial distance to the origin to zero
                                                 
                for (int i = 0; i < MAX_STEPS; i++)                         
                {
                    float3 Point = rayOrig + rayDir * distOrig;              // Throwing a ray in the given direction

                    // Calculating distance to each object in the scene
                    float distSurf = DistanceToSurface(Point);              // Calculate distance to the surface
                    float distPlane = DistanceToPlane(Point);               // Calculate distance to the plane
                    
                    float dist = min(distSurf, distPlane);                  // Taking the minimal one
                    distOrig += dist;                                       // Remembering, how much we have passed in the current direction

                    if (distOrig > MAX_DIST || dist < SURF_DIST)    break;  // If we have gone too far, or if we are enought close to the surface - break
                }
                
                return distOrig;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv - 0.5;                                     //  Making the uv (0, 0) at the screen center
                float3 col = 0.0f;
                float3 rayDirection = normalize(float3(uv.x, uv.y, 1.0f));  // Ray direction comes from each pixel in forward direction
                rayOrigin.z += _ZMovingAmount;
                float d = RayMarchingResult(rayOrigin, rayDirection);       // Do the raymarching
                float maxDist = surface.z + surface.w - _ZMovingAmount;                      // Calculate approximate max distance in te raymarch scene to figure out the normalization coefficient
                col.rgb = lerp(cyan, darkBlue, d / maxDist);                                        // Write the normalized distance to the red channel
                
                return float4(col, 1.0f);
            }
            ENDCG
        }
    }
}
