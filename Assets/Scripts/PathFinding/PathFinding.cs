using System.Collections.Generic;
using UnityEngine;

public enum PathFindingType
{
    AStar,
    Dijkstra,
    FlowField,
    BFS,
    DFS
}
public static class PathFinding
{
    private static Dictionary<PathFindingType, IPathFindingAlgorithm> algorithms = new Dictionary<PathFindingType, IPathFindingAlgorithm>
    {
        { PathFindingType.AStar, new AStart() },
        { PathFindingType.FlowField, new FlowField() },
        //{ PathFindingType.Dijkstra, new Dijkstra() },
        //{ PathFindingType.BFS, new BFS() },
        //{ PathFindingType.DFS, new DFS() }
    };

    public static List<Node> FindPath(PathFindingType type, Node start, Node end, GridBase gridBase)
    {
        IPathFindingAlgorithm algorithm;
        if (algorithms.TryGetValue(type, out algorithm))
        {
            return algorithm.FindPath(start, end, gridBase);
        }
        else
        {
            Debug.LogError("Algorithm not found");
        }
        return null;
    }
}
