using UnityEngine;
using Cysharp.Threading.Tasks;

public class LoadingUI : MonoBehaviour
{
    public static LoadingUI Instance { get; private set; }

    [SerializeField] private CanvasGroup canvasGroup;
    [SerializeField] private UnityEngine.UI.Slider progressBar;

    void Awake()
    {
        if (Instance != null)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    public async UniTask ShowAsync()
    {
        canvasGroup.alpha = 1;
        canvasGroup.blocksRaycasts = true;
        progressBar.value = 0f;
        await UniTask.Yield();
    }

    public async UniTask HideAsync()
    {
        canvasGroup.alpha = 0;
        canvasGroup.blocksRaycasts = false;
        await UniTask.Yield();
    }

    public void SetProgress(float progress)
    {
        progressBar.value = Mathf.Clamp01(progress);
    }
}
