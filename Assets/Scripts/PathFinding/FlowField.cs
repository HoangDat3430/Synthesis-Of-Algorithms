using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEngine;

public class FlowField : IPathFindingAlgorithm
{
    private Node goal;
    public List<Node> FindPath(Node start, Node end, GridBase gridBase)
    {
        // With this algorithm, just set flow field when new goal position is updated.
        if (goal != end)
        {
            SetFlow(end, gridBase);
        }
        List<Node> result = new List<Node>();
        Node curNode = start;
        while (curNode != null)
        {
            result.Add(curNode);
            curNode = curNode.nextNode;
        }
        return result;
    }
    private void SetFlow(Node end, GridBase gridBase)
    {
        // Reset all node costs
        foreach (Node node in gridBase.gridMap)
        {
            node.gCost = float.MaxValue;
            node.prevNode = null;
            node.nextNode = null;
        }
        // Update new goal position
        goal = end;
        goal.gCost = 0;
        Queue<Node> queue = new Queue<Node>();
        queue.Enqueue(goal);
        // Use reverse Dijkstra algorithm to calculate the cost of each node from the goal
        while (queue.Count > 0)
        {
            Node curNode = queue.Dequeue();
            foreach (Node neighbor in curNode.neighbors)
            {
                float costToNeighbor = curNode.gCost + neighbor.mCost;
                if (costToNeighbor < neighbor.gCost)
                {
                    neighbor.gCost = costToNeighbor;
                    neighbor.nextNode = curNode;
                    queue.Enqueue(neighbor);
                }
            }
        }
    }
}