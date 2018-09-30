using UnityEngine;
using Unity.Mathematics;

class LinearMotion : MonoBehaviour
{
    [SerializeField] float3 _positionVelocity = 0;
    [SerializeField] float3 _rotationVelocity = 0;

    float3 _originalPosition;
    quaternion _originalRotation;

    void Start()
    {
        _originalPosition = transform.localPosition;
        _originalRotation = transform.localRotation;
    }

    void Update()
    {
        var dp = _positionVelocity * Time.time;
        var dr = _rotationVelocity * Time.time;
        transform.localPosition = _originalPosition + dp;
        transform.localRotation = math.mul(quaternion.EulerXYZ(dr), _originalRotation);
    }
}
