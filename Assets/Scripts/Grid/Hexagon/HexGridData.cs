using System;
using UnityEngine;
public enum HexType
{
    PointyTop = 0,
    FlatTop = 1,
}
[Serializable] public class HexGridData : GridBaseData
{
    // Note that this is the regular hexagon
    public HexType hexType;
    public float HexTileWidth { get { return Mathf.Sqrt(3) * edgeSize; } } // distance between two opposite edges of the hexagon
    public float HexTileHeight { get { return 2 * edgeSize; } } // distance between two opposite vertices of the hexagon
}
