using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MainUI : UIPanelBase<MainUI, MainUIHandler>
{
    public Transform _algorithmsPopup;
    public Button MenuBtn;
    public Button ConfirmBtn;
    public Button CancelBtn;

    public override void Init()
    {
        base.Init();
    }
    protected override void RegisterInternalEvents()
    {
        MenuBtn.onClick.AddListener(() => OnSetPopupVisible(true));
        CancelBtn.onClick.AddListener(() => OnSetPopupVisible(false));
    }
    private void OnSetPopupVisible(bool visible)
    {
        _algorithmsPopup.gameObject.SetActive(visible);
    }
}
