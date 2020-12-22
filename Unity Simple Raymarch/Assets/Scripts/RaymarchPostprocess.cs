using UnityEngine;

public class RaymarchPostprocess : MonoBehaviour
{
    [SerializeField]
    private Shader onRenderShader = null;

    private Material mat = null;

    private float zMovement = 0.0f;
    private float zStep = 0.5f;

    private void Awake()
    {
        InitializeMaterial();
    }

    private void FixedUpdate()
    {
        ProcessInput();
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        InitializeMaterial();
        SetShaderParameters();
        // Read pixels from the source RenderTexture, apply the material, copy the updated results to the destination RenderTexture
        Graphics.Blit(source, destination, mat);
    }

    private void ProcessInput()
    {
        if (Input.GetKey(KeyCode.W))
        {
            zMovement += zStep * Time.deltaTime;
        }
        if (Input.GetKey(KeyCode.S))
        {
            zMovement -= zStep * Time.deltaTime;
        }
    }

    private void SetShaderParameters()
    {
        mat.SetFloat("_ZMovingAmount", zMovement);
    }

    // Setting up our material if needed
    private void InitializeMaterial()
    {
        if (onRenderShader == null)
        {
            Debug.LogError("Ooops: OnRenderShader is missing!");

            return;
        }

        if (mat == null)
        {
            mat = new Material(onRenderShader);
        }
    }

}
