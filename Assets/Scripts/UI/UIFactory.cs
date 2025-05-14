using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using UnityEngine;

public static class UIFactory
{
    private static Dictionary<Type, IUIEventHandler> _panelDict = new();
    private static Dictionary<Type, string> _panelPaths = new();
    public static void Registry()
    {
        RegistryPanel<PathFindingPanel>(new PathFindingPanelHandler(), "Prefabs/UI/PathFindingPanel");
    }
    public static void RegistryPanel<T>(IUIEventHandler handler, string path) where T : UIPanelBase
    {
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
        IUIEventHandler handler = CreateHandlerFor<T>();
        handler.AttachToPanel(panel);
        panel.Init();
        return panel;
    }

    private static IUIEventHandler CreateHandlerFor<T>() where T : UIPanelBase, new()
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

