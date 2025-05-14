using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public abstract class UIPanelBase : MonoBehaviour
{
    protected IUIEventHandler _handler;
    public virtual void Init()
    {
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
    public virtual void RegisterInternalEvents(){}
    public virtual void UnregisterEvents() {}
}
