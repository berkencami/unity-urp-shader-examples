using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class EnableDepthBuffer : MonoBehaviour
{
    private Camera m_camera;

    private void Start()
    {
        if (m_camera == null)
        {
            m_camera = GetComponent<Camera>();
        }

        m_camera.depthTextureMode = DepthTextureMode.Depth;
    }
}