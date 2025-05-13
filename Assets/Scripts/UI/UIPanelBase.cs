using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public class UIPanelBase : MonoBehaviour
{
    public virtual void Show()
    {
        gameObject.SetActive(true);
    }
    public virtual void Hide()
    {
        gameObject.SetActive(false);
    }
    public virtual void Refresh()
    {
    }
    public virtual void RegisterExternalEvents()
    {
    }
    public virtual void RegisterInternalEvents()
    {
    }
    public virtual void UnregisterEvents() {}
    protected virtual void OnEnable()
    {
        RegisterInternalEvents();
        RegisterExternalEvents();
    }
    protected virtual void OnDisable()
    {
        UnregisterEvents();
    }
}
