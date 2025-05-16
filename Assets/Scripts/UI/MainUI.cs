using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MainUI : UIPanelBase
{
    public Button MenuBtn;
    public override void Init()
    {
        RegisterInternalEvents();
    }
    protected override void RegisterInternalEvents()
    {
        base.RegisterInternalEvents();
    }
}
