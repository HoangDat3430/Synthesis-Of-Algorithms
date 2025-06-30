using UnityEditor;
using System;
using System.Linq;
using System.Diagnostics;

[CustomEditor(typeof(GridMgr))]
public class GridDataHolderEditor : Editor
{
    GridMgr gridMgr;
    private SerializedProperty algorithmProp;
    private SerializedProperty gridTypeProp;
    private SerializedProperty gridDataProp;
    private int selectedIndex = -1;

    private void OnEnable()
    {
        gridMgr = (GridMgr)target;
        algorithmProp = serializedObject.FindProperty("Algorithm");
        gridTypeProp = serializedObject.FindProperty("gridType");
        gridDataProp = serializedObject.FindProperty("gridData");

        if (gridDataProp.managedReferenceValue != null)
        {
            selectedIndex = (int)gridMgr.gridType;
        }
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        if (gridTypeProp.enumValueIndex != selectedIndex)
        {
            // Step 1: Backup base data
            GridBaseData oldData = gridDataProp.managedReferenceValue as GridBaseData;
            GridBaseData newData = GetGridDataByType(gridMgr.gridType);

            if (oldData != null && newData != null)
            {
                var baseType = typeof(GridBaseData);
                var fields = baseType.GetFields();

                foreach (var field in fields)
                {
                    var oldValue = field.GetValue(oldData);
                    field.SetValue(newData, oldValue);
                }
            }
            gridDataProp.managedReferenceValue = newData;
            selectedIndex = (int)gridMgr.gridType;
        }
        EditorGUILayout.PropertyField(algorithmProp);
        EditorGUILayout.PropertyField(gridTypeProp);
        EditorGUILayout.PropertyField(gridDataProp, true);
        serializedObject.ApplyModifiedProperties();
    }
    private GridBaseData GetGridDataByType(GridType type)
    {
        switch (type)
        {
            case GridType.Hexagon:
                return new HexGridData();
            case GridType.Square:
                return new SquareGridData();
            default:
                break;
        }
        return null;
    }
}
