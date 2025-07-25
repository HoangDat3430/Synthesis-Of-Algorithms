using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class FindPathEvent{}
public class ResetMapEvent{}
public abstract class GridBase : IGrid
{
    public GridBaseData gridData;
    public Node[,] gridMap;
    public Dictionary<Node, List<Node>> startNodeList = new Dictionary<Node, List<Node>>();
    public Node goal;
    protected List<CombineInstance> _submeshes = new();
    private Queue<Vector4> rippleDatas = new(8);
    public void SetStartPos(Node newStartNode)
    {
        SetTouchPoint(newStartNode.Position);
        return;
        if (goal != newStartNode)
        {
            // For toggle a start node
            if (startNodeList.ContainsKey(newStartNode))
            {
                ResetStartNode(newStartNode);
                startNodeList.Remove(newStartNode);
                FindAllPaths();
            }
            else
            {
                SetMaterial(newStartNode, gridData.startMat);
                startNodeList[newStartNode] = new List<Node>();
                if (goal != null)
                {
                    startNodeList[newStartNode] = FindPathOfNode(newStartNode);
                }
            }
            ShowPaths();
        }
    }
    public void SetGoalPos(Node newGoalNode)
    {
        if (goal != newGoalNode && !startNodeList.ContainsKey(newGoalNode))
        {
            // reset the material of previous goal position
            if (goal != null)
            {
                SetMaterial(goal, gridData.terrainMat[(int)goal.terrain], true);
            }
            goal = newGoalNode;
            SetMaterial(goal, gridData.goalMat, true);
            FindAllPaths();
            ShowPaths();
        }
    }
    string name = "_TouchPoint";
    private void SetTouchPoint(Vector2 pos)
    {
        if (rippleDatas.Count >= 8)
        {
            Debug.LogError($"Ripple: {rippleDatas.Peek()} is removed!");
            rippleDatas.Dequeue();
        }
        float duration = 2f;
        Vector4 newPoint = new Vector4(pos.x / gridData.mapWidth, pos.y / gridData.mapHeight, duration, Time.time);
        rippleDatas.Enqueue(newPoint);
        Debug.LogError($"Ripple: {newPoint} is added!");
        Vector4[] arr = new Vector4[8];
        rippleDatas.CopyTo(arr, 0);
        ShaderUtility.SetGlobal(name, arr);
        ShaderUtility.SetGlobal("_RippleCount", rippleDatas.Count);
    }
    public void FindAllPaths()
    {
        // Save the new path into a temporaty path to avoid exception when modify Collection while looping
        Dictionary<Node, List<Node>> pathList = new();
        foreach (Node start in startNodeList.Keys)
        {
            pathList[start] = FindPathOfNode(start);
        }
        // Update new paths
        startNodeList = pathList;
    }
    private List<Node> FindPathOfNode(Node start)
    {
        if (startNodeList.TryGetValue(start, out var path) && goal != null)
        {
            foreach (Node node in path)
            {
                SetMaterial(node, gridData.terrainMat[(int)node.terrain]);
            }
            path = PathFinding.FindPath(GridMgr.Instance.Algorithm, start, goal, this);
        }
        return path;
    }
    public void ResetMap(ResetMapEvent e)
    {
        // reset all start node and it's path
        if (startNodeList.Count > 0)
        {
            foreach (var start in startNodeList.Keys)
            {
                ResetStartNode(start);
            }
            startNodeList.Clear();
        }
        // reset goal node
        if (goal != null)
        {
            SetMaterial(goal, gridData.terrainMat[(int)goal.terrain], true);
            goal = null;
        }
        for (int i = 0; i < rippleDatas.Count; i++)
        {
            rippleDatas.Dequeue();
        }
        ShaderUtility.SetGlobal("_RippleCount", rippleDatas.Count);
    }
    private void ResetStartNode(Node start)
    {
        // clear start node
        SetMaterial(start, gridData.terrainMat[(int)start.terrain], true);
        foreach (var node in startNodeList[start])
        {
            // clear it's own path
            SetMaterial(node, gridData.terrainMat[(int)start.terrain]);
        }
    }
    public void SetTerrain(Node node, TerrainType type)
    {
        if (!SetMaterial(node, gridData.terrainMat[(int)type])) return;
        if (type == TerrainType.Hole)
        {
            node.isObstacle = true;
        }
        else
        {
            node.terrain = type;
            node.isObstacle = false;
        }
    }
    private bool SetMaterial(Node node, Material material, bool bForce = false)
    {
        bool canSet = node.meshRenderer.sharedMaterial != gridData.startMat && node.meshRenderer.sharedMaterial != gridData.goalMat;
        if (canSet || bForce)
        {
            node.meshRenderer.material = material;
        }
        return canSet;
    }
    private void ShowPaths()
    {
        foreach (var data in startNodeList)
        {
            foreach (Node node in data.Value)
            {
                SetMaterial(node, gridData.desiredMat);
            }
        }
    }
    public virtual void Init(GridBaseData data)
    {
        gridData = data; // set the grid base data for base logics
        GenGrid();
        SetNeighborsForAllGrid();
        UIEventBus.Subscribe<CombineMeshEvent>(CombineMeshes);
    }
    public void GenGrid()
    {
        gridMap = new Node[gridData.mapWidth, gridData.mapHeight];
        for (int y = 0; y < gridData.mapHeight; y++)
        {
            for (int x = 0; x < gridData.mapWidth; x++)
            {
                gridMap[x, y] = GenSingleNode(x, y);
                SetTerrain(gridMap[x, y], TerrainType.Water);
            }
        }
    }
    public virtual Node GenSingleNode(int x, int y)
    {
        GameObject newGrid = new GameObject(string.Format("X:{0}, Y:{1}", x, y));
        newGrid.transform.parent = GridMgr.Instance.transform;
        DrawGrid(newGrid, x, y);
        return new Node(newGrid, new Vector2Int(x, y));
    }
    public virtual void DrawGrid(GameObject newGrid, int x, int y)
    {
    }
    public virtual Vector3 GetCenter(int x, int y)
    {
        return Vector3.zero;
    }
    public Node GetNodeByGameObject(GameObject go)
    {
        foreach (var node in gridMap)
        {
            if (node.NodeGO == go)
            {
                return node;
            }
        }
        return null;
    }
    public void SetNeighborsForAllGrid()
    {
        for (int x = 0; x < gridData.mapWidth; x++)
        {
            for (int y = 0; y < gridData.mapHeight; y++)
            {
                gridMap[x, y].neighbors = GetNeighbors(gridMap[x, y]);
            }
        }
    }
    protected void CombineMeshes(CombineMeshEvent e)
    {
        Mesh combinedMesh = new Mesh();
        combinedMesh.name = "Combined_Water_Mesh";
        combinedMesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
        combinedMesh.CombineMeshes(_submeshes.ToArray(), true, true, false);
        string path = "Assets/CombinedMeshes/CombinedWater.asset";
        Directory.CreateDirectory("Assets/CombinedMeshes");
        AssetDatabase.CreateAsset(combinedMesh, path);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("Mesh saved to: " + path);
    }
    public virtual List<Node> GetNeighbors(Node node)
    {
        return null;
    }
}
