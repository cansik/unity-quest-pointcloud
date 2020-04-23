using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveTrigger : MonoBehaviour
{
    private MeshRenderer _renderer;
 
    private static readonly int WaveStartTimeName = Shader.PropertyToID("_WaveStartTime");

    // Start is called before the first frame update
    void Start()
    {
        _renderer = GetComponent<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
       
    }

    public void ResetStartTime()
    {
        // update uniforms
        _renderer.material.SetFloat(WaveStartTimeName, Time.timeSinceLevelLoad);
    }
}
