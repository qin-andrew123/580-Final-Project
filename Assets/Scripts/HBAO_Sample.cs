using System.Collections;
using System.Collections.Generic;
using UnityEditor.PackageManager.UI;
using UnityEngine;
using UnityEngine.Profiling;

[ExecuteInEditMode]
public class HBAO_Sample : MonoBehaviour
{
    // A Material with the Unity shader you want to process the image with
    [Header("SSAO Material")]
    public Material mat;
    //public Vector3 Color;
    //public 
    [Header("Material Parameters")]
    public bool showSSAO;
    public float radius;
    public float intensity;

    [Header("Sampling Settings")]
    public bool regenerate;

    public static int sampleSize = 64;
    private List<Vector4> samples = new List<Vector4>(sampleSize );
    
    private void Update()
    {
        CreateSamplesHemi();

        mat.SetInt("_ShowSSAO", showSSAO ? 1 : 0);
        mat.SetFloat("_Radius", radius);
        mat.SetFloat("_Intensity", intensity);

        mat.SetInt("_SampleSize", sampleSize);
        mat.SetVectorArray("_Samples", samples);
    }

    private void CreateSamples() {
        if (samples.Count == sampleSize && !regenerate)
        {
            Debug.Log("sample count is" + samples.Count);
            return;
        }
        samples.Clear();//for now just generate new sample everyframe!
        
        for (int i = 0; i < sampleSize; i++)
        {
            Vector4 newPos = Random.insideUnitSphere;//a location is generated!
            samples.Add(newPos);
           
        }
    }

    private void CreateSamplesHemi()
    {
        if (samples.Count == sampleSize && !regenerate)
        {
            Debug.Log("sample count is" + samples.Count);
            return;
        }
        samples.Clear();//for now just generate new sample everyframe!

        int counter = 0;
        while (counter < sampleSize)
        {
            Vector4 newPos = Random.insideUnitSphere;//a location is generated!
            if (newPos.z > 0)
            {
                float scale = (float)counter / (float)sampleSize;
                scale = Mathf.Lerp(0.1f, 1.0f, scale * scale);
                //a larger weight on occlusions close to the actual fragment.
                newPos *= scale;
                samples.Add(newPos);
                counter++;
            }
        }
    }
}
