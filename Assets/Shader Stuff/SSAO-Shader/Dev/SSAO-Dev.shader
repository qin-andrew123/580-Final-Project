Shader"Unlit/SSAO-Dev"
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
    float3 WorldSpacePosition;
    float3 ViewSpacePosition;
    
    float3 ViewSpaceNormal;
    float3 WorldSpaceNormal;
    float3 CameraSpaceNormal;
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
float3 _Samples[512];

float _Radius;
float _Intensity;
int _ShowSSAO;

int _IsSimple;
        // Graph Functions
        
void Unity_SceneDepth_Raw_float(float4 UV, out float Out)
{
    Out = SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy);   
}
        
void Unity_SceneDepth_Linear_float(float4 UV, out float Out)
{
    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
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

float3 TransformTagentToView(float3 tagent, float3 WorldSpaceNormal)
{
    float3 _TransformedView;
    float3 world;
        
    float3 WorldSpaceTangent, WorldSpaceBiTangent;
    
    float4 tangentWS = float4(0, 1, 0, 0); // We can't access the tangent in screen space
    // use bitangent on the fly like in hdrp
    // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
    float crossSign = (tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
    float3 bitang = crossSign * cross(WorldSpaceNormal.xyz, tangentWS.xyz);
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
    WorldSpaceTangent = tangentWS.xyz;
    WorldSpaceBiTangent = bitang;
    
    float3x3 tangentTransform = float3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal);
    world = TransformTangentToWorld(tagent, tangentTransform, false);
   
    _TransformedView = TransformWorldToViewNormal(world, true);
    
    return _TransformedView;
}

float3 TransformTagentToViewPos(float3 tagent, float3 WorldSpaceNormal, float3 WorldSpacePosition)
{
    float3 _TransformedView;
    float3 world;
        
    float3 WorldSpaceTangent, WorldSpaceBiTangent;
    
    float4 tangentWS = float4(0, 1, 0, 0); // We can't access the tangent in screen space
    // use bitangent on the fly like in hdrp
    // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
    float crossSign = (tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
    float3 bitang = crossSign * cross(WorldSpaceNormal.xyz, tangentWS.xyz);
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
    WorldSpaceTangent = tangentWS.xyz;
    WorldSpaceBiTangent = bitang;
    
    float3x3 tangentTransform = float3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal);
    world = TransformTangentToWorldDir(tagent.xyz, tangentTransform, false).xyz + WorldSpacePosition;
                
    _TransformedView = TransformWorldToView(world);
    
    return _TransformedView;
}

float3 TransformViewToClip(float3 viewVector)
{
   // float3 _Transform_Vector3;
   /* {
        // Converting Direction from View to Screen via world space
        float3 world;
        world = TransformViewToWorldDir(viewVector.xyz, false);
        float4 _Transform_Vector3_value = TransformWViewToHClip(viewVector.xyz);
        float3 _Transform_Vector3_uv = _Transform_Vector3_value.xyz / _Transform_Vector3_value.w;
#if UNITY_UV_STARTS_AT_TOP
                _Transform_Vector3_uv.y = -_Transform_Vector3_uv.y;
#endif
        _Transform_Vector3_uv.xy = _Transform_Vector3_uv.xy * 0.5 + 0.5;
        _Transform_Vector3 = _Transform_Vector3_uv;
    }*/
    float4 ret = TransformWViewToHClip(viewVector);
    ret.xy = ret.xy * 0.5 + 0.5;//clip space x,y [-1, 1],----> uv [0,1]
    
    return ret.xyz/ret.w;
}

float3 TransformClipToView(float2 ClipPos, float depth)
{
    float3 world;
    world = ComputeWorldSpacePosition(ClipPos.xy, depth, UNITY_MATRIX_I_VP);
    float3 ret = TransformWorldToView(world);
    
    return ret;

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

SurfaceDescription SimpleSSAO(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription) 0;
    
        //generate scene color and depth
    float SceneDepth;
    Unity_SceneDepth_Raw_float(float4(IN.NDCPosition.xy, 0, 0),SceneDepth);
    
    float3 SceneColor = Unity_Universal_SampleBuffer_BlitSource_float(float4(IN.NDCPosition.xy, 0, 0).xy);
    
    float2 NDCPos = IN.NDCPosition.xy; //NDC xy
    int sampleCount = _SampleSize;
    float radius = _Radius; //0.04;//need to tweak this later
    radius = radius * SceneDepth ;
    
    float resRatio = _ScreenParams.x / _ScreenParams.y;
    bool isCenterDebug = ((NDCPos.x) <= 0.5 + radius && (NDCPos.x) >= 0.5 - radius);
    isCenterDebug = isCenterDebug && ((NDCPos.y) <= 0.5 + radius * resRatio && (NDCPos.y) >= 0.5 - radius * resRatio);
    
    float occlusion = 0;
    float sampleSignCheck = 1;
    for ( int i = 0; i < sampleCount; i++)
    {
        //for each sample, evaluate its location in NDC
        float3 tagentSample = _Samples[i]; //simple sample
        
        float3 NDCSample = tagentSample * radius;
        //rescale by screen ratio
        NDCSample.y = NDCSample.y * resRatio;
        
        float2 offsetUV = NDCSample.xy + NDCPos;
        
        float offsetDepth = NDCSample.z + SceneDepth;
        offsetDepth = saturate(offsetDepth);
        
        float actualDepth;
        Unity_SceneDepth_Raw_float(float4(offsetUV, 0, 0), actualDepth);
        
        float bias = 0.002;
        if (actualDepth >= offsetDepth + bias)//nearest is 1, farest is 0
        {
            float depthDiff = abs(actualDepth - offsetDepth);
            float rangeCheck = smoothstep(0.0, 1.0, radius / depthDiff);
            occlusion = occlusion + rangeCheck * _Intensity;
        }
        
    }
    occlusion = occlusion / ((float) sampleCount);
    
    surface.BaseColor = SceneColor;
    surface.Alpha = 1;
    
    if (isCenterDebug)
    {
        surface.BaseColor = 1;
        return  surface;
    }
    
    if (_ShowSSAO == 1)
        surface.BaseColor = (1 - occlusion); //need to tweak this later
    else if (_ShowSSAO == 2)
        surface.BaseColor *= (1 - occlusion);
    else if (_ShowSSAO == 3)
        surface.BaseColor = SceneDepth;
    return surface;
}

float3 normalFromDepth(float depth, float2 NDCPos)//screen space normal
{
    const float2 offset1 = float2(0.0, 0.001);
    const float2 offset2 = float2(0.001, 0.0);
  
    float depth1, depth2;
    Unity_SceneDepth_Raw_float(float4(NDCPos.xy + offset1, 0, 0), depth1);
    Unity_SceneDepth_Raw_float(float4(NDCPos.xy + offset2, 0, 0), depth2);
  
    float3 p1 = float3(offset1, depth1 - depth);
    float3 p2 = float3(offset2, depth2 - depth);
  
    float3 normal = cross(p1, p2);
    normal.z = -normal.z;
  
    return normalize(normal);
}

SurfaceDescription DevSSAO(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription) 0;
    
    float SceneDepth;
    Unity_SceneDepth_LinearEye_float(float4(IN.NDCPosition.xy, 0, 0), SceneDepth);
    float SceneDepthRaw;
    Unity_SceneDepth_Raw_float(float4(IN.NDCPosition.xy, 0, 0), SceneDepthRaw);
    
    float3 SceneColor = Unity_Universal_SampleBuffer_BlitSource_float(float4(IN.NDCPosition.xy, 0, 0).xy);
    
    float2 NDCPos = IN.NDCPosition.xy; //NDC xy ,[0,1]
    int sampleCount = _SampleSize;
    float radius = _Radius; //0.04;//need to tweak this later
    radius = radius; //* SceneDepthRaw;
    
    float resRatio = _ScreenParams.x / _ScreenParams.y;
    float2 sqrCenter = float2(0.5, 0.5);
    bool isCenterDebug = ((NDCPos.x) <= sqrCenter.x + radius && 
    (NDCPos.x) >= sqrCenter.x - radius);
    
    isCenterDebug = isCenterDebug && 
    ((NDCPos.y) <= sqrCenter.y + radius * resRatio &&
    (NDCPos.y) >= sqrCenter.y - radius * resRatio);
    
    float3 ViewNormal = normalize(IN.ViewSpaceNormal);
    float3 NDCNormal = normalFromDepth(SceneDepth, NDCPos);
  
    float occlusion = 0;
    float sampleSignCheck = 1;
    float debugZcount = 0;
    
    for (int i = 0; i < sampleCount; i++)
    {
        //for each sample, evaluate its location in NDC
        float3 tagentSample = _Samples[i]; //simple sample, with positive z
        tagentSample = sign(dot(tagentSample, ViewNormal)) * tagentSample;
       
        if (dot(tagentSample, ViewNormal) < 0)
            tagentSample = -tagentSample;
        
        float3 NDCSample = tagentSample * radius;
        //rescale by screen ratio
        //NDCSample.y = NDCSample.y * resRatio;
        
        float2 offsetUV = NDCSample.xy + NDCPos;
        
        float offsetDepth =  - NDCSample.z + SceneDepth;
        //offsetDepth = saturate(offsetDepth);
        
        float actualDepth;
        Unity_SceneDepth_LinearEye_float(float4(offsetUV, 0, 0), actualDepth);
        
        float bias = 0.04;
        if (actualDepth < offsetDepth - bias)//nearest is 1, farest is 0
        {
            float depthDiff = abs(SceneDepth - actualDepth);
            float rangeCheck = smoothstep(0.0, 1.0, radius / depthDiff);
            occlusion = occlusion + rangeCheck * _Intensity;
        }
    }
    occlusion = occlusion / ((float) sampleCount);
    debugZcount = debugZcount / ((float) sampleCount);
    
    surface.BaseColor = SceneColor;
    surface.Alpha = 1;
    
    float3 debugColor = float3(1, 1, 1);
    if (isCenterDebug)
    {
        surface.BaseColor = float3(1, 1,1 );
        return surface;
    }
    
    if (_ShowSSAO == 1)
        surface.BaseColor = (1 - occlusion) * debugColor; //need to tweak this later
    else if (_ShowSSAO == 2)
        surface.BaseColor *= (1 - occlusion);
    else if (_ShowSSAO == 3)
        surface.BaseColor = sampleSignCheck;
        //TransformTagentToView(float3(0, 2, 1), IN.WorldSpaceNormal);
    //NDCNormal;
        //mul(mat, float3(0,0,1));
    //TransformTagentToView(float(0,0,1), IN.WorldSpaceNormal);
   
    return surface;
}
SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    if (_IsSimple)
        return SimpleSSAO(IN);
    else
        return DevSSAO(IN);

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
        
    output.WorldSpacePosition = positionWS;
    output.ViewSpacePosition = TransformWorldToView(positionWS);
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