using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IUIEventHandler
{
    void AttachToPanel(UIPanelBase panelBase);
    void RegisterEvent();
}
