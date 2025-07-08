using System;
using UnityEngine.UI;

public class PathFindingView : UIPanelBase<PathFindingView, PathFindingViewHandler>
{
    public Button CombineMeshBtn;
    public Button resetBtn;
    public Action OnCombineMesh;

    protected override void RegisterInternalEvents()
    {
        CombineMeshBtn.onClick.AddListener(() => OnCombineMesh?.Invoke());
    }
}
