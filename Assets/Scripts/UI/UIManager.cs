using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum UISystem
{
    None,
    Menu,
    Main,
    Settings
}
[Serializable]
public struct UIEntry
{
    public UISystem UISystem;
    public UIPanelBase UIPanelBase;
}
public class UIManager : MonoBehaviour
{
    public static UIManager Instance { get; private set; }
    [SerializeField] private UIEntry[] m_UIEntries;
    private Dictionary<UISystem, UIPanelBase> m_UIPanels = new Dictionary<UISystem, UIPanelBase>();
    private UIPanelBase m_CurGameUI;
    private void Awake()
    {
        Instance = this;
        foreach (var ui in m_UIEntries)
        {
            m_UIPanels.Add(ui.UISystem, ui.UIPanelBase);
        }
    }
    public void ShowUI(UISystem uISystem)
    {
        if (m_UIPanels.TryGetValue(uISystem, out UIPanelBase ui))
        {
            ui.Show();
        }
        else
        {
            throw new Exception("Invalid UI System");
        }
    }
    public void HideUI(UISystem uISystem)
    {
        if (m_UIPanels.TryGetValue(uISystem, out UIPanelBase ui))
        {
            ui.Hide();
        }
        else
        {
            throw new Exception("Invalid UI System");
        }
    }
}
