using UnityEngine;

public class CameraController : MonoBehaviour
{
    public Transform targetPivot; // Điểm để xoay quanh (pivot)
    public float distance = 10f;  // Khoảng cách từ camera đến pivot
    public float zoomSpeed = 5f;
    public float rotateSpeed = 5f;
    public float panSpeed = 0.01f;
    public float minDistance = 2f;
    public float maxDistance = 50f;

    private float yaw = 0f;
    private float pitch = 30f;

    private Vector3 lastMousePos;

    void Start()
    {
        if (targetPivot == null)
        {
            // Tạo pivot mặc định nếu chưa có
            GameObject pivot = new GameObject("CameraPivot");
            pivot.transform.position = transform.position + transform.forward * distance;
            targetPivot = pivot.transform;
        }

        Vector3 dir = (transform.position - targetPivot.position).normalized;
        distance = Vector3.Distance(transform.position, targetPivot.position);
        transform.LookAt(targetPivot);
    }

    void Update()
    {
        HandleInput();
        UpdateCameraPosition();
        ShaderUtility.SetGlobal("_camPos", transform.position);
    }

    void HandleInput()
    {
        if (Input.GetMouseButtonDown(1) || Input.GetMouseButtonDown(2))
            lastMousePos = Input.mousePosition;

        Vector3 mouseDelta = Input.mousePosition - lastMousePos;

        // Rotate (Right Mouse)
        if (Input.GetMouseButton(1))
        {
            yaw += mouseDelta.x * rotateSpeed * Time.deltaTime;
            pitch -= mouseDelta.y * rotateSpeed * Time.deltaTime;
            pitch = Mathf.Clamp(pitch, -89f, 89f);
        }

        // Pan (Middle Mouse)
        if (Input.GetMouseButton(2))
        {
            Vector3 pan = -mouseDelta.x * transform.right + -mouseDelta.y * transform.up;
            targetPivot.position += pan * panSpeed;
        }

        // Zoom
        float scroll = Input.GetAxis("Mouse ScrollWheel");
        if (Mathf.Abs(scroll) > 0.01f)
        {
            distance -= scroll * zoomSpeed;
            distance = Mathf.Clamp(distance, minDistance, maxDistance);
        }

        lastMousePos = Input.mousePosition;
    }

    void UpdateCameraPosition()
    {
        Quaternion rotation = Quaternion.Euler(pitch, yaw, 0);
        Vector3 dir = rotation * Vector3.back;
        transform.position = targetPivot.position + dir * distance;
        transform.rotation = rotation;
    }
}
