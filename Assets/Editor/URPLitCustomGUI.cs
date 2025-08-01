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
        Transparent,
        TransparentCutout
    }
    public enum FaceRenderingMode
    {
        Front,
        Back,
        Both,
        DoubleSided
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
        var FaceRenderingProp = BaseShaderGUI.FindProperty("_FaceRenderingMode", properties, true);

        EditorGUI.BeginChangeCheck();
        surfaceProp.floatValue = (int)(SurfaceType)EditorGUILayout.EnumPopup("Surface Type", (SurfaceType)surfaceProp.floatValue);
        FaceRenderingProp.floatValue = (int)(FaceRenderingMode)EditorGUILayout.EnumPopup("Face Rendering Mode", (FaceRenderingMode)FaceRenderingProp.floatValue);
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
                material.DisableKeyword("_ALPHA_CUTOUT");
                break;
            case SurfaceType.Transparent:
                material.renderQueue = (int)RenderQueue.Transparent;
                material.SetOverrideTag("RenderType", "Transparent");
                material.DisableKeyword("_ALPHA_CUTOUT");
                break;
            case SurfaceType.TransparentCutout:
                material.renderQueue = (int)RenderQueue.AlphaTest;
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.EnableKeyword("_ALPHA_CUTOUT");
                break;
        }

        switch (surfaceType)
        {
            case SurfaceType.Opaque:
            case SurfaceType.TransparentCutout:
                material.SetInt("_SourceBlend", (int)BlendMode.One);
                material.SetInt("_DestBlend", (int)BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                break;
            case SurfaceType.Transparent:
                material.SetInt("_SourceBlend", (int)BlendMode.SrcAlpha);
                material.SetInt("_DestBlend", (int)BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                break;
        }
        material.SetShaderPassEnabled("ShadowCaster", surfaceType != SurfaceType.Transparent);

        FaceRenderingMode faceRenderingMode = (FaceRenderingMode)material.GetFloat("_FaceRenderingMode");
        switch (faceRenderingMode)
        {
            case FaceRenderingMode.Front:
                material.SetInt("_Cull", (int)CullMode.Back);
                material.DisableKeyword("_DOUBLE_SIDED_NORMALS");
                break;
            case FaceRenderingMode.Back:
                material.SetInt("_Cull", (int)CullMode.Front);
                material.DisableKeyword("_DOUBLE_SIDED_NORMALS");
                break;
            case FaceRenderingMode.Both:
                material.SetInt("_Cull", (int)CullMode.Off);
                material.DisableKeyword("_DOUBLE_SIDED_NORMALS");
                break;
            case FaceRenderingMode.DoubleSided:
                material.SetInt("_Cull", (int)CullMode.Off);
                material.EnableKeyword("_DOUBLE_SIDED_NORMALS");
                break;
        }
        
    }
}
