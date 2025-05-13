using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class PathFindingPanel : UIPanelBase
{
    private Button m_ResetBtn;
    private Button m_FindPathBtn;
    private void Awake()
    {
        UIManager.Instance.RegisterPanel(this);
    }
    private void Start()
    {
        m_ResetBtn = transform.Find("ResetMap").GetComponent<Button>();
        m_FindPathBtn = transform.Find("FindPath").GetComponent<Button>();
    }
    public override void Show()
    {
        base.Show();
    }
    public override void Hide()
    {
        base.Hide();
    }
    public override void RegisterInternalEvents()
    {
    }
    public override void RegisterExternalEvents()
    {
        m_ResetBtn.onClick.AddListener(OnReset);
        m_FindPathBtn.onClick.AddListener(OnFindPath);
    }
    private void OnReset()
    {
        UIEventBus.Publish(new ResetMapEvent());
    }
    private void OnFindPath()
    {
        UIEventBus.Publish(new FindPathEvent());
    }
}
