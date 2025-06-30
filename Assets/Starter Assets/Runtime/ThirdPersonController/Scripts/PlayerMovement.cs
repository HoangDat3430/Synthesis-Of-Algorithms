using System.Collections;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PlayerMovement : MonoBehaviour
{
    [Header("Movement Settings")]
    public float walkSpeed = 4f;
    public float runSpeed = 8f;
    public float jumpForce = 6f;
    public float gravity = -9.81f;

    [Header("Ground Check")]
    public Transform groundCheck;
    public float groundDistance = 0.4f;
    public LayerMask groundMask;

    private CharacterController controller;
    private Vector3 velocity;
    private bool isGrounded;
    private Vector3 moveDir = Vector3.zero;
    private bool isDashing = false;
    private bool canDash = true;
    private float dashSpeed = 20f;
    private float dashDuration = 0.2f;
    private float dashCooldown = 1f;


    void Start()
    {
        controller = GetComponent<CharacterController>();
    }

    void Update()
    {
        if (!isDashing)
        {
            HandleMovement();
        }
        if(Input.GetKeyDown(KeyCode.LeftShift) && canDash)
        {
            StartCoroutine(Dash());
        }
        HandleJumpAndGravity();
    }
    IEnumerator Dash()
    {
        isDashing = true;
        canDash = false;
        float elapsed = 0f;
        while (elapsed < dashDuration)
        {
            controller.Move(moveDir.normalized * dashSpeed * Time.deltaTime);
            elapsed += Time.deltaTime;
            yield return null;
        } 
        yield return new WaitForSeconds(dashCooldown);
        isDashing = false;
        canDash = true;
    }
    void HandleMovement()
    {
        float moveX = Input.GetAxis("Horizontal");
        float moveZ = Input.GetAxis("Vertical");

        // Move relative to current forward direction
        moveDir = transform.right * moveX + transform.forward * moveZ;

        // Run when holding Left Shift
        float speed = Input.GetKey(KeyCode.LeftShift) ? runSpeed : walkSpeed;
        controller.Move(moveDir * speed * Time.deltaTime);
    }

    void HandleJumpAndGravity()
    {
        // Ground check
        isGrounded = Physics.CheckSphere(groundCheck.position, groundDistance, groundMask);

        if (isGrounded && velocity.y < 0)
            velocity.y = -2f; // keep grounded

        if (Input.GetButtonDown("Jump") && isGrounded)
            velocity.y = Mathf.Sqrt(jumpForce * -2f * gravity); // jump physics

        velocity.y += gravity * Time.deltaTime;
        controller.Move(velocity * Time.deltaTime);
    }
}
