using System.Collections;
using System.Collections.Generic;
using UnityEditor.PackageManager.UI;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcessing : MonoBehaviour
{
    // A Material with the Unity shader you want to process the image with
    public Material mat;
    //public Vector3 Color;
    public bool regenerate;

    public static int sampleSize = 64;
    private List<Vector4> samples = new List<Vector4>(sampleSize);
    
    private void Update()
    {
        //samples.Add(new Vector4(Color.x, Color.y, Color.z, 1));
        CreateSamples();
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
}
