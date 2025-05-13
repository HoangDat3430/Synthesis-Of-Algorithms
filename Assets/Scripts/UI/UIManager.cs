using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    public static UIManager Instance { get; private set; }
    [SerializeField] private Type[] m_UIEntries;
    private Dictionary<Type, UIPanelBase> m_UIPanels = new Dictionary<Type, UIPanelBase>();
    private UIPanelBase m_CurGameUI;
    private void Awake()
    {
        Instance = this;
    }
    public void RegisterPanel<T>(T panel, IUIEventHandler handler) where T : UIPanelBase
    {
        if (!m_UIPanels.ContainsKey(typeof(T)))
        {
            m_UIPanels[typeof(T)] = panel;
            handler.Inject(panel);
        }
        else
        {
            Debug.LogError("This panel is already registered!");
        }
    }
    public void ShowUI<T>()
    {
        if (m_UIPanels.TryGetValue(typeof(T), out UIPanelBase ui))
        {
            ui.Show();
        }
        else
        {
            throw new Exception("Invalid UI System");
        }
    }
    public void HideUI<T>()
    {
        if (m_UIPanels.TryGetValue(typeof(T), out UIPanelBase ui))
        {
            ui.Hide();
        }
        else
        {
            throw new Exception("Invalid UI System");
        }
    }
}
