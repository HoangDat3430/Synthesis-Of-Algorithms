using UnityEngine;

public interface IGrid
{
    public void SetStartPos(Node node);
    public void SetGoalPos(Node node);
    public void SetTerrain(Node node, TerrainType type);
    public void Init(GridBaseData data);
    public Vector3 GetCenter(int x, int y);
    public Node GetNodeByGameObject(GameObject go);
}
