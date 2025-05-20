using System.Collections.Generic;
using Cysharp.Threading.Tasks;
public enum Scene
{
    None = 0,
    PathFinding = 1,
    Boid = 2,
    ArrangeSquad = 3,
    CutMesh = 4,
}
public static class SceneFactory
{
    private static readonly HashSet<Scene> openedScene = new();
    public static void Registry()
    {
        openedScene.Add(Scene.PathFinding);
        openedScene.Add(Scene.Boid);
        openedScene.Add(Scene.ArrangeSquad);
        openedScene.Add(Scene.CutMesh);
    }
    public static async UniTask LoadSceneAsync(Scene scene)
    {
        await SceneLoader.LoadSceneAsync(scene);
        SetupScene(scene);
    }

    private static void SetupScene(Scene scene)
    {
        switch (scene)
        {
            case Scene.PathFinding:
                break;
            case Scene.CutMesh:
                break;
        }
    }
}
