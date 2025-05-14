using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OnCreatePanelFinishedEvent
{
}
public abstract class UIHandlerBase : IUIEventHandler
{
    public virtual void AttachToPanel(UIPanelBase panel) {}
    public virtual void RegisterEvent() { }
}
