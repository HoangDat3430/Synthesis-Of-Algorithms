using UnityEngine;

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

    public PathFindingType algorithm = PathFindingType.AStar;
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
        bool isSetStartPos = Input.GetMouseButtonUp(0);
        bool isSetGoalPos = Input.GetMouseButtonUp(1);
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
        UIEventBus.Subscribe<FindPathEvent>(_curGrid.OnFindPath);
        UIEventBus.Subscribe<ResetMapEvent>(_curGrid.OnResetMap);
    }
    private void OnDisable()
    {
        UIEventBus.Unsubscribe<FindPathEvent>(_curGrid.OnFindPath);
        UIEventBus.Unsubscribe<ResetMapEvent>(_curGrid.OnResetMap);
    }
}
