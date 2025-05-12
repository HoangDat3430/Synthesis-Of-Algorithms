using System.Collections.Generic;
using System.Linq;
using UnityEditor.Experimental.GraphView;
using UnityEngine;

public abstract class GridBase : IGrid
{
    public GridBaseData gridData;

    public Node[,] gridMap;
    public Dictionary<Node, List<Node>> startNodeList = new Dictionary<Node, List<Node>>();
    public Node goalPos;
    public void SetStartPos(Node start)
    {
        // For toggle a start node
        if (startNodeList.ContainsKey(start))
        {
            // Clear that start node's path
            foreach (Node node in startNodeList[start])
            {
                SetMaterial(node, gridData.terrainMat[(int)node.terrain]);
            }
            start.meshRenderer.material = gridData.terrainMat[(int)start.terrain]; // reset the start node's material
            startNodeList.Remove(start);
            ShowPaths();
        }
        else
        {
            List<Node> path = new List<Node>();
            if (goalPos != start)
            {
                if (goalPos != null)
                {
                    path = PathFinding.FindPath(GridMgr.Instance.algorithm, start, goalPos, this);
                    foreach (Node node in path)
                    {
                        SetMaterial(node, gridData.desiredMat);
                    }
                }
                startNodeList[start] = path;
                start.meshRenderer.material = gridData.startPosMat;
            }
        }
    }
    public void SetGoalPos(Node newGoalNode)
    {
        if (goalPos != newGoalNode && !startNodeList.ContainsKey(newGoalNode))
        {
            // reset the previous goal position
            if (goalPos != null)
            {
                goalPos.meshRenderer.material = gridData.terrainMat[(int)goalPos.terrain]; 
            }
            goalPos = newGoalNode;

            var tempDic = new Dictionary<Node, List<Node>>();
            foreach (var data in startNodeList)
            {
                // reset the previous path of each start node
                foreach (Node node in data.Value)
                {
                    SetMaterial(node, gridData.terrainMat[(int)node.terrain]);
                }
                // recalculate new path each start node and save the new path to temporary dictionary to avoid modifying the original dictionary while iterating
                tempDic[data.Key] = PathFinding.FindPath(GridMgr.Instance.algorithm, data.Key, goalPos, this); 
            }
            // update the original dictionary with the new paths
            startNodeList = tempDic;
            ShowPaths();
            goalPos.meshRenderer.material = gridData.goalPosMat;
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
    private bool SetMaterial(Node node, Material material)
    {
        bool canSet = node.meshRenderer.sharedMaterial != gridData.startPosMat && node.meshRenderer.sharedMaterial != gridData.goalPosMat;
        if (canSet)
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
    }
    public void GenGrid()
    {
        gridMap = new Node[gridData.mapWidth, gridData.mapHeight];
        for (int y = 0; y < gridData.mapHeight; y++)
        {
            for (int x = 0; x < gridData.mapWidth; x++)
            {
                gridMap[x, y] = GenSingleNode(x, y);
            }
        }
    }
    public Node GenSingleNode(int x, int y)
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
    public virtual List<Node> GetNeighbors(Node node)
    {
        return null;
    }
}
