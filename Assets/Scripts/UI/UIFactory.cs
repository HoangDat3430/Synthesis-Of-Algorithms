using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using UnityEngine;

public static class UIFactory
{
    private static Dictionary<Type, string> _panelPaths = new();
    public static void Registry()
    {
        RegistryPanel<PathFindingView>("PathFindingView");
        RegistryPanel<MainUI>("MainUI");
    }
    public static void RegistryPanel<T>(string prefabName)
    {
        string path = Path.Combine("Prefabs", "UI", prefabName);
        _panelPaths.Add(typeof(T), path);
    }
    
    public static TPanel Create<TPanel, THandler>(Transform parent)
        where TPanel : UIPanelBase<TPanel, THandler>, IUIPanelBase
        where THandler : IUIHandlerBase<TPanel>, new()
    {
        Type type = typeof(TPanel);
        if (!_panelPaths.TryGetValue(type, out var prefabPath))
        {
            Debug.LogError($"UI panel not registered: {type.Name}");
            return null;
        }

        GameObject prefab = Resources.Load<GameObject>(prefabPath);
        if (prefab == null)
        {
            Debug.LogError($"Prefab not found at path: {prefabPath}");
            return null;
        }

        GameObject instance = GameObject.Instantiate(prefab, parent);
        TPanel panel = instance.GetComponent<TPanel>();
        panel.Init();
        return panel;
    }
}

