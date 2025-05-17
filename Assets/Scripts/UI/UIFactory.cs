using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using UnityEngine;

public static class UIFactory
{
    private static Dictionary<Type, IUIHandler> _panelDict = new();
    private static Dictionary<Type, string> _panelPaths = new();
    public static void Registry()
    {
        RegistryPanel<PathFindingView>(new PathFindingViewHandler(), "PathFindingView");
        RegistryPanel<MainUI>(new MainUIHandler(), "MainUI");
    }
    public static void RegistryPanel<T>(IUIHandler handler, string prefabName) where T : UIPanelBase
    {
        string path = Path.Combine("Prefabs", "UI", prefabName);
        _panelDict.Add(typeof(T), handler);
        _panelPaths.Add(typeof(T), path);
    }
    public static T CreatePanel<T>(Transform parent) where T : UIPanelBase, new()
    {
        Type type = typeof(T);

        string prefabPath = _panelPaths[type];

        // Tải prefab từ Resources hoặc Addressables
        GameObject prefab = Resources.Load<GameObject>(prefabPath);
        if (prefab == null)
        {
            Debug.LogError($"Prefab không tồn tại tại path: {prefabPath}");
            return null;
        }

        GameObject instance = GameObject.Instantiate(prefab, parent);
        T panel = instance.GetComponent<T>();
        IUIHandler handler = CreateHandlerFor<T>();
        handler.AttachToPanel(panel);
        panel.Init();
        return panel;
    }

    private static IUIHandler CreateHandlerFor<T>() where T : UIPanelBase, new()
    {
        Type panelType = typeof(T);
        if (_panelDict.TryGetValue(panelType, out var handler))
        {
            return handler;
        }
        else
        {
            Debug.LogError("UI Panel was not registered");
            return null;
        }
    }
}

