using System;
using System.Collections.Generic;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    public static UIManager Instance { get; private set; }
    private Dictionary<Type, IUIPanelBase> m_LoadedPanels = new Dictionary<Type, IUIPanelBase>();
    private void Awake()
    {
        Instance = this;
        DontDestroyOnLoad(gameObject);
        UIFactory.Registry();
        SubscribeEvent();
    }
    private void Start()
    {
        ShowUI<PathFindingView, PathFindingViewHandler>();
    }
    public TPanel LoadUI<TPanel, THandler>()
        where TPanel : UIPanelBase<TPanel,THandler>
        where THandler : IUIHandlerBase<TPanel>, new()
    {
        Type type = typeof(TPanel);
        if (!m_LoadedPanels.TryGetValue(type, out var panel))
        {
            panel = UIFactory.Create<TPanel, THandler>(transform);
            m_LoadedPanels.Add(type, panel);
        }
        return (TPanel)panel;
    }
    public void ShowUI<TPanel, THandler>()
        where TPanel : UIPanelBase<TPanel,THandler>
        where THandler : IUIHandlerBase<TPanel>, new()
    {
        if (!m_LoadedPanels.TryGetValue(typeof(TPanel), out IUIPanelBase ui))
        {
            ui = LoadUI<TPanel, THandler>();
        }
        else
        {
            throw new Exception("Invalid UI System");
        }
        ui.Show();
    }
    public void HideUI<TPanel, THandler>()
        where TPanel : UIPanelBase<TPanel,THandler>
        where THandler : IUIHandlerBase<TPanel>, new()
    {
        if (m_LoadedPanels.TryGetValue(typeof(TPanel), out IUIPanelBase ui))
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
