using System.Collections;
using System.Collections.Generic;
using UnityEditor.VersionControl;
using UnityEngine;
using UnityEngine.Rendering;

public class CameraRenderer
{
    const string bufferName = "Render Camera";
    static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");
    ScriptableRenderContext context;
    Camera camera;
    CommandBuffer buffer = new CommandBuffer { name = bufferName };
    CullingResults cullingResults;

    //legacy
    static ShaderTagId[] legacyShaderTagIds = {
        new ShaderTagId("Always"),
        new ShaderTagId("ForwardBase"),
        new ShaderTagId("PrepassBase"),
        new ShaderTagId("Vertex"),
        new ShaderTagId("VertexLMRGBM"),
        new ShaderTagId("VertexLM")
    };

    public void Render(ScriptableRenderContext context, Camera camera)
    {
        this.context = context;
        this.camera = camera;
        if (!Cull())
        {
            return;
        }
        Setup();
        DrawVisibleGeometry();
        DrawUnsupportedShaders();
        Submit();
    }

    void Setup()
    {
        context.SetupCameraProperties(this.camera);
        buffer.ClearRenderTarget(true, true, Color.clear);
        buffer.BeginSample(bufferName);
        ExecuteBuffer();
    }

    void DrawVisibleGeometry()
    {
        var sortingSettings = new SortingSettings(camera) { criteria = SortingCriteria.CommonOpaque };
        var drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings);
        var filteringSettings = new FilteringSettings(RenderQueueRange.all);

        context.DrawSkybox(this.camera);
        sortingSettings.criteria = SortingCriteria.CommonTransparent;
        drawingSettings.sortingSettings = sortingSettings;
        filteringSettings.renderQueueRange = RenderQueueRange.transparent;

        context.DrawRenderers(
            cullingResults, ref drawingSettings, ref filteringSettings
        );
    }
    void DrawUnsupportedShaders()
    {
        var drawingSettings = new DrawingSettings(
            legacyShaderTagIds[0], new SortingSettings(camera)
        );

        for (int i = 1; i < legacyShaderTagIds.Length; i++)
        {
            drawingSettings.SetShaderPassName(i, legacyShaderTagIds[i]);
        }//multi-pass

        var filteringSettings = FilteringSettings.defaultValue;
        context.DrawRenderers(
            cullingResults, ref drawingSettings, ref filteringSettings
        );
    }

    void Submit()
    {
        buffer.EndSample(bufferName);
        ExecuteBuffer();
        context.Submit();
    }

    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    bool Cull()
    {
        if (camera.TryGetCullingParameters(out ScriptableCullingParameters p))
        {
            cullingResults = context.Cull(ref p);
            return true;
        }
        return false;
    }
}
