using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathFindingPanelHandler : IUIEventHandler
{
    public void OnReset()
    {
        UIEventBus.Publish(new ResetMapEvent());
    }
    public void OnFindPath()
    {
        UIEventBus.Publish(new FindPathEvent());
    }
}
