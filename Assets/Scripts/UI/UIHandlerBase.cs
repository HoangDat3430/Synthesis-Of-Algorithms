using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class UIHandlerBase<TPanel> : IUIHandlerBase<TPanel> where TPanel : IUIPanelBase
{
    public virtual void AttachToPanel(TPanel panel) {}
    public virtual void RegisterEvent() { }
}
