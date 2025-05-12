using System.Collections.Generic;
using UnityEngine;

public class Node
{
    private GameObject nodeGO;
    private Vector2Int pos;
    public float mCost => (int)terrain + 1;
    public float hCost; // heuristic
    public float gCost = float.MaxValue; // cost so far
    public float fCost => gCost + hCost;
    
    public Node prevNode;
    public Node nextNode;
    public List<Node> neighbors;
    
    public bool isObstacle;
    public TerrainType terrain = TerrainType.Ground;
    public MeshRenderer meshRenderer;
    public GameObject NodeGO
    {
        get { return nodeGO; }
    }
    public Vector2Int Position
    {
        get { return pos; }
    }
    public Node(GameObject nodeGO, Vector2Int pos, bool isObstacle = false)
    {
        this.nodeGO = nodeGO;
        this.pos = pos;
        this.isObstacle = isObstacle;
        prevNode = null;
        meshRenderer = nodeGO.GetComponent<MeshRenderer>();
    }
}
