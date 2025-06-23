public class PathFindingViewHandler : UIHandlerBase<PathFindingView>
{
    private PathFindingView m_panel;
    public override void AttachToPanel(PathFindingView panel)
    {
        m_panel = panel;
        RegisterEvent();
    }
    public override void RegisterEvent()
    {
        m_panel.resetBtn.onClick.AddListener(OnResetGrid);
    }
    private void OnResetGrid()
    {
        UIEventBus.Publish(new ResetMapEvent());
    }
}
