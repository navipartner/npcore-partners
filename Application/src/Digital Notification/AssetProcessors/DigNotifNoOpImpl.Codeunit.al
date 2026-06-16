#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248206 "NPR DigNotif NoOp Impl" implements "NPR IDigNotifAssetProcessor"
{
    Access = Internal;

    procedure ProcessAsset(var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary; var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary; var Context: Codeunit "NPR DigNotif Manifest Context")
    begin
        // None: the line is not a digital asset — intentionally do nothing.
    end;
}
#endif
