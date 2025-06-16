public interface IUIHandlerBase<TPanel> where TPanel : IUIPanelBase
{
    void AttachToPanel(TPanel panelBase);
    void RegisterEvent();
}
