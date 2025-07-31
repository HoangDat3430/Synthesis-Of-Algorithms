using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

public class URPLitCustomGUI : ShaderGUI
{
    public enum SurfaceType
    {
        Opaque,
        Transparent
    }
    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        base.AssignNewShaderToMaterial(material, oldShader, newShader);
        if (newShader.name == "Custom/URPLit")
        {
            UpdateSurfaceType(material);
        }
    }
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material material = materialEditor.target as Material;
        var surfaceProp = BaseShaderGUI.FindProperty("_SurfaceType", properties, true);

        EditorGUI.BeginChangeCheck();
        surfaceProp.floatValue = (int)(SurfaceType)EditorGUILayout.EnumPopup("Surface Type", (SurfaceType)surfaceProp.floatValue);
        if (EditorGUI.EndChangeCheck())
        {
            UpdateSurfaceType(material);
        }
        base.OnGUI(materialEditor, properties);
    }
    private void UpdateSurfaceType(Material material)
    {
        SurfaceType surfaceType = (SurfaceType)material.GetFloat("_SurfaceType");
        switch (surfaceType)
        {
            case SurfaceType.Opaque:
                material.renderQueue = (int)RenderQueue.Geometry;
                material.SetOverrideTag("RenderType", "Opaque");
                material.SetInt("_SourceBlend", (int)BlendMode.One);
                material.SetInt("_DestBlend", (int)BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.SetShaderPassEnabled("ShadowCaster", true);
                break;
            case SurfaceType.Transparent:
                material.renderQueue = (int)RenderQueue.Transparent;
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SourceBlend", (int)BlendMode.SrcAlpha);
                material.SetInt("_DestBlend", (int)BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.SetShaderPassEnabled("ShadowCaster", false);
                break;
        }
    }
}
