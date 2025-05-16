using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathFindingViewHandler : UIHandlerBase, IUIHandler
{
    private PathFindingView m_panel;
    public override void AttachToPanel(UIPanelBase panel)
    {
        m_panel = panel as PathFindingView;
        RegisterEvent();
    }
    public override void RegisterEvent()
    {
        m_panel.resetBtn.onClick.AddListener(OnResetGrid);
    }
    private void OnResetGrid()
    {
        UIEventBus.Publish(new ResetMapEvent());
    }
}
