using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LeafShader : MonoBehaviour
{
    private MeshRenderer _renderer;
    private float _time = 0;
    private static readonly int Time = Shader.PropertyToID("_Time");

    // Start is called before the first frame update
    void Start()
    {
        _renderer = GetComponent<MeshRenderer>();
        Debug.Log(_renderer.material.shader.name);
    }

    // Update is called once per frame
    void Update()
    {
        // update uniforms

        _time += 0.1f;
        //_renderer.material.SetFloat(Time, _time);
    }
}
