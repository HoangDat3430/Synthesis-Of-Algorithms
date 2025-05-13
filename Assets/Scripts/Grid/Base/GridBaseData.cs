using System;
using UnityEngine;

[Serializable] public abstract class GridBaseData
{
    public int edgeSize = 1;
    public float gridSpacing;
    public int mapWidth = 2;
    public int mapHeight = 4;
    public Material normalMat;
    public Material startMat;
    public Material desiredMat;
    public Material goalMat;
    public Material[] terrainMat;
}
