﻿using UnityEngine;
using UnityEngine.EventSystems;

public enum GridType
{
    Square,
    Hexagon,
    Symetrics
}
public enum TerrainType
{
    Ground,
    Water,
    Swamp,
    Rock,
    Hole
}
public class GridMgr : MonoBehaviour
{
    public static GridMgr Instance { get; private set; }

    public PathFindingType Algorithm = PathFindingType.AStar;
    public GridType gridType = GridType.Hexagon;
    [SerializeReference] public GridBaseData gridData;
    private IGrid _curGrid;
    private IGridFactory _gridFactory;

    private void Awake()
    {
        Instance = this;
        _gridFactory = new GridFactory();
        _curGrid = _gridFactory.CreateGrid(gridType);
    }
    private void Start()
    {
        _curGrid.Init(gridData);
    }

    private void Update()
    {
        // Check if the mouse is raycast on an UI component
        if (EventSystem.current.IsPointerOverGameObject())
        {
            return;
        }
        // Input logics
        bool isSetStartPos = Input.GetMouseButtonUp(0);
        bool isSetGoalPos = Input.GetKeyDown(KeyCode.G);
        if (isSetStartPos || isSetGoalPos)
        {
            RaycastHit hitInfo;
            Ray hit = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(hit, out hitInfo, 100))
            {
                Node hitNode = _curGrid.GetNodeByGameObject(hitInfo.collider.gameObject);
                if (isSetGoalPos && hitNode != null)
                {
                    _curGrid.SetGoalPos(hitNode);
                }
                else
                {
                    _curGrid.SetStartPos(hitNode);
                }
            }
        }
        // Set terrain
        if (Input.GetKeyDown(KeyCode.Alpha0) || Input.GetKeyDown(KeyCode.Alpha1) || Input.GetKeyDown(KeyCode.Alpha2) || Input.GetKeyDown(KeyCode.Alpha3) || Input.GetKeyDown(KeyCode.Alpha4))
        {
            RaycastHit hitInfo;
            Ray hit = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(hit, out hitInfo, 100))
            {
                Node hitNode = _curGrid.GetNodeByGameObject(hitInfo.collider.gameObject);
                _curGrid.SetTerrain(hitNode, (TerrainType)int.Parse(Input.inputString));
            }
        }
    }
    private void OnEnable()
    {
        //UIEventBus.Subscribe<FindPathEvent>(_curGrid.OnFindPath);
        UIEventBus.Subscribe<ResetMapEvent>(_curGrid.ResetMap);
    }
    private void OnDisable()
    {
        //UIEventBus.Unsubscribe<FindPathEvent>(_curGrid.OnFindPath);
        UIEventBus.Unsubscribe<ResetMapEvent>(_curGrid.ResetMap);
    }
}
