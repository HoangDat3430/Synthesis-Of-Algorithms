using System;
using System.Collections.Generic;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    public static UIManager Instance { get; private set; }
    private Dictionary<Type, UIPanelBase> m_LoadedPanels = new Dictionary<Type, UIPanelBase>();
    private void Awake()
    {
        Instance = this;
        DontDestroyOnLoad(gameObject);
        UIFactory.Registry();
        SubscribeEvent();
    }
    private void Start()
    {
        ShowUI<PathFindingView>();
    }
    public T LoadUI<T>() where T : UIPanelBase, new()
    {
        Type type = typeof(T);
        if (!m_LoadedPanels.TryGetValue(type, out var panel))
        {
            panel = UIFactory.CreatePanel<T>(transform);
            m_LoadedPanels.Add(type, panel);
        }
        return (T)panel;
    }
    public void ShowUI<T>() where T : UIPanelBase, new()
    {
        if (!m_LoadedPanels.TryGetValue(typeof(T), out UIPanelBase ui))
        {
            ui = LoadUI<T>();
        }
        else
        {
            throw new Exception("Invalid UI System");
        }
        ui.Show();
    }
    public void HideUI<T>() where T : UIPanelBase
    {
        if (m_LoadedPanels.TryGetValue(typeof(T), out UIPanelBase ui))
        {
            ui.Hide();
        }
        else
        {
            throw new Exception("Invalid UI System");
        }
    }
    private void SubscribeEvent()
    {
    }
}
