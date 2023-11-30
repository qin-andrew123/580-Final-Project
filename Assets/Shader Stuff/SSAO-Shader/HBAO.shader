Shader"Unlit/HBAO"
{
    Properties
    {
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            // RenderType: <None>
            // Queue: <None>
            // DisableBatching: <None>
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalFullscreenSubTarget"
        }
        Pass
        {
Name"DrawProcedural"
        
        // Render State
        Cull
Off
        Blend
Off
        ZTest
Off
        ZWrite
Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma vertex vert
        #pragma fragment frag
        // #pragma enable_d3d11_debug_symbols
        
        /* WARNING: $splice Could not find named fragment 'DotsInstancingOptions' */
        /* WARNING: $splice Could not find named fragment 'HybridV1InjectedBuiltinProperties' */
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
#define FULLSCREEN_SHADERGRAPH
        
        // Defines
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_VERTEXID
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
        
        // Force depth texture because we need it for almost every nodes
        // TODO: dependency system that triggers this define from position or view direction usage
#define REQUIRE_DEPTH_TEXTURE
#define REQUIRE_NORMAL_TEXTURE
        
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DRAWPROCEDURAL
#define REQUIRE_DEPTH_TEXTURE
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenShaderPass.cs.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
struct Attributes
{
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
#endif
    uint vertexID : VERTEXID_SEMANTIC;
};
struct SurfaceDescriptionInputs
{
    float2 NDCPosition;
    float2 PixelPosition;
    
    float3 ViewSpacePosition;
    float3 WorldSpacePosition;
    
    float3 ViewSpaceNormal;
    float3 WorldSpaceNormal;
};
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float4 texCoord0;
    float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
};
struct VertexDescriptionInputs
{
};
struct PackedVaryings
{
    float4 positionCS : SV_POSITION;
    float4 texCoord0 : INTERP0;
    float4 texCoord1 : INTERP1;
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
};
        
PackedVaryings PackVaryings(Varyings input)
{
    PackedVaryings output;
    ZERO_INITIALIZE(PackedVaryings, output);
    output.positionCS = input.positionCS;
    output.texCoord0.xyzw = input.texCoord0;
    output.texCoord1.xyzw = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
    return output;
}
        
Varyings UnpackVaryings(PackedVaryings input)
{
    Varyings output;
    output.positionCS = input.positionCS;
    output.texCoord0 = input.texCoord0.xyzw;
    output.texCoord1 = input.texCoord1.xyzw;
#if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
    return output;
}
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        CBUFFER_END
        
        
        // Object and Global properties
float _FlipY;
        
        // Graph Includes
        // GraphIncludes: <None>
int _SampleSize;
float3 _Samples[256];

float _Radius;
float _Intensity;
int _ShowSSAO;
int _StepUpperBound;
        // Graph Functions
        
void Unity_SceneDepth_Raw_float(float4 UV, out float Out)
{
    Out = SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy);
}


void Unity_SceneDepth_LinearEye_float(float4 UV, out float Out)
{
    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
}
        
TEXTURE2D_X(_BlitTexture);
float4 Unity_Universal_SampleBuffer_BlitSource_float(float2 uv)
{
    uint2 pixelCoords = uint2(uv * _ScreenSize.xy);
    return LOAD_TEXTURE2D_X_LOD(_BlitTexture, pixelCoords, 0);
}

//random range

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
    float randomno = frac(sin(dot(Seed, float2(12.9898, 78.233))) * 43758.5453);
    Out = lerp(Min, Max, randomno);
}

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        // GraphVertex: <None>
        
        // Custom interpolators, pre surface
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreSurface' */


        // Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};     

