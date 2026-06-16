#if not (BC17 or BC18 or BC19 or BC20 or BC21)
interface "NPR IDigNotifAssetProcessor"
{
    Access = Internal;

    /// <summary>Adds this asset type's manifest assets for one document line. Implementations read inputs from the
    /// buffers and shared state (manifest id, asset count, setup, dedup) from the Context.</summary>
    procedure ProcessAsset(var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary; var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary; var Context: Codeunit "NPR DigNotif Manifest Context");
}
#endif
