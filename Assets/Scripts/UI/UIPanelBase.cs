using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public abstract class UIPanelBase<TPanel, THandler> : MonoBehaviour, IUIPanelBase 
where TPanel : UIPanelBase<TPanel, THandler>, IUIPanelBase
where THandler : IUIHandlerBase<TPanel>, new()
{
    protected THandler _handler;
    public virtual void Init()
    {
        _handler = new();
        _handler.AttachToPanel((TPanel)this);
    }
    public virtual void Show()
    {
        gameObject.SetActive(true);
    }
    public virtual void Hide()
    {
        gameObject.SetActive(false);
    }
    public virtual void Refresh(){}
    protected virtual void RegisterInternalEvents(){}
    protected virtual void UnregisterEvents() {}
}
