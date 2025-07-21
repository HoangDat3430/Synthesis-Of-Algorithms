using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SquareGrid : GridBase
{
    private SquareGridData _squareGridData;
    public override void Init(GridBaseData data)
    {
        _squareGridData = data as SquareGridData;
        base.Init(data);
    }
    public override Node GenSingleNode(int x, int y)
    {
        GameObject newGrid = new GameObject(string.Format("X:{0}, Y:{1}", x, y));
        newGrid.transform.parent = GridMgr.Instance.transform;
        Vector3 pos = new Vector3(x, 0, y);
        newGrid.transform.localPosition = pos;
        Debug.LogError(pos, newGrid);
        DrawGrid(newGrid, x, y);
        return new Node(newGrid, new Vector2Int(x, y));
    }
    public override void DrawGrid(GameObject newGrid, int x, int y)
    {
        Mesh mesh = new Mesh();
        newGrid.AddComponent<MeshFilter>().mesh = mesh;
        newGrid.AddComponent<MeshRenderer>().material = gridData.normalMat;

        mesh.vertices = SetVertices(4, x, y);
        mesh.triangles = new int[] { 0, 1, 2, 2, 3, 0 };
        mesh.uv = SetUVs(x, y, gridData.mapWidth, gridData.mapHeight);
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        MeshCollider meshCollider = newGrid.AddComponent<MeshCollider>();
        meshCollider.sharedMesh = mesh;
        meshCollider.convex = true;

        CombineInstance ci = new CombineInstance();
        ci.mesh = mesh;
        ci.transform = meshCollider.transform.localToWorldMatrix;
        _submeshes.Add(ci);
    }
    private Vector2[] SetUVs(int x, int y, int tileCountX, int tileCountY)
    {
        float tileWidth = 1f/tileCountX;
        float tileHeight = 1f/tileCountY;

        Vector2[] uvs = new Vector2[4];
        uvs[0] = new Vector2(x * tileWidth, y * tileHeight);
        uvs[1] = new Vector2(x * tileWidth, (y + 1) * tileHeight);
        uvs[2] = new Vector2((x + 1) * tileWidth, (y + 1) * tileHeight);
        uvs[3] = new Vector2((x + 1) * tileWidth, y * tileHeight);

        // uvs[0] = new Vector2(0, 0);
        // uvs[1] = new Vector2(0, 1);
        // uvs[2] = new Vector2(1, 1);
        // uvs[3] = new Vector2(1, 0);
        return uvs;
    }
    private Vector3[] SetVertices(int verticesCount, int x, int y)
    {
        float radius = gridData.edgeSize * Mathf.Sqrt(2) / 2;
        //Vector3 center = new Vector3(x + radius, 0, y + radius);
        //float angleOffset = 45; // place the first vertex of a square is on the top-right => cos(45) 
        Vector3[] vertices = new Vector3[verticesCount];
        // for (int i = 0; i < verticesCount; i++)
        // {
        //     var angleDeg = i * 90 + angleOffset; // each vertex is 90 degree apart
        //     var angleRad = Mathf.Deg2Rad * angleDeg;
        //     float posX = center.x + (radius - gridData.gridSpacing) * (float)Mathf.Cos(angleRad);
        //     float posY = center.z + (radius - gridData.gridSpacing) * (float)Mathf.Sin(angleRad);
        //     vertices[i] = new Vector3(posX, 0, posY);
        // }
        vertices[0] = new Vector3(x, 0, y);
        vertices[1] = new Vector3(x, 0, y + gridData.edgeSize);
        vertices[2] = new Vector3(x + gridData.edgeSize, 0, y + gridData.edgeSize);
        vertices[3] = new Vector3(x + gridData.edgeSize, 0, y);

        vertices[0] = new Vector3(0, 0, 0);
        vertices[1] = new Vector3(0, 0, 1);
        vertices[2] = new Vector3(1, 0, 1);
        vertices[3] = new Vector3(1, 0, 0);
        return vertices;
    }
    private Vector2Int[] GetNeighborDir(Node node)
    {
        return new Vector2Int[]
        {
            new Vector2Int(0, 1),
            new Vector2Int(0, -1),
            new Vector2Int(1, 0),
            new Vector2Int(-1, 0),
            // 4 diagnose dirs in 8 dir mode 
            new Vector2Int(1, 1),
            new Vector2Int(1, -1),
            new Vector2Int(-1, 1),
            new Vector2Int(-1, -1),
        };
    }
    public override List<Node> GetNeighbors(Node node)
    {
        List<Node> neighbors = new List<Node>();
        int dirCount = _squareGridData.isEightDir ? 8 : 4;
        Vector2Int[] directions = GetNeighborDir(node);
        for (int i = 0; i < dirCount; i++)
        {
            Vector2Int relatedPos = directions[i] + node.Position;
            if (relatedPos.x >= 0 && relatedPos.y >= 0 && relatedPos.x < gridData.mapWidth && relatedPos.y < gridData.mapHeight)
            {
                neighbors.Add(gridMap[relatedPos.x, relatedPos.y]);
            }
        }
        return neighbors;
    }
}
