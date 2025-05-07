using UnityEditor;
using UnityEngine;
using System;
using System.Linq;
using System.Collections.Generic;
using System.Reflection;
using System.Collections;

[CustomEditor(typeof(GridMgr))]
public class GridDataHolderEditor : Editor
{
    private SerializedProperty gridDataProp;
    private Type[] gridTypes;
    private string[] gridTypeNames;
    private int selectedIndex = -1;

    private void OnEnable()
    {
        gridDataProp = serializedObject.FindProperty("gridData");
        // Get all types that inherit from GridBaseData
        gridTypes = AppDomain.CurrentDomain.GetAssemblies()
            .SelectMany(a => a.GetTypes())
            .Where(t => !t.IsAbstract && typeof(GridBaseData).IsAssignableFrom(t))
            .ToArray();

        gridTypeNames = gridTypes.Select(t => t.Name).ToArray();

        if (gridDataProp.managedReferenceValue != null)
        {
            Type currentType = gridDataProp.managedReferenceValue.GetType();
            selectedIndex = Array.FindIndex(gridTypes, t => t == currentType);
        }
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        // Dropdown to select type
        int newIndex = EditorGUILayout.Popup("Grid Type", selectedIndex, gridTypeNames);
        if (newIndex != selectedIndex)
        {
            // Step 1: Backup base data
            GridBaseData oldData = gridDataProp.managedReferenceValue as GridBaseData;
            GridBaseData newData = Activator.CreateInstance(gridTypes[newIndex]) as GridBaseData;

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
            SerializedProperty gridTypeProp = serializedObject.FindProperty("gridType");
            gridTypeProp.enumValueIndex = (int)GetTypeBaseOnClass(gridTypes[newIndex]);

            gridDataProp.managedReferenceValue = newData;
            selectedIndex = newIndex;
        }
        EditorGUILayout.PropertyField(gridDataProp, true);
        serializedObject.ApplyModifiedProperties();
    }
    private GridType GetTypeBaseOnClass(Type type)
    {
        if(type == typeof(HexGridData)) return GridType.Hexagon;
        if(type == typeof(SquareGridData)) return GridType.Square;
        return GridType.Symetrics;
    }
}
