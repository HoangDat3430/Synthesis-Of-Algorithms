using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathFindingPanelHandler : IUIEventHandler
{
    private PathFindingPanel _panel;
    public void Inject(UIPanelBase panel)
    {
        _panel = (PathFindingPanel)panel;
    } 
}