float3 TransformClipToView(float2 uv, float depth)
{
    float3 ret;
    {
                // Converting Position from Screen to View via world space
        float3 world;
        world = ComputeWorldSpacePosition(uv, depth, UNITY_MATRIX_I_VP);
        ret = TransformWorldToView(world);
    }
    return ret;
}

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription) 0;
    
    //generate scene color and depth
    float SceneDepth;
    Unity_SceneDepth_LinearEye_float(float4(IN.NDCPosition.xy, 0, 0), SceneDepth);
    
    float SceneDepthRaw;
    Unity_SceneDepth_Raw_float(float4(IN.NDCPosition.xy, 0, 0), SceneDepthRaw);
   
    float4 SceneColorxyzw = Unity_Universal_SampleBuffer_BlitSource_float(float4(IN.NDCPosition.xy, 0, 0).xy);
    float3 SceneColor = SceneColorxyzw.xyz;
    float2 NDCPos = IN.NDCPosition.xy;//NDC xy
    //we also need normal
    float3 NDCNormal = IN.ViewSpaceNormal;
    
    float radius = _Radius ; 
    float radiusPixel = floor(radius * _ScreenParams.x);
    float2 InvRes = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);
    
    //debug square
    float resRatio = _ScreenParams.x / _ScreenParams.y;
    float2 sqrCenter = float2(0.5, 0.5);
    bool isCenterDebug = ((NDCPos.x) <= sqrCenter.x + radius &&
    (NDCPos.x) >= sqrCenter.x - radius);
    
    isCenterDebug = isCenterDebug &&
    ((NDCPos.y) <= sqrCenter.y + radius * resRatio &&
    (NDCPos.y) >= sqrCenter.y - radius * resRatio);
    
    
    //sample count for theta and stepcount
    int sampleCount = _SampleSize;
    int stepCount = max(0, min(_StepUpperBound, radiusPixel));
    
    //stepSize
    float stepSizePixel = radiusPixel / (stepCount + 1);
    float2 stepSize = stepSizePixel * InvRes;//should be good but we will see
    
    float occlusion = 0;
    
    float t_theta = acos((normalize(NDCNormal)).z); //tagent angle, good
    float3 P = IN.ViewSpacePosition;
    //float3(NDCPos, SceneDepth);//P as the point we are evaluating
    for (int i = 0; i < sampleCount; i++)
    {
        //for each sample, evaluate its location in NDC
        float2 thetaSample = normalize(_Samples[i].xy); //direction, length 1
        
       // if (length(thetaSample) > 0.99)
        //    t_theta = 0;//thetaSample's length is good
        
        float2 directedStepSize = thetaSample * stepSize; //let's say its good
        
        float h_theta = t_theta;//good
        
        //stepping forward
        float D = 0;
        for (int s = 1; s <= stepCount; s++)
        {
            float2 stepSample = NDCPos + s * directedStepSize;//a 2D stepping
            stepSample = saturate(stepSample);
            
            //obtain depth
            float stepDepth;
            Unity_SceneDepth_Raw_float(float4(stepSample.xy, 0, 0), stepDepth);
            //construct 3D stepping point
            float3 Si = float3(stepSample, stepDepth);
            float3 Si_view = TransformClipToView(stepSample, stepDepth);
            
            float3 D = Si_view - P;//dir from sample(3D) to point
            float DLength = length(D);
            float alphaSi = atan(D.z / length(D.xy));//as in the paper, but no
            //negative z as we now has depth 1-0
            
            if (DLength < radius && alphaSi > h_theta)
            {
                D = DLength;
                h_theta = alphaSi;
                
                float omega_theta = max(0, (1 - (D * D) / (radius * radius)));
                occlusion += omega_theta * (sin(h_theta) - sin(t_theta));
            }

        }
        //transform from tangent to NDC
    }
    occlusion = occlusion / ((float) sampleCount) * _Intensity;
    
    surface.BaseColor = SceneColor;
    surface.Alpha = 1;
    
    if (isCenterDebug)
    {
       // surface.BaseColor = float3(1,0,0);
       // return surface;
    }
    
    if (_ShowSSAO == 1)
        surface.BaseColor = (1 - occlusion) ;
    else if (_ShowSSAO == 2)
        surface.BaseColor *= (1 - occlusion);
    else if (_ShowSSAO == 3)
        surface.BaseColor = TransformClipToView(NDCPos, SceneDepth);//tranformation is good
    //IN.ViewSpacePosition
        //need to tweak this later
   
    return surface;
}
        
        // --------------------------------------------------
        // Build Graph Inputs
        
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
    float3 normalWS = SHADERGRAPH_SAMPLE_SCENE_NORMAL(input.texCoord0.xy);
    float4 tangentWS = float4(0, 1, 0, 0); // We can't access the tangent in screen space
    
    output.WorldSpaceNormal = normalWS.xyz;
    output.ViewSpaceNormal = mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_I_V);
        
        
        
    float3 viewDirWS = normalize(input.texCoord1.xyz);
    float linearDepth = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(input.texCoord0.xy), _ZBufferParams);
    float3 cameraForward = -UNITY_MATRIX_V[2].xyz;
    float camearDistance = linearDepth / dot(viewDirWS, cameraForward);
    float3 positionWS = viewDirWS * camearDistance + GetCameraPositionWS();
        
        
    output.NDCPosition = input.texCoord0.xy;
    
    output.ViewSpacePosition = TransformWorldToView(positionWS);
    output.WorldSpacePosition = positionWS;
        
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
    return output;
}
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenCommon.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenDrawProcedural.hlsl"
        
        ENDHLSL
        }
        Pass
        {
Name"Blit"
        
        // Render State
        Cull
Off
        Blend
Off
        ZTest
Off
        ZWrite
Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma vertex vert
        #pragma fragment frag
        // #pragma enable_d3d11_debug_symbols
        
        /* WARNING: $splice Could not find named fragment 'DotsInstancingOptions' */
        /* WARNING: $splice Could not find named fragment 'HybridV1InjectedBuiltinProperties' */
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
#define FULLSCREEN_SHADERGRAPH
        
        // Defines
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_VERTEXID
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
        
        // Force depth texture because we need it for almost every nodes
        // TODO: dependency system that triggers this define from position or view direction usage
#define REQUIRE_DEPTH_TEXTURE
#define REQUIRE_NORMAL_TEXTURE
        
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_BLIT
#define REQUIRE_DEPTH_TEXTURE
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenShaderPass.cs.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
struct Attributes
{
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
#endif
    uint vertexID : VERTEXID_SEMANTIC;
    float3 positionOS : POSITION;
};
struct SurfaceDescriptionInputs
{
    float2 NDCPosition;
    float2 PixelPosition;
};
struct Varyings
{
    float4 positionCS : SV_POSITION;
    float4 texCoord0;
    float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
};
struct VertexDescriptionInputs
{
};
struct PackedVaryings
{
    float4 positionCS : SV_POSITION;
    float4 texCoord0 : INTERP0;
    float4 texCoord1 : INTERP1;
#if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
};
        
PackedVaryings PackVaryings(Varyings input)
{
    PackedVaryings output;
    ZERO_INITIALIZE(PackedVaryings, output);
    output.positionCS = input.positionCS;
    output.texCoord0.xyzw = input.texCoord0;
    output.texCoord1.xyzw = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
    return output;
}
        
Varyings UnpackVaryings(PackedVaryings input)
{
    Varyings output;
    output.positionCS = input.positionCS;
    output.texCoord0 = input.texCoord0.xyzw;
    output.texCoord1 = input.texCoord1.xyzw;
#if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
    return output;
}
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        CBUFFER_END
        
        
        // Object and Global properties
float _FlipY;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
void Unity_SceneDepth_Raw_float(float4 UV, out float Out)
{
    Out = SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy);
}
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        // GraphVertex: <None>
        
        // Custom interpolators, pre surface
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreSurface' */
        
        // Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};
        
SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription) 0;
    float _SceneDepth_45b93924e263408b80908e216012afce_Out_1_Float;
    Unity_SceneDepth_Raw_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_45b93924e263408b80908e216012afce_Out_1_Float);
    surface.BaseColor = (_SceneDepth_45b93924e263408b80908e216012afce_Out_1_Float.xxx);
    surface.Alpha = 1;
    return surface;
}
        
        // --------------------------------------------------
        // Build Graph Inputs
        
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
    float3 normalWS = SHADERGRAPH_SAMPLE_SCENE_NORMAL(input.texCoord0.xy);
    float4 tangentWS = float4(0, 1, 0, 0); // We can't access the tangent in screen space
        
        
        
        
    float3 viewDirWS = normalize(input.texCoord1.xyz);
    float linearDepth = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(input.texCoord0.xy), _ZBufferParams);
    float3 cameraForward = -UNITY_MATRIX_V[2].xyz;
    float camearDistance = linearDepth / dot(viewDirWS, cameraForward);
    float3 positionWS = viewDirWS * camearDistance + GetCameraPositionWS();
        
        
    output.NDCPosition = input.texCoord0.xy;
        
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
    return output;
}
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenCommon.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/Fullscreen/Includes/FullscreenBlit.hlsl"
        
        ENDHLSL
        }
    }
CustomEditor"UnityEditor.Rendering.Fullscreen.ShaderGraph.FullscreenShaderGUI"
    FallBack"Hidden/Shader Graph/FallbackError"
}