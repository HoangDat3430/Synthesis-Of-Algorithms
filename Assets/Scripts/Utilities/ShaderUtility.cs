using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using UnityEngine;

public static class ShaderUtility
{
    public static void SetPropertyBlock(MeshRenderer meshRenderer, string name, object value)
    {
        MaterialPropertyBlock mpb = new MaterialPropertyBlock();

        int id = Shader.PropertyToID(name);

        switch (value)
        {
            case float f:
                mpb.SetFloat(id, f);
                break;
            case int i:
                mpb.SetInt(id, i);
                break;
            case Vector4 v4:
                mpb.SetVector(id, v4);
                break;
            case Vector3 v3:
                mpb.SetVector(id, (Vector4)v3);
                break;
            case Vector2 v2:
                mpb.SetVector(id, (Vector4)v2);
                break;
            case Color c:
                mpb.SetColor(id, c);
                break;
            case Texture tex:
                mpb.SetTexture(id, tex);
                break;
            case Vector4[] v4Array:
                mpb.SetVectorArray(id, v4Array);
                break;
            case Matrix4x4 m:
                mpb.SetMatrix(id, m);
                break;
            default:
                Debug.LogError($"[ShaderGlobalUtil] Unsupported type {value.GetType()} for global property {name}");
                break;
        }
        meshRenderer.SetPropertyBlock(mpb);
    }
    public static void SetGlobal(string name, object value)
    {
        int id = Shader.PropertyToID(name);

        switch (value)
        {
            case float f:
                Shader.SetGlobalFloat(id, f);
                break;
            case int i:
                Shader.SetGlobalInt(id, i);
                break;
            case Vector4 v4:
                Shader.SetGlobalVector(id, v4);
                break;
            case Vector3 v3:
                Shader.SetGlobalVector(id, (Vector4)v3);
                break;
            case Vector2 v2:
                Shader.SetGlobalVector(id, (Vector4)v2);
                break;
            case Color c:
                Shader.SetGlobalColor(id, c);
                break;
            case Texture tex:
                Shader.SetGlobalTexture(id, tex);
                break;
            case Matrix4x4 m:
                Shader.SetGlobalMatrix(id, m);
                break;
            case Vector4[] v4Array:
                Shader.SetGlobalVectorArray(id, v4Array);
                break;
            case float[] fArray:
                Shader.SetGlobalFloatArray(id, fArray);
                break;
            default:
                Debug.LogError($"[ShaderGlobalUtil] Unsupported type {value.GetType()} for global property {name}");
                break;
        }
    }
}
