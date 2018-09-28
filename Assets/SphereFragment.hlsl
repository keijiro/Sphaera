// Self emission term
half3 SelfEmission(FragInputs input, SurfaceData surface)
{
    float x = input.texCoord0.x * 2;
    float y = input.texCoord0.y * 1000;
    float fw = fwidth(y);

    float t = lerp(1, 3, Hash(floor(y))) * 0.02 * (_Time.y + 100);
    float scroll = pow(frac(x - t), 10) * 10;

    float ln = saturate(1 - abs(0.5 - frac(y)) / fw);

    float mask = smoothstep(0.001, 0.002, surface.baseColor.x);

    return ln * scroll * mask;
}

// Fragment shader function, copy-pasted from HDRP/ShaderPass/ShaderPassGBuffer.hlsl
// There are a few modification from the original shader. See "Custom:" for details.
void SphereFragment(
            PackedVaryingsToPS packedInput,
            OUTPUT_GBUFFER(outGBuffer)
            #ifdef _DEPTHOFFSET_ON
            , out float outputDepth : SV_Depth
            #endif
            )
{
    FragInputs input = UnpackVaryingsMeshToFragInputs(packedInput.vmesh);

    // input.positionSS is SV_Position
    PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

#ifdef VARYINGS_NEED_POSITION_WS
    float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
#else
    // Unused
    float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0
#endif

    SurfaceData surfaceData;
    BuiltinData builtinData;
    GetSurfaceAndBuiltinData(input, V, posInput, surfaceData, builtinData);

    // Custom: Add the self emission term.
    builtinData.bakeDiffuseLighting += SelfEmission(input, surfaceData);

#ifdef DEBUG_DISPLAY
    ApplyDebugToSurfaceData(input.worldToTangent, surfaceData);
#endif

    ENCODE_INTO_GBUFFER(surfaceData, builtinData, posInput.positionSS, outGBuffer);

#ifdef _DEPTHOFFSET_ON
    outputDepth = posInput.deviceDepth;
#endif
}
