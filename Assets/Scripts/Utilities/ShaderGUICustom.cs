using UnityEngine;
using UnityEditor;

public class LitShaderGUICustom : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // Hiển thị toàn bộ GUI mặc định
        base.OnGUI(materialEditor, properties);
    }
}
