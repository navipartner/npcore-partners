codeunit 6184649 "NPR Eject Payment Bin On Sale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        POSPaymentBinEjectMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSUnit.Get(Rec."Register No.") then
            exit;

        if not POSAuditProfile.Get(POSUnit."POS Audit Profile") then
            exit;

        if not POSAuditProfile."Bin Eject After Sale" then
            exit;

        POSPaymentBinEjectMgt.CarryOutPaymentBinEject(Rec, false);
    end;
}