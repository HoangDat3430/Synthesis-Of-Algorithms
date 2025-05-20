using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using UnityEngine;

public class MainUIHandler : UIHandlerBase<MainUI>
{
    private MainUI m_panel;
    public override void AttachToPanel(MainUI panel)
    {
        m_panel = panel;
        RegisterEvent();
    }
    public override void RegisterEvent()
    {
    }
}
