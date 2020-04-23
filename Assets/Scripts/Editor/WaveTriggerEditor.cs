using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(WaveTrigger))]
public class WaveTriggerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        var waveTrigger = target as WaveTrigger;
        if(GUILayout.Button("Trigger"))
        {
            waveTrigger.ResetStartTime();
        }
    }
}