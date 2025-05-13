using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class PathFindingPanel : UIPanelBase
{
    private PathFindingPanelHandler m_Handler;

    [SerializeField] private Button m_ResetBtn;
    [SerializeField] private Button m_FindPathBtn;
    private void Awake()
    {
    }
    private void Start()
    {
        Debug.LogError(1);
        RegisterInternalEvents();
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
        m_ResetBtn.onClick.AddListener(m_Handler.OnReset);
        m_FindPathBtn.onClick.AddListener(m_Handler.OnFindPath);
    }
}
