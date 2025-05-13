using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    [SerializeField] private UIPanelBase[] m_Panels;
    public static UIManager Instance { get; private set; }
    private Dictionary<Type, UIPanelBase> m_UIPanelDict = new Dictionary<Type, UIPanelBase>();
    private void Awake()
    {
        Instance = this;
        Register();
    }
    private void Register()
    {
        // Register all panels here
        Debug.LogError(2);
        RegisterPanel(new PathFindingPanel(), new PathFindingPanelHandler());
    }
    public void RegisterPanel<T>(T panel, IUIEventHandler handler) where T : UIPanelBase
    {
        if (!m_UIPanelDict.ContainsKey(typeof(T)))
        {
            m_UIPanelDict[typeof(T)] = panel;
            panel.Inject(handler);
        }
        else
        {
            Debug.LogError("This panel is already registered!");
        }
    }
    public void ShowUI<T>()
    {
        if (m_UIPanelDict.TryGetValue(typeof(T), out UIPanelBase ui))
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
        if (m_UIPanelDict.TryGetValue(typeof(T), out UIPanelBase ui))
        {
            ui.Hide();
        }
        else
        {
            throw new Exception("Invalid UI System");
        }
    }
}
