using System.Collections.Generic;

public interface IPathFindingAlgorithm
{
    List<Node> FindPath(Node start, Node end, GridBase gridBase);
}