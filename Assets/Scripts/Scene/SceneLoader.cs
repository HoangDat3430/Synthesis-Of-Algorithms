using UnityEngine;
using UnityEngine.SceneManagement;
using Cysharp.Threading.Tasks;
using System;
using System.Collections.Generic;

public static class SceneLoader
{
    public static async UniTask LoadSceneAsync(Scene sceneName, bool showLoadingUI = true, float minLoadingTime = 1f)
    {
        if (showLoadingUI)
            await LoadingUI.Instance.ShowAsync();

        var loadingStartTime = Time.time;

        AsyncOperation loadOp = SceneManager.LoadSceneAsync(sceneName.ToString(), LoadSceneMode.Single);
        loadOp.allowSceneActivation = false;

        while (loadOp.progress < 0.9f)
        {
            LoadingUI.Instance.SetProgress(loadOp.progress);
            await UniTask.Yield();
        }

        float elapsed = Time.time - loadingStartTime;
        if (elapsed < minLoadingTime)
            await UniTask.Delay(TimeSpan.FromSeconds(minLoadingTime - elapsed));

        loadOp.allowSceneActivation = true;
        await UniTask.WaitUntil(() => loadOp.isDone);

        if (showLoadingUI)
            await LoadingUI.Instance.HideAsync();
    }
}
