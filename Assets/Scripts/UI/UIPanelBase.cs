using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public enum EventID
{
    None = 0,
    ResetMap = 1,
    FindPath = 2,
}
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
    public virtual void RegisterButtonEvent(Button btn, EventID eventID)
    {
        btn.onClick.AddListener(() =>
        {
            UIEventBus.OnButtonClicked?.Invoke(eventID);
        });
    }
    public virtual void RegisterButtonEvent(Button btn, UnityEvent ev)
    {
        btn.onClick.AddListener(() =>
        {
            ev?.Invoke();
        });
    }
}
