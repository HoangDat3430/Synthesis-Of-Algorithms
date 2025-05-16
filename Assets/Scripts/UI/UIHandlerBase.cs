using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OnCreatePanelFinishedEvent
{
}
public abstract class UIHandlerBase : IUIHandler
{
    public virtual void AttachToPanel(UIPanelBase panel) {}
    public virtual void RegisterEvent() { }
}
