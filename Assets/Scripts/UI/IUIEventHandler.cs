using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IUIHandler
{
    void AttachToPanel(UIPanelBase panelBase);
    void RegisterEvent();
}
