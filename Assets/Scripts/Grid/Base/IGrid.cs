using UnityEngine;

public interface IGrid
{
    public void SetStartPos(Node node);
    public void SetGoalPos(Node node);
    public void SetTerrain(Node node, TerrainType type);
    public void Init(GridBaseData data);
    public Node GetNodeByGameObject(GameObject go);
    public void FindAllPaths();
    public void ResetMap(ResetMapEvent e);
}
