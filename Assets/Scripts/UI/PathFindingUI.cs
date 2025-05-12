using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PathFindingUI : UIPanelBase
{
    private Button m_ResetBtn;
    private Button m_FindPathBtn;
    private void Awake()
    {
        m_ResetBtn = transform.Find("ResetMap").GetComponent<Button>();
        m_FindPathBtn = transform.Find("FindPath").GetComponent<Button>();
    }
    private void Start()
    {
        RegisterButtonEvent(m_ResetBtn, EventID.ResetMap);   
        RegisterButtonEvent(m_ResetBtn, EventID.FindPath);   
    }
    public override void Show()
    {
        base.Show();
    }
    public override void Hide()
    {
        base.Hide();
    }
}
