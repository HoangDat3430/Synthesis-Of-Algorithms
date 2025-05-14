using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathFindingPanelHandler : UIHandlerBase, IUIEventHandler
{
    private PathFindingPanel m_panel;
    public override void AttachToPanel(UIPanelBase panel)
    {
        m_panel = panel as PathFindingPanel;
        RegisterEvent();
    }
    public override void RegisterEvent()
    {
        m_panel.resetBtn.onClick.AddListener(OnResetGrid);
        m_panel.findPathBtn.onClick.AddListener(OnFindPath);
    }
    private void OnResetGrid()
    {
        UIEventBus.Publish(new ResetMapEvent());
    }
    private void OnFindPath()
    {
        UIEventBus.Publish(new FindPathEvent());
    }
}
