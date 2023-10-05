codeunit 6151033 "NPR POS Action Set Serial No B"
{
    Access = Internal;

    #region CheckLineTracking
    internal procedure CheckLineTracking(SaleLinePOS: Record "NPR POS Sale Line";
                                         var RequiresSerialNo: Boolean;
                                         var UseSpecificTracking: Boolean;
                                         var HasAssignedSerialNo: boolean)
    begin
        CheckTrackingOptions(SaleLinePOS);

        GetTrackingOptions(SaleLinePOS,
                           RequiresSerialNo,
                           UseSpecificTracking);

        HasAssignedSerialNo := SaleLinePOS."Serial No." <> '';


    end;
    #endregion CheckLineTracking


    #region AssignSerialNo
    internal procedure AssignSerialNo(var SaleLinePOS: Record "NPR POS Sale Line"; var SerialNumberInput: Text[50]; SerialSelectionFromList: Boolean; POSSetup: Codeunit "NPR POS Setup")
    var
        POSStore: Record "NPR POS Store";
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        QuantityErrLbl: Label 'Quantity at %1 %2 can only be 1 or -1', Comment = '%1 - field name, %2 - field value';
    begin
        CheckTrackingOptions(SaleLinePOS);

        POSSetup.GetPOSStore(POSStore);
        NPRPOSTrackingUtils.ValidateSerialNo(SaleLinePOS."No.", SaleLinePOS."Variant Code", SerialNumberInput, SerialSelectionFromList, POSStore);

        if (SerialNumberInput <> '') and
           (Abs(SaleLinePOS.Quantity) <> 1)
        then
            Error(QuantityErrLbl,
                  SaleLinePOS.FieldName("Serial No."),
                  SerialNumberInput);

        SaleLinePOS.Validate("Serial No.", SerialNumberInput);
        SaleLinePOS.Modify(true);

    end;
    #endregion AssignSerialNo

    #region CheckTrackingOptions
    internal procedure CheckTrackingOptions(SaleLinePOS: Record "NPR POS Sale Line")
    var
        Item: Record Item;
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        UseSpecificTracking: Boolean;
        LineTypeErr: Label 'Line Type on %1 must be %2 or %3. Current value %4.', Comment = '%1 - Current line record id, %2 - allowed line type value, %3 - allowed line type value, %4 - current line type value.';
        ItemDoesNotRequireSerialNoErr: Label 'Item %1 does not require serial no tracking.', Comment = '%1 - item no.';

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
        if not NPRPOSTrackingUtils.ItemRequiresSerialNumber(Item,
                                                            UseSpecificTracking)
        then
            Error(ItemDoesNotRequireSerialNoErr, Item."No.");

    end;
    #endregion CheckTrackingOptions

    #region GetTrackingOptions
    internal procedure GetTrackingOptions(SaleLinePOS: Record "NPR POS Sale Line";
                                          var RequiresSerialNo: Boolean;
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
        RequiresSerialNo := NPRPOSTrackingUtils.ItemRequiresSerialNumber(Item,
                                                                         UseSpecificTracking);

        TrackingOptionsFound := true;
    end;
    #endregion GetTrackingOptions


}