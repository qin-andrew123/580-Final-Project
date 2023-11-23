using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcessing : MonoBehaviour
{
    // A Material with the Unity shader you want to process the image with
    public Material mat;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // Read pixels from the source RenderTexture, apply the material, copy the updated results to the destination RenderTexture
        //Graphics.Blit(src, dest, mat);
        Debug.Log("Hey");
    }
}
