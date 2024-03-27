codeunit 6184798 "NPR POS Action Set Lot No B"
{
    Access = Internal;

    #region CheckLineTracking
    internal procedure CheckLineTracking(SaleLinePOS: Record "NPR POS Sale Line";
                                         var RequiresLotNo: Boolean;
                                         var UseSpecificTracking: Boolean;
                                         var HasAssignedLotNo: boolean)
    begin
        CheckTrackingOptions(SaleLinePOS);

        GetTrackingOptions(SaleLinePOS,
                           RequiresLotNo,
                           UseSpecificTracking);

        HasAssignedLotNo := SaleLinePOS."Lot No." <> '';


    end;
    #endregion CheckLineTracking


    #region AssignLotNo
    internal procedure AssignLotNo(var SaleLinePOS: Record "NPR POS Sale Line"; LotNoInput: Text[50]; POSSetup: Codeunit "NPR POS Setup")
    var
        POSStore: Record "NPR POS Store";
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
    begin
        CheckTrackingOptions(SaleLinePOS);

        POSSetup.GetPOSStore(POSStore);
        NPRPOSTrackingUtils.ValidateLotNo(SaleLinePOS."No.", SaleLinePOS."Variant Code", LotNoInput, POSStore);

        SaleLinePOS.Validate("Lot No.", LotNoInput);
        SaleLinePOS.Modify(true);

    end;
    #endregion AssignLotNo

    #region CheckTrackingOptions
    internal procedure CheckTrackingOptions(SaleLinePOS: Record "NPR POS Sale Line")
    var
        Item: Record Item;
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        UseSpecificTracking: Boolean;
        LineTypeErr: Label 'Line Type on %1 must be %2 or %3. Current value %4.', Comment = '%1 - Current line record id, %2 - allowed line type value, %3 - allowed line type value, %4 - current line type value.';
        ItemDoesNotRequireLotNoErr: Label 'Item %1 does not require Lot No. tracking.', Comment = '%1 - Item No.';

    begin
        if not (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::Item,
                                            salelinepos."Line Type"::"BOM List"])
        then
            Error(LineTypeErr, Format(SaleLinePOS.RecordId),
                               SaleLinePOS."Line Type"::Item,
                               SaleLinePOS."Line Type"::"BOM List",
                               SaleLinePOS."Line Type");

        SaleLinePOS.TestField("No.");
        Item.get(SaleLinePOS."No.");
        if not NPRPOSTrackingUtils.ItemRequiresLotNo(Item, UseSpecificTracking) then
            Error(ItemDoesNotRequireLotNoErr, Item."No.");

    end;
    #endregion CheckTrackingOptions

    #region GetTrackingOptions
    internal procedure GetTrackingOptions(SaleLinePOS: Record "NPR POS Sale Line";
                                          var RequiresLotNo: Boolean;
                                          var UseSpecificTracking: Boolean) TrackingOptionsFound: Boolean
    var
        Item: Record Item;
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
    begin
        if not (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::Item,
                                            salelinepos."Line Type"::"BOM List"])
        then
            exit;

        if SaleLinePOS."No." = '' then
            exit;

        Item.get(SaleLinePOS."No.");
        RequiresLotNo := NPRPOSTrackingUtils.ItemRequiresLotNo(Item, UseSpecificTracking);
        TrackingOptionsFound := true;
    end;
    #endregion GetTrackingOptions


}