codeunit 6150621 "NPR POS Action: Change Bin-B"
{
    Access = Internal;

    procedure ChangeBin(SaleLine: codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        WMSMgt: Codeunit "WMS Management";
        NewBinCode: Code[20];
        NonInvItemError: Label 'Bin Code cannot be selected for a non-inventoriable item.';
    begin
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not SaleLinePOS.IsInventoriableItem() then
            Error(NonInvItemError);

        WhseItemTrackingSetup."Serial No." := SaleLinePOS."Serial No.";
        NewBinCode := WMSMgt.BinContentLookUp(SaleLinePOS."Location Code", SaleLinePOS."No.", SaleLinePOS."Variant Code", '', WhseItemTrackingSetup, SaleLinePOS."Bin Code");
        if NewBinCode = '' then
            exit;

        if SaleLinePOS."Bin Code" = NewBinCode then
            exit;

        SaleLine.SetBin(NewBinCode);
    end;
}