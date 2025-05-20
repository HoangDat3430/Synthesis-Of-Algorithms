using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IUIHandlerBase<TPanel> where TPanel : IUIPanelBase
{
    void AttachToPanel(TPanel panelBase);
    void RegisterEvent();
}
